"""Fetch text-only primary fable pages for authoring; no media is downloaded."""
import concurrent.futures
import html
import json
import re
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'tool/authoring_myths'

def fetch(number):
    url = f'https://www.read.gov/aesop/{number:03}.html'
    request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(request, timeout=30) as response:
        document = response.read().decode('utf-8')
    def text(value):
        return re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]+>', '', value))).strip()
    heading = re.search(r'<h1[^>]*>(.*?)</h1>', document, re.S)
    paragraphs = [text(p) for p in re.findall(r'<p[^>]*>(.*?)</p>', document, re.S)]
    return dict(number=number, url=url, title=text(heading.group(1)), paragraphs=[p for p in paragraphs if p])

def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    # The Library's 1919 Aesop for Children text. Each selected page is distinct.
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        pages = list(executor.map(fetch, range(2, 102)))
    (OUTPUT / 'primary_pages.json').write_text(json.dumps(pages, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(dict(pages=len(pages), words=sum(len(' '.join(p['paragraphs']).split()) for p in pages))))

if __name__ == '__main__':
    main()
