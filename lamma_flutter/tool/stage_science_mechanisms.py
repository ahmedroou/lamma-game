"""Stage final stable-ID qualitative questions without touching live assets."""
from pathlib import Path
from collections import Counter
import json,random,re,hashlib
from rebuild_science_puzzles import ROOT,problem,SCI_EASY,SCI_SOURCES,LEVELS
from science_mechanism_catalog import CATALOG
from science_mechanism_clarifications import TEXT,WRONG,OMIT

PHYS='https://openstax.org/books/college-physics-2e/pages/'
CHEM='https://openstax.org/books/chemistry-2e/pages/'
SOURCE=dict(SCI_SOURCES)
SOURCE.update({
'phase':PHYS+'13-5-phase-changes',
'torque':PHYS+'9-6-forces-and-torques-in-muscles-and-joints',
'motor':PHYS+'22-8-torque-on-a-current-loop-motors-and-meters',
'induction':PHYS+'23-2-faradays-law-of-induction-lenzs-law',
'electrostatic':PHYS+'18-8-applications-of-electrostatics',
'lens':PHYS+'25-6-image-formation-by-lenses',
'polarization':PHYS+'27-8-polarization',
'interference':PHYS+'27-3-youngs-double-slit-experiment',
'sound':PHYS+'17-2-speed-of-sound-frequency-and-wavelength',
'waves':PHYS+'16-9-waves',
'heatpump':'https://betterbuildingssolutioncenter.energy.gov/resources/heat-pump-rtu-switchover-temperature-guidance',
'engine':PHYS+'15-3-introduction-to-the-second-law-of-thermodynamics-heat-engines-and-their-efficiency',
'wind':'https://www.energy.gov/cmei/systems/how-do-wind-turbines-work',
'hydropower':'https://www.eia.gov/kids/energy-sources/hydropower/',
'solarcell':'https://www.energy.gov/cmei/systems/solar-photovoltaic-cell-basics',
'solarthermal':'https://www.energystar.gov/products/solar_water_heaters/how-it-works',
'fuelcell':'https://www.energy.gov/cmei/fuels/fuel-cell-animation-text-version',
'nuclear':'https://www.energy.gov/ne/articles/nuclear-101-how-does-nuclear-reactor-work',
'electrochem':CHEM+'17-2-galvanic-cells',
'battery':'https://ntrs.nasa.gov/api/citations/20220004129/downloads/AiChE%20Presentation%20v2.pdf',
'additive':'https://www.nist.gov/additive-manufacturing/research-areas/technologies',
'inkjet':'https://hp.globalbmg.com/download/getfileupload?downloadId=0838B331-4BCA-4E3A-B2CE-54744A237B10',
'osmosis':CHEM+'11-4-colligative-properties',
'filtration':'https://www.cdc.gov/infection-control/hcp/environmental-control/water.html',
'centrifuge':PHYS+'6-3-centripetal-force',
'chromatography':'https://edu.rsc.org/resources/chromatography/11333.article',
'magneticforce':PHYS+'22-4-magnetic-field-strength-force-on-a-moving-charge-in-a-magnetic-field',
'spectroscopy':'https://edu.rsc.org/resources/ultraviolet/visible-spectroscopy/1300.article',
'ultrasound':'https://www.nibib.nih.gov/science-education/science-topics/ultrasound',
'ct':'https://www.nibib.nih.gov/science-education/science-topics/computed-tomography-ct',
'mri':'https://www.nibib.nih.gov/science-education/science-topics/magnetic-resonance-imaging-mri',
'fluorescence':PHYS+'30-5-applications-of-atomic-excitations-and-de-excitations',
'laser':PHYS+'30-5-applications-of-atomic-excitations-and-de-excitations',
'radiationdetect':PHYS+'31-2-radiation-detection-and-detectors',
'photoelectric':PHYS+'29-2-the-photoelectric-effect',
'angular':PHYS+'10-7-gyroscopic-effects-vector-aspects-of-angular-momentum',
'sha':'https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf',
'aes':'https://csrc.nist.gov/pubs/fips/197/final',
})
for _,key,_ in CATALOG:
    if key.startswith('rfc'):SOURCE[key]='https://datatracker.ietf.org/doc/html/'+key

