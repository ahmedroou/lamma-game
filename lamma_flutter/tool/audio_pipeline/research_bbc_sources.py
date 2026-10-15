"""Fetch metadata for BBC's explicitly released voice samples, without approval."""
import json,time
from research_voice_sources import category,metadata,OUT,plain

titles=[]
for name in ['BBC voice samples of female people','BBC voice samples of males']:
    titles.extend(category(name))
pages=[]
for i in range(0,len(titles),30):
    pages.extend(metadata(titles[i:i+30]))
    (OUT/'bbc-candidates.json').write_text(json.dumps(pages,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('BBC metadata',len(pages),flush=True)
    time.sleep(5)
lines=[]
for page in pages:
    info=page['imageinfo'][0]; e=info.get('extmetadata',{})
    lines.append(page['title']+' | '+plain(e.get('LicenseShortName',{}).get('value'))+' | '+plain(e.get('ImageDescription',{}).get('value'))[:900])
(OUT/'bbc-index.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')
