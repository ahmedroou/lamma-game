import json,re,html,urllib.request,concurrent.futures
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
old=json.loads((ROOT/'tool/staging/notable_arab_sources.json').read_text(encoding='utf8'))
tasks=[{'id':k,'url':f'https://mathshistory.st-andrews.ac.uk/Biographies/{k}/','group':'math'} for k in ['Khayyam','Ibrahim','Al-Banna','Avicenna','Al-Haytham','Yunus','Al-Mahani','Al-Sijzi','Al-Khujandi']]
presidents=['georgewashington','johnadams','thomasjefferson','jamesmadison','jamesmonroe','johnquincyadams','andrewjackson','martinvanburen','williamhenryharrison','johntyler','jameskpolk','zacharytaylor','millardfillmore','franklinpierce','jamesbuchanan','abrahamlincoln','andrewjohnson','ulyssessgrant','rutherfordbhayes','jamesagarfield','chesterarthur','grovercleveland','benjaminharrison','williammckinley','theodoreroosevelt']
tasks += [{'id':k,'url':f'https://obamawhitehouse.archives.gov/1600/presidents/{k}','group':'ruler'} for k in presidents]
tasks += [{'id':k,'url':f'https://www.royal.uk/{k}','group':'ruler'} for k in ['victoria-r-1837-1901','elizabeth-i-r-1558-1603','george-iii-r-1760-1820']]
def fetch(q):
 try:
  b=urllib.request.urlopen(urllib.request.Request(q['url'],headers={'User-Agent':'Mozilla/5.0'}),timeout=30).read().decode()
  b=re.sub(r'<(?:script|style)\b.*?</(?:script|style)>','',b,flags=re.S)
  t=re.sub(r'\s+',' ',html.unescape(re.sub('<[^>]+>',' ',b)))
  if q['group']=='ruler':
   start=t.find('Presidents ');start=t.find('Presidents ',start+1)
   # Keep the entire institutional page so no body facts get lost.
  q['text']=t
 except Exception as e:q['error']=str(e)
 return q
with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:result=list(pool.map(fetch,tasks))
math=[q for q in old if 'text'in q]+[q for q in result if q['group']=='math']
(ROOT/'tool/staging/notable_arab_sources.json').write_text(json.dumps(math,ensure_ascii=False,indent=2),encoding='utf8')
(ROOT/'tool/staging/notable_president_sources.json').write_text(json.dumps([q for q in result if q['group']=='ruler'],ensure_ascii=False,indent=2),encoding='utf8')
print('Math',len(math),'errors',[(q['id'],q['error']) for q in result if 'error'in q])