def candidates():
    # Difficulty pools preserve the IDs' approved tiers. Parts requiring
    # specialised knowledge or system interactions are mostly later tiers.
    rows=[]
    for ui,(name,key,parts) in enumerate(CATALOG):
        for pi,(part,answer,hint) in enumerate(parts):
            if (name,part) in OMIT:continue
            if pi in [0,1]:text=f'في «{name}»، كيف يؤدي «{part}» دوره في المنظومة؟'
            elif pi in [2,3]:text=f'ما الآلية التي تفسّر أثر «{part}» في «{name}»؟'
            else:
                events=('زيادة','انعدام','زوال','تساوي','فقد','ازدياد','تقليل','قطع','خفض','وصول','تغيير','بطء','تراكم','عودة','فتح','تحريك','سحب','استرجاع','تعاقب','تكرار','ارتفاع','إغلاق','تشكل','توافق','انتقال','ضغط','نقل','وجود','عدم','حفظ','عكس','توزيع','فصل','تحويل','احتفاظ','إضافة')
                if part.startswith(events):text=f'ما الأثر المباشر لـ«{part}» في «{name}»؟'
                else:text=f'في «{name}»، ما الوظيفة المحددة لـ«{part}»؟'
            text=TEXT.get((name,part),text)
            wrong=WRONG.get((name,part),[r for j,(_,r,_) in enumerate(parts) if j!=pi])
            assert len(set([answer,*wrong]))==6
            q=problem(text,answer,wrong,hint,
                f'دور «{part}» في هذا النظام هو: {answer}. '+hint,
                [f'المرجع الأساسي للآلية: {SOURCE[key]}'])
            q.pop('_proof',None)
            rows.append((ui,pi,q))
    # One mechanism occurs only once. Interleave systems within each tier.
    chosen={'medium':[],'hard':[],'legendary':[]}
    for ui,pi,q in rows:
        tier='medium' if pi<2 else 'hard' if pi<4 else 'legendary'
        chosen[tier].append((ui,pi,q))
    # Existing quarantined IDs require174/225/224, not a new tier balance.
    transfer=chosen['medium'][174:]
    chosen['medium']=chosen['medium'][:174]
    chosen['hard']+=transfer[:15];chosen['legendary']+=transfer[15:30]
    chosen['hard']=chosen['hard'][:225];chosen['legendary']=chosen['legendary'][:224]
    for level in chosen:
        rng=random.Random('qualitative:'+level);rng.shuffle(chosen[level])
        chosen[level]=[q for _,_,q in chosen[level]]
    assert {k:len(v) for k,v in chosen.items()}=={'medium':174,'hard':225,'legendary':224}
    chosen['easy']=[problem(t,a,w.split('|'),h,e,[SCI_SOURCES[s]]) for t,a,w,h,e,s in SCI_EASY]
    for q in chosen['easy']:q.pop('_proof',None)
    return chosen

def main():
    staged=ROOT/'tool/staging';staged.mkdir(exist_ok=True)
    base=ROOT/'tool/authoring_final_science_puzzles/how_it_works.json'
    bank=json.loads(base.read_text(encoding='utf-8'))
    original=set(json.loads((ROOT/'tool/reasoning_original_ids.json').read_text(encoding='utf-8')))
    pools=candidates();changes=[]
    for level in LEVELS:
        ids=sorted(q['id'] for q in bank['questions'] if q['difficulty']==level and (q['id'] in original or int(q['id'].split('-')[-1])>200))
        assert len(ids)==len(pools[level]),(level,len(ids),len(pools[level]))
        replacements={qid:dict(id=qid,categoryId='how_it_works',difficulty=level,**q) for qid,q in zip(ids,pools[level])}
        for i,q in enumerate(bank['questions']):
            if q['id'] in replacements:bank['questions'][i]=replacements[q['id']];changes.append(q['id'])
    for q in bank['questions']:
        if q['id']!='how_it_works-legendary-0074':q['qualityStatus']='unreviewed'
        q.pop('qualityReasons',None)
    bank.update(targetCount=900,targetPerDifficulty=225,status='draft')
    path=staged/'how_it_works.json';path.write_text(json.dumps(bank,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (staged/'how_it_works_changes.json').write_text(json.dumps(changes,indent=2)+'\n',encoding='utf-8')
    sha=hashlib.sha256(path.read_bytes()).hexdigest();print('Staged qualitative science:',len(changes),'changes;',len(bank['questions']),'total; sha256',sha)
    print('105 systems /623 specific qualitative mechanisms plus25 easy questions; no physical-network calculations retained.')
if __name__=='__main__':main()
