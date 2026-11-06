"""Windows host execution + Cortex-M4 object compilation. Python stdlib only.
Usage: python run_tests.py --clang path/to/clang.exe --out build
"""
import argparse
import ctypes as ct
import csv
import hashlib
import json
import math
from pathlib import Path
import random
import subprocess
import struct
import unittest


class Measurement(ct.Structure):
    _fields_ = [("amplitude_v", ct.c_float), ("offset_v", ct.c_float),
                ("residual_rms_v", ct.c_float), ("quality", ct.c_int)]


class Observer(ct.Structure):
    _fields_ = [("x", ct.c_float * 3), ("samples", ct.c_uint32)]


class Detector(ct.Structure):
    _fields_ = [("threshold_low_v", ct.c_float), ("threshold_high_v", ct.c_float),
                ("last_ms", ct.c_uint32), ("seen", ct.c_uint32),
                ("calibrated", ct.c_uint32), ("candidate_count", ct.c_uint32),
                ("state", ct.c_int), ("candidate", ct.c_int)]


class Guard(ct.Structure):
    _fields_ = [(name,ct.c_uint32) for name in ("last_block","last_completed_us","last_valid_us",
                "started_us","have_sequence","have_valid","pending","lost_blocks")] + [("fault",ct.c_int)]


metrics = {}


def wave(amplitude=.3, phase=.7, offset=1.65, frequency=10000, vref=3.3, n=400, stride=1):
    data = [0] * (n * stride)
    for k in range(n):
        value = offset + amplitude * math.cos(2 * math.pi * frequency * k / 200000 + phase)
        data[k * stride] = max(0, min(4095, round(value / vref * 4095)))
    return (ct.c_uint16 * len(data))(*data)


