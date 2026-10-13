from pathlib import Path
import urllib.request,concurrent.futures,re,json,html
ROOT=Path(__file__).resolve().parents[1]
def fetch(i):
    url=f'https://read.gov/aesop/{i:03}.html'
    raw=urllib.request.urlopen(url,timeout=35).read().decode('utf-8')
    title=html.unescape(re.sub('<[^>]+>','',re.search('<h1[^>]*>(.*?)</h1>',raw,re.S)[1])).strip()
    paragraphs=[html.unescape(re.sub('<[^>]+>','',p)).strip() for p in re.findall('<p[^>]*>(.*?)</p>',raw,re.S)]
    return dict(i=i,url=url,title=title,paragraphs=paragraphs)
if __name__=='__main__':
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:rows=list(pool.map(fetch,range(2,52)))
    (ROOT/'tool/fable_source_readings.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('Fetched',len(rows))
