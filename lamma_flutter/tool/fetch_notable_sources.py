"""Read and cache institutional sources for manual authoring; no question generation."""
import json,urllib.request,re,html,concurrent.futures,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
raw=json.loads((ROOT/'tool/notable_nobel_metadata_source.json').read_text(encoding='utf8'))['laureates']
exclude={
 'Physics':{'rontgen','thomson','planck','einstein','bohr','heisenberg','chadwick','fermi'},
 'Chemistry':{'marie-curie','rutherford','ramsay','haber','sanger','pauling','libby','calvin','hodgkin','zewail','hahn','corey','shechtman','kornberg','ertl','mitchell','klug'},
 'Physiology or Medicine':{'koch','pavlov','fibiger'},
 'Literature':set(), 'Economic Sciences':set(), 'Peace':{'roosevelt'}
}
counts={'Physics':38,'Chemistry':45,'Physiology or Medicine':35,'Literature':50,'Economic Sciences':17,'Peace':10}
pool={k:[] for k in counts}
for q in raw:
 if 'knownName' not in q:continue
 for prize in q.get('nobelPrizes',[]):
  category=prize['category']['en']
  if category in pool and prize['portion']=='1' and int(prize['awardYear'])<=2015 and q['fileName'] not in exclude[category]:
   url=next(x['href'] for x in prize['links'] if x.get('class')==['laureate facts'])
   pool[category].append(dict(id=q['fileName'],name=q['knownName']['en'],category=category,year=prize['awardYear'],url=url,motivation=prize['motivation']['en'],birth=q.get('birth',{}),prize=prize))
selected=[]
for cat,count in counts.items():
 values=sorted(pool[cat],key=lambda x:int(x['year']))[:count]
 assert len(values)==count,(cat,len(values),count)
 selected.extend(values)
assert len(selected)==195
from collections import Counter
slug_counts=Counter(q['id'] for q in selected)
for q in selected:
 q['slug']=q['id']
 if slug_counts[q['id']]>1:q['id']+='-'+q['year']
cache=ROOT/'tool/staging/notable_source_cache';cache.mkdir(parents=True,exist_ok=True)
def fetch(q):
 p=cache/(q['category'].replace(' ','_').replace('/','_')+'_'+q['year']+'_'+q['id']+'.txt')
 legacy=cache/(q['category'].replace(' ','_').replace('/','_')+'_'+q['slug']+'.txt')
 if slug_counts[q['slug']]==1 and legacy.exists() and not p.exists():p.write_bytes(legacy.read_bytes())
 if p.exists():q['sourceText']=p.read_text(encoding='utf8');return q
 try:
  b=urllib.request.urlopen(urllib.request.Request(q['url'],headers={'User-Agent':'Mozilla/5.0'}),timeout=25).read().decode()
  b=re.sub(r'<(?:script|style)\b.*?</(?:script|style)>','',b,flags=re.S)
  t=html.unescape(re.sub('<[^>]+>',' ',b));t=re.sub(r'\s+',' ',t)
  start=t.find('Prize motivation:');end=t.find('To cite this section',start)
  if start<0:raise ValueError('Could not locate source article')
  q['sourceText']=t[max(0,start-350):end if end>start else start+9000]
  p.write_text(q['sourceText'],encoding='utf8')
 except Exception as e:q['error']=str(e)
 return q
with concurrent.futures.ThreadPoolExecutor(max_workers=5) as workers:
 result=list(workers.map(fetch,selected))
(ROOT/'tool/staging/notable_nobel_195_sources.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf8')
print('cached',sum('sourceText' in q for q in result),'errors',[(q['id'],q['error']) for q in result if 'error'in q])
