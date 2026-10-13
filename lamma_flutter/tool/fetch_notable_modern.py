import json,urllib.request,re,html,concurrent.futures
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
raw=json.loads((ROOT/'tool/notable_nobel_metadata_source.json').read_text(encoding='utf8'))['laureates']
keys='fenn tanaka wuthrich mather smoot ashkin arnold smith winter sauvage stoddart feringa shimomura chalfie tsien kornberg lefkowitz kobilka shechtman davis koshiba giacconi kilby shirakawa bertozzi'.split()
selected=[]
for k in keys:
 q=next(q for q in raw if q['fileName']==k and (k not in ['smith','kornberg'] or any(p['awardYear']=={'smith':'2018','kornberg':'2006'}[k] for p in q['nobelPrizes'])));p=q['nobelPrizes'][-1]
 selected.append(dict(id=k,name=q['knownName']['en'],category=p['category']['en'],year=p['awardYear'],url=next(x['href']for x in p['links']if x.get('class')==['laureate facts'])))
def fetch(q):
 b=urllib.request.urlopen(urllib.request.Request(q['url'],headers={'User-Agent':'Mozilla/5.0'}),timeout=30).read().decode();b=re.sub(r'<(?:script|style)\b.*?</(?:script|style)>','',b,flags=re.S)
 t=re.sub(r'\s+',' ',html.unescape(re.sub('<[^>]+>',' ',b)));start=t.find('Prize motivation:');end=t.find('To cite this section',start)
 q['sourceText']=t[max(0,start-350):end];return q
with concurrent.futures.ThreadPoolExecutor(max_workers=5) as p:result=list(p.map(fetch,selected))
(ROOT/'tool/staging/notable_modern_25_sources.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf8')
for q in result:print(q['id'],q['sourceText'][q['sourceText'].find('Life '):])
