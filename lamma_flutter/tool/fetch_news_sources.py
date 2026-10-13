"""Text-only source snapshots for authoring; no downloaded media."""
import concurrent.futures
import html
import json
import re
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def fetch(item):
    key, url = item
    request = urllib.request.Request(url, headers={'User-Agent':'Mozilla/5.0'})
    with urllib.request.urlopen(request, timeout=35) as response:
        document=response.read().decode('utf-8')
    # Exclude scripts/styles and preserve paragraph text for source reading.
    document=re.sub(r'<(?:script|style)\b[^>]*>.*?</(?:script|style)>','',document,flags=re.S|re.I)
    paragraphs=[]
    for paragraph in re.findall(r'<p\b[^>]*>(.*?)</p>',document,re.S|re.I):
        text=re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]+>','',paragraph))).strip()
        if len(text)>60:
            paragraphs.append(text)
    return dict(key=key,url=url,paragraphs=paragraphs)

def main():
    folder=ROOT/'tool/authoring_news'
    urls=json.loads((folder/'sources.json').read_text(encoding='utf-8'))
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        articles=list(executor.map(fetch,urls.items()))
    (folder/'primary_articles.json').write_text(json.dumps(articles,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(articles=len(articles),paragraphs=sum(len(a['paragraphs']) for a in articles),empty=[a['key'] for a in articles if not a['paragraphs']])))
    assert len(articles)==25

if __name__=='__main__':
    main()
