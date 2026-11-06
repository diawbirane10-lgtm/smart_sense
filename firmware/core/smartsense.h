#ifndef SMARTSENSE_H
#define SMARTSENSE_H
#include <stdint.h>
#include <stddef.h>

#if defined(_WIN32) && defined(SS_TEST_EXPORTS)
#define SS_API __declspec(dllexport)
#else
#define SS_API
#endif

/* Fixed contract: 200 ksample/s, 10 kHz IR, coherent 20-sample periods. */
enum { SS_VALID = 0, SS_CLIPPED = 1, SS_BAD_INPUT = 2 };
enum {
    SS_UNCALIBRATED = 0, SS_SETTLING = 1, SS_CLEAR = 2,
    SS_LOW_SIGNAL = 3, SS_SATURATED = 4, SS_INVALID = 5, SS_STALE = 6
};
typedef struct { float amplitude_v, offset_v, residual_rms_v; int quality; } ss_measurement;
typedef struct { float x[3]; uint32_t samples; } ss_observer;
typedef struct {
    float threshold_low_v, threshold_high_v;
    uint32_t last_ms, seen, calibrated, candidate_count;
    int state, candidate;
} ss_detector;
enum {
    SS_RT_OK = 0, SS_RT_WAITING = 1, SS_RT_STALE = 2, SS_RT_SEQUENCE = 3,
    SS_RT_LOSS = 4, SS_RT_CADENCE = 5, SS_RT_LATE = 6, SS_RT_DEADLINE = 7,
    SS_RT_API_ERROR = 8, SS_RT_ACQUISITION = 9
};
typedef struct {
    uint32_t last_block, last_completed_us, last_valid_us, started_us;
    uint32_t have_sequence, have_valid, pending, lost_blocks;
    int fault;
} ss_rt_guard;

/* Count is the number of IR samples, not the number of interleaved words.
   Caller owns at least (count-1)*stride+1 uint16_t words, no concurrent DMA writes.
   vref is the ADC reference supply estimate, not the analogue 1.65 V bias. */
SS_API int ss_ir_block(const uint16_t *adc, size_t count, size_t stride,
                       float vref, ss_measurement *out);
SS_API void ss_observer_reset(ss_observer *o);
SS_API int ss_observer_step(ss_observer *o, float adc_volts, float vref);
/* Returns 1 after 2000 valid samples (10 ms), otherwise 0. */
SS_API int ss_observer_read(const ss_observer *o, float *amplitude_v, float *offset_v);
SS_API void ss_detector_reset(ss_detector *d);
/* sigma_v: repeatability std of block amplitudes from a real calibration run. */
SS_API int ss_detector_calibrate(ss_detector *d, float clear_v, float blocked_v, float sigma_v);
SS_API int ss_detector_update(ss_detector *d, const ss_measurement *m, uint32_t sample_ms);
SS_API int ss_detector_status(ss_detector *d, uint32_t now_ms);
/* Timestamps are from one monotonic microsecond clock, modulo 2^32.
   DMA halves contain 400 IR samples = 2ms. Publish only after finish==OK. */
SS_API void ss_rt_reset(ss_rt_guard *g, uint32_t now_us);
SS_API int ss_rt_begin(ss_rt_guard *g, uint32_t block_id, uint32_t completed_us, uint32_t now_us);
SS_API int ss_rt_finish(ss_rt_guard *g, uint32_t now_us);
SS_API int ss_rt_status(ss_rt_guard *g, uint32_t now_us);
SS_API void ss_rt_acquisition_fault(ss_rt_guard *g);
#endif
