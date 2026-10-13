from pathlib import Path
import xml.etree.ElementTree as E
import re,html,json
import pypdf
from fetch_numeric_sources import URLS
p=Path(__file__).parent/'numeric_sources'
r=E.parse(p/'cldr_ar.raw')
for c in ['gregorian','islamic']:
 print(c,[(x.get('type'),x.text) for x in r.findall(f'./dates/calendars/calendar[@type="{c}"]/months/monthContext[@type="format"]/monthWidth[@type="wide"]/month')])
t=html.unescape(re.sub('<[^>]+>',' ',(p/'planet_notes.raw').read_text(encoding='utf-8')))
t=re.sub(r'\s+',' ',t)
(p/'planet_notes.txt').write_text(t,encoding='utf-8')
print(t[:6500])
pdf='\n'.join(x.extract_text() for x in pypdf.PdfReader(p/'arabic_chart.raw').pages)
(p/'arabic_chart.txt').write_text(pdf,encoding='utf-8')
print(pdf[:6500])
manifest=json.loads((p/'manifest.json').read_text(encoding='utf-8'))
import hashlib
for key in ['cldr_ar','quran_doc','planet_notes','arabic_chart']:
 data=(p/(key+'.raw')).read_bytes()
 manifest[key]={'url':URLS[key],'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'status':'archived'}
(p/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
