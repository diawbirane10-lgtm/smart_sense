"""Run with KiCad's bundled Python; export values/pins for revue_rd.m.

python verifier_kicad.py --project path/to/SmartSense_V1.kicad_pro
Read-only on the design. Writes JSON evidence beside this script.
"""
from pathlib import Path
import argparse,hashlib,json,subprocess,sys,tempfile,xml.etree.ElementTree as ET
import pcbnew

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--project',type=Path,required=True)
    args=parser.parse_args()
    project=args.project.resolve();out=Path(__file__).resolve().parent
    cli=Path(sys.executable).parent/'kicad-cli.exe'
    if not cli.is_file():raise RuntimeError('Use the Python supplied with KiCad on Windows')
    sch=project.with_suffix('.kicad_sch');pcb=project.with_suffix('.kicad_pcb')
    for command,source,destination in [('sch',sch,'ERC_FINAL.json'),('pcb',pcb,'DRC_FINAL.json')]:
        cmd=[str(cli),command,'erc' if command=='sch' else 'drc','--format','json','--severity-all','--exit-code-violations','-o',str(out/destination)]
        if command=='pcb':cmd+=['--schematic-parity']
        subprocess.run(cmd+[str(source)],check=True,timeout=120,cwd=project.parent)
    with tempfile.TemporaryDirectory(prefix='smartsense_netlist_') as temporary:
        xml=Path(temporary)/'netlist.xml'
        subprocess.run([str(cli),'sch','export','netlist','--format','kicadxml','-o',str(xml),str(sch)],check=True,timeout=120,cwd=project.parent)
        netlist=ET.parse(xml).getroot()
    board=pcbnew.LoadBoard(str(pcb));footprints={fp.GetReference():fp for fp in board.GetFootprints()}
    expected={(p.get('ref'),p.get('pin')):n.get('name') for n in netlist.findall('./nets/net') for p in n.findall('node')}
    actual={(ref,p.GetNumber()):p.GetNetname() for ref,fp in footprints.items() for p in fp.Pads() if p.GetNumber()}
    mismatches=[{'ref':r,'pin':p,'expected':n,'actual':actual.get((r,p))} for (r,p),n in expected.items() if r in footprints and actual.get((r,p))!=n]
    components={c.get('ref'):{'value':c.findtext('value'),'pins':{p:n for (r,p),n in expected.items() if r==c.get('ref')}} for c in netlist.findall('./components/comp')}
    tracks=[t for t in board.GetTracks() if not isinstance(t,pcbnew.PCB_VIA)]
    vias=[t for t in board.GetTracks() if isinstance(t,pcbnew.PCB_VIA)]
    routing={n:{'length_mm':sum(pcbnew.ToMM(t.GetLength()) for t in tracks if t.GetNetname()==n),'vias':sum(v.GetNetname()==n for v in vias)} for n in ['PD_SUM','V_TIA','ADC_PHOTO','ADC_US','+5V','+5V_HMI']}
    report={'source':'KiCad native Python and fresh CLI netlist','kicad':pcbnew.GetBuildVersion(),'layers':board.GetCopperLayerCount(),'footprints':len(footprints),'pin_net_checked':sum(r in footprints for r,p in expected),'mismatches':mismatches,'components':components,'sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(project.parent.glob('*.kicad_sch'))}|{pcb.name:hashlib.sha256(pcb.read_bytes()).hexdigest()},'status':'Design evidence only; no physical validation or certification'}
    report.update(tracks=len(tracks),vias=len(vias),critical_routing=routing)
    (out/'AUDIT_NATIF.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    assert not mismatches,mismatches
    print(json.dumps({k:report[k] for k in ['kicad','layers','footprints','pin_net_checked','mismatches']}))

if __name__=='__main__':main()