class CoreTests(unittest.TestCase):
    def measure(self, data, n=400, stride=1, vref=3.3):
        result = Measurement()
        lib.ss_ir_block(data, n, stride, vref, ct.byref(result))
        return result

    def calibrated(self):
        d = Detector()
        self.assertEqual(lib.ss_detector_calibrate(ct.byref(d), .3, .03, .003), 1)
        return d

    def feed(self, d, amplitude, stamp, quality=0):
        value = Measurement(amplitude, 1.65, .001, quality)
        return lib.ss_detector_update(ct.byref(d), ct.byref(value), stamp)

    def test_01_phase_independence_and_adc_reference(self):
        errors = []
        for phase in [0, .17, 1.1, 2.4, math.pi, 5.8]:
            for vref in [3.0, 3.3, 3.6]:
                m = self.measure(wave(phase=phase, vref=vref), vref=vref)
                self.assertEqual(m.quality, 0)
                errors.append(abs(m.amplitude_v - .3))
                self.assertLess(errors[-1], .001)
        metrics["iq_max_quantised_amplitude_error_V"] = max(errors)

    def test_02_dc_rejection(self):
        for offset in [1.0, 1.65, 2.3]:
            m = self.measure(wave(amplitude=0, offset=offset))
            self.assertLess(m.amplitude_v, 1e-5)
            self.assertAlmostEqual(m.offset_v, offset, delta=.001)

    def test_03_out_of_band_rejection(self):
        m = self.measure(wave(frequency=9000))
        self.assertLess(m.amplitude_v, .001)
        metrics["iq_9kHz_ideal_coherent_bin_residual_V"] = m.amplitude_v

    def test_04_interleaved_dma(self):
        m = self.measure(wave(stride=3), stride=3)
        self.assertEqual(m.quality, 0)
        self.assertAlmostEqual(m.amplitude_v, .3, delta=.001)

    def test_05_clipping_and_invalid_input(self):
        data = wave()
        data[123] = 4095
        self.assertEqual(self.measure(data).quality, 1)
        data[123] = 5000
        self.assertEqual(self.measure(data).quality, 2)
        self.assertEqual(self.measure(wave(), n=399).quality, 2)
        self.assertEqual(self.measure(wave(), vref=float("nan")).quality, 2)
        m = Measurement()
        self.assertEqual(lib.ss_ir_block(None, 400, 1, 3.3, ct.byref(m)), 2)

    def test_06_calibration_rejects_poor_contrast(self):
        for clear, blocked, sigma in [(.03, .3, .001), (.30, .29, .001),
                                      (.3, .03, .06), (float("nan"), .03, .001)]:
            d = Detector()
            self.assertEqual(lib.ss_detector_calibrate(ct.byref(d), clear, blocked, sigma), 0)

    def test_07_hysteresis_and_debounce(self):
        d = self.calibrated()
        self.assertEqual(self.feed(d, .30, 2), 1)
        self.assertEqual(self.feed(d, .30, 4), 1)
        self.assertEqual(self.feed(d, .30, 6), 2)
        self.assertEqual(self.feed(d, .03, 8), 2)
        self.assertEqual(self.feed(d, .165, 10), 2)  # deadband interrupts the transition
        self.assertEqual(self.feed(d, .03, 12), 2)
        self.assertEqual(self.feed(d, .03, 14), 2)
        self.assertEqual(self.feed(d, .03, 16), 3)

    def test_08_fault_stale_recovery_and_clock_wrap(self):
        d = self.calibrated()
        for t in [0xFFFFFFFA, 0xFFFFFFFC, 0xFFFFFFFE]:
            self.feed(d, .30, t)
        self.assertEqual(self.feed(d, .30, 0), 2)
        self.assertEqual(lib.ss_detector_status(ct.byref(d), 100), 6)
        self.assertEqual(self.feed(d, .30, 102), 1)
        self.assertEqual(self.feed(d, .30, 104, quality=1), 4)
        self.assertEqual(self.feed(d, .30, 106), 1)
        self.assertEqual(self.feed(d, .30, 108), 1)
        self.assertEqual(self.feed(d, .30, 110), 2)
        self.assertEqual(self.feed(d, .30, 110), 5)  # repeated timestamp

    def test_09_uncalibrated_and_nonfinite_measurement(self):
        d = Detector()
        lib.ss_detector_reset(ct.byref(d))
        self.assertEqual(self.feed(d, .30, 2), 0)
        m = Measurement(.3, float("nan"), .001, 0)
        self.assertEqual(lib.ss_detector_update(ct.byref(d), ct.byref(m), 4), 5)

    def test_10_observer_noiseless_and_warmup(self):
        o = Observer()
        lib.ss_observer_reset(ct.byref(o))
        a, bias = ct.c_float(), ct.c_float()
        self.assertEqual(lib.ss_observer_read(ct.byref(o), ct.byref(a), ct.byref(bias)), 0)
        for k in range(12000):
            value = 1.8 + .3 * math.cos(2 * math.pi * k / 20 + .72)
            self.assertEqual(lib.ss_observer_step(ct.byref(o), value, 3.3), 1)
        self.assertEqual(lib.ss_observer_read(ct.byref(o), ct.byref(a), ct.byref(bias)), 1)
        self.assertAlmostEqual(a.value, .3, delta=.001)
        self.assertAlmostEqual(bias.value, 1.8, delta=.001)
        metrics["observer_noiseless_amplitude_error_V"] = abs(a.value - .3)

    def test_11_observer_noisy_and_amplitude_step(self):
        o = Observer()
        lib.ss_observer_reset(ct.byref(o))
        rng = random.Random(17)
        a, bias = ct.c_float(), ct.c_float()
        errors, settled_at = [], None
        for k in range(18000):
            target = .3 if k < 9000 else .03
            y = 1.65 + target * math.cos(2 * math.pi * k / 20 + .31) + rng.gauss(0, .005)
            lib.ss_observer_step(ct.byref(o), y, 3.3)
            ready = lib.ss_observer_read(ct.byref(o), ct.byref(a), ct.byref(bias))
            if ready and 4000 <= k < 9000:
                errors.append((a.value-target)**2)
            if k >= 9000 and settled_at is None and abs(a.value-.03) < .003:
                settled_at = (k-9000)/200000
        rmse = math.sqrt(sum(errors)/len(errors))
        self.assertLess(rmse, .002)
        self.assertIsNotNone(settled_at)
        self.assertLess(settled_at, .01)
        self.assertAlmostEqual(a.value, .03, delta=.003)
        metrics["observer_simulated_5mV_noise_amplitude_rmse_V"] = rmse
        metrics["observer_simulated_step_first_entry_10percent_s"] = settled_at

    def test_12_observer_fault_resets_validity(self):
        o = Observer()
        lib.ss_observer_reset(ct.byref(o))
        for _ in range(2000):
            lib.ss_observer_step(ct.byref(o), 1.65, 3.3)
        self.assertEqual(o.samples, 2000)
        self.assertEqual(lib.ss_observer_step(ct.byref(o), float("nan"), 3.3), 0)
        self.assertEqual(o.samples, 0)
        self.assertEqual(lib.ss_observer_step(ct.byref(o), 0, 3.3), 0)

    def test_13_matlab_reference_vector(self):
        source = Path(__file__).resolve().parents[2]/"etudes/resultats/STIMULUS_ADC.csv"
        o = Observer()
        lib.ss_observer_reset(ct.byref(o))
        amplitude, offset = ct.c_float(), ct.c_float()
        maximum = 0.0
        with source.open(encoding="utf-8-sig") as fp:
            for row in csv.DictReader(fp):
                lib.ss_observer_step(ct.byref(o), int(row["adc_code"])*3.3/4095, 3.3)
                ready = lib.ss_observer_read(ct.byref(o), ct.byref(amplitude), ct.byref(offset))
                if ready:
                    maximum = max(maximum, abs(amplitude.value-float(row["amplitude_est_v"])),
                                  abs(offset.value-float(row["offset_est_v"])))
        self.assertLess(maximum, 1e-4)
        metrics["max_C_float_vs_MATLAB_double_difference_V"] = maximum

    def guard(self, now=0):
        g = Guard()
        lib.ss_rt_reset(ct.byref(g), now)
        return g

    def good_block(self, g, block, timestamp):
        self.assertEqual(lib.ss_rt_begin(ct.byref(g),block,timestamp,(timestamp+100)&0xFFFFFFFF),0)
        self.assertEqual(lib.ss_rt_finish(ct.byref(g),(timestamp+500)&0xFFFFFFFF),0)

    def test_14_initial_and_active_data_expiry(self):
        g = self.guard()
        self.assertEqual(lib.ss_rt_status(ct.byref(g),99999),1)
        self.assertEqual(lib.ss_rt_status(ct.byref(g),100000),2)
        self.good_block(g,1,200000)
        self.assertEqual(lib.ss_rt_status(ct.byref(g),299999),0)
        self.assertEqual(lib.ss_rt_status(ct.byref(g),300000),2)

    def test_15_lost_blocks_and_recovery(self):
        g = self.guard()
        self.good_block(g,1,2000)
        self.assertEqual(lib.ss_rt_begin(ct.byref(g),3,6000,6100),4)
        self.assertEqual(g.lost_blocks,1)
        self.assertEqual(lib.ss_rt_status(ct.byref(g),6200),4)
        self.good_block(g,4,8000)
        self.assertEqual(lib.ss_rt_status(ct.byref(g),8500),0)

    def test_16_duplicate_and_reversed_blocks(self):
        g = self.guard()
        self.good_block(g,10,2000)
        self.assertEqual(lib.ss_rt_begin(ct.byref(g),10,2000,2100),3)
        self.assertEqual(lib.ss_rt_begin(ct.byref(g),9,2000,2100),3)

    def test_17_late_processing_start(self):
        g = self.guard()
        self.assertEqual(lib.ss_rt_begin(ct.byref(g),1,2000,3001),6)
        self.assertEqual(g.have_valid,0)

    def test_18_processing_and_buffer_deadline(self):
        g = self.guard()
        self.assertEqual(lib.ss_rt_begin(ct.byref(g),1,2000,2100),0)
        self.assertEqual(lib.ss_rt_finish(ct.byref(g),3101),7)
        self.assertEqual(g.have_valid,0)
        self.assertEqual(lib.ss_rt_begin(ct.byref(g),2,4000,5000),0)
        self.assertEqual(lib.ss_rt_finish(ct.byref(g),6000),7)
        self.assertEqual(g.have_valid,0)

    def test_19_wrong_cadence_and_api_order(self):
        g = self.guard()
        self.assertEqual(lib.ss_rt_finish(ct.byref(g),100),8)
        lib.ss_rt_reset(ct.byref(g),0)
        self.good_block(g,1,2000)
        self.assertEqual(lib.ss_rt_begin(ct.byref(g),2,4200,4300),5)
        lib.ss_rt_reset(ct.byref(g),0)
        self.assertEqual(lib.ss_rt_begin(ct.byref(g),1,2000,2100),0)
        self.assertEqual(lib.ss_rt_begin(ct.byref(g),2,4000,4100),8)

    def test_20_sequence_and_microsecond_clock_wrap(self):
        g = self.guard(0xFFFFF000)
        self.good_block(g,0xFFFFFFFF,0xFFFFFF00)
        self.good_block(g,0,(0xFFFFFF00+2000)&0xFFFFFFFF)
        self.assertEqual(lib.ss_rt_status(ct.byref(g),2000),0)

    def test_21_dma_or_adc_error_is_immediately_invalid(self):
        g = self.guard()
        self.good_block(g,1,2000)
        lib.ss_rt_acquisition_fault(ct.byref(g))
        self.assertEqual(lib.ss_rt_status(ct.byref(g),2600),9)
        self.good_block(g,2,4000)
        self.assertEqual(lib.ss_rt_status(ct.byref(g),4500),0)

    def test_22_expired_values_never_revive_after_full_clock_wrap(self):
        g = self.guard()
        self.good_block(g,1,2000)
        self.assertEqual(lib.ss_rt_status(ct.byref(g),102000),2)
        self.assertEqual(lib.ss_rt_status(ct.byref(g),2001),2)
        d = self.calibrated()
        for t in [2,4,6]:
            self.feed(d,.30,t)
        self.assertEqual(lib.ss_detector_status(ct.byref(d),106),6)
        self.assertEqual(lib.ss_detector_status(ct.byref(d),7),6)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--clang", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    global lib
    root = Path(__file__).resolve().parents[1]
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    clang = args.clang.resolve()
    lld = clang.with_name("lld.exe")
    flags = ["-std=c11", "-O2", "-Wall", "-Wextra", "-Werror", "-ffreestanding",
             "-fno-builtin", "-fno-math-errno", "-ffp-contract=off", "-fstack-usage"]
    subprocess.run([str(clang), *flags, "-DSS_TEST_EXPORTS", "-c", str(root/"core/smartsense.c"),
                    "-o", str(out/"core.host.obj")], check=True)
    subprocess.run([str(clang), *flags, "-c", str(root/"tests/host_support.c"),
                    "-o", str(out/"host_support.obj")], check=True)
    subprocess.run([str(lld), "-flavor", "link", "/dll", "/noentry", "/machine:x64", "/nodefaultlib",
                    "/out:"+str(out/"smartsense.dll"), str(out/"core.host.obj"),
                    str(out/"host_support.obj")], check=True)
    subprocess.run([str(clang), "--target=arm-none-eabi", "-mcpu=cortex-m4", "-mthumb",
                    "-mfpu=fpv4-sp-d16", "-mfloat-abi=hard", *flags, "-c",
                    str(root/"core/smartsense.c"), "-o", str(out/"core.arm.o")], check=True)
    lib = ct.CDLL(str(out/"smartsense.dll"))
    lib.ss_ir_block.argtypes = [ct.POINTER(ct.c_uint16), ct.c_size_t, ct.c_size_t,
                                ct.c_float, ct.POINTER(Measurement)]
    lib.ss_observer_reset.argtypes = [ct.POINTER(Observer)]
    lib.ss_observer_step.argtypes = [ct.POINTER(Observer), ct.c_float, ct.c_float]
    lib.ss_observer_read.argtypes = [ct.POINTER(Observer), ct.POINTER(ct.c_float), ct.POINTER(ct.c_float)]
    lib.ss_detector_reset.argtypes = [ct.POINTER(Detector)]
    lib.ss_detector_calibrate.argtypes = [ct.POINTER(Detector), ct.c_float, ct.c_float, ct.c_float]
    lib.ss_detector_update.argtypes = [ct.POINTER(Detector), ct.POINTER(Measurement), ct.c_uint32]
    lib.ss_detector_status.argtypes = [ct.POINTER(Detector), ct.c_uint32]
    lib.ss_rt_reset.argtypes = [ct.POINTER(Guard),ct.c_uint32]
    lib.ss_rt_begin.argtypes = [ct.POINTER(Guard),ct.c_uint32,ct.c_uint32,ct.c_uint32]
    lib.ss_rt_finish.argtypes = [ct.POINTER(Guard),ct.c_uint32]
    lib.ss_rt_status.argtypes = [ct.POINTER(Guard),ct.c_uint32]
    lib.ss_rt_acquisition_fault.argtypes = [ct.POINTER(Guard)]
    result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(CoreTests))
    elf = (out/"core.arm.o").read_bytes()
    section_offset = struct.unpack_from('<I',elf,32)[0]
    section_size, section_count = struct.unpack_from('<HH',elf,46)
    allocated = sum(struct.unpack_from('<10I',elf,section_offset+i*section_size)[5]
                    for i in range(section_count)
                    if struct.unpack_from('<10I',elf,section_offset+i*section_size)[2]&2)
    stacks = (out/"core.arm.su").read_text().splitlines()
    max_stack = max(int(line.split('\t')[1]) for line in stacks)
    report = {"date":"2026-11-06", "tests_run":result.testsRun, "passed":result.wasSuccessful(),
              "failed":len(result.failures)+len(result.errors), "execution":"Windows x86_64 host",
              "arm_build":"Cortex-M4F hard-float object; not linked or flashed",
              "compiler":subprocess.check_output([str(clang),"--version"],text=True).splitlines()[0],
              "core_c_sha256":hashlib.sha256((root/"core/smartsense.c").read_bytes()).hexdigest(),
              "observer_bytes":ct.sizeof(Observer), "detector_bytes":ct.sizeof(Detector),
              "arm_object_allocated_sections_bytes":allocated,
              "core_max_static_stack_bytes_per_function":max_stack,
              "realtime_guard_bytes":ct.sizeof(Guard),"metrics":metrics}
    (out/"RESULTATS_LOGICIEL.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
    print(json.dumps(report,indent=2))
    raise SystemExit(0 if result.wasSuccessful() else 1)


if __name__ == "__main__":
    main()
