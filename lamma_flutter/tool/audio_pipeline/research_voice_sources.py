"""Cache public Commons file metadata for individual source research; never approve audio."""
import concurrent.futures
import html
import json
import pathlib
import re
import urllib.parse
import urllib.request
import urllib.error
import time

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / 'design_sources/character_voice_repair/research-20261015'
OUT.mkdir(exist_ok=True)

def api(**params):
    query = urllib.parse.urlencode({'action':'query','format':'json', **params})
    request = urllib.request.Request('https://commons.wikimedia.org/w/api.php?' + query,
                                    headers={'User-Agent':'LammaVoiceSourceResearch/1.0'})
    for attempt in range(5):
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                return json.load(response)
        except urllib.error.HTTPError as error:
            if error.code not in (429,502,503) or attempt == 4: raise
            delay=max(float(error.headers.get('Retry-After','15')),15*(attempt+1))
            print('Source API backoff',delay,flush=True)
            time.sleep(delay)

def category(name):
    results, continuation = [], {}
    while True:
        data = api(list='categorymembers', cmtitle='Category:' + name,
                   cmlimit=500, cmtype='file', **continuation)
        results.extend(entry['title'] for entry in data['query']['categorymembers'])
        if 'continue' not in data:
            return results
        continuation = data['continue']

def plain(value):
    return html.unescape(re.sub('<[^>]+>', ' ', value or '')).strip()

def metadata(titles):
    data = api(titles='|'.join(titles),prop='imageinfo',iiprop='url|size|extmetadata|sha1',iiextmetadatalanguage='en')
    return [p for p in data['query']['pages'].values() if 'imageinfo' in p]

def main():
    titles = set()
    for name in ['Voice intro project - en', 'Voice intro project - ar',
                 'Voice intro project - fr','Voice intro project - de',
                 'Audio files of speeches in English','BBC voice samples']:
        found = category(name)
        print(name, len(found), flush=True)
        titles.update(found)
    batches = [sorted(titles)[i:i+30] for i in range(0,len(titles),30)]
    pages=[]
    for titles in batches:
        pages.extend(metadata(titles))
        print('Metadata',len(pages),flush=True)
        time.sleep(3)
    (OUT/'commons-candidates.json').write_text(json.dumps(pages,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    lines=[]
    for page in sorted(pages,key=lambda p:p['title']):
        i=page['imageinfo'][0]; e=i.get('extmetadata',{})
        lines.append(page['title']+' | '+str(i.get('size'))+' | '+plain(e.get('LicenseShortName',{}).get('value'))+' | '+plain(e.get('ImageDescription',{}).get('value'))[:700])
    (OUT/'candidate-index.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print('Saved', len(pages), 'source records; no media approved.',flush=True)

if __name__=='__main__': main()
