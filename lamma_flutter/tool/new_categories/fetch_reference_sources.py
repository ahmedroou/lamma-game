from pathlib import Path
import urllib.request, concurrent.futures, hashlib, json, re, html
BASE=Path(__file__).parent/'reference_sources'; BASE.mkdir(exist_ok=True)
URLS=[
'https://www.nasa.gov/reference/appendix-b-vol-2/',
'https://www.nasa.gov/reference/appendix-a-acronyms/',
'https://www.un.org/dgacm/en/content/editorial-manual/abbreviations',
'https://medlineplus.gov/appendixb.html',
'https://www.itu.int/ITU-D/ict/publications/wtdr_99/material/glossary.html',
'https://www.ecb.europa.eu/euro/banknotes/current/design/html/index.en.html',
'https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html',
'https://www.bankofengland.co.uk/banknotes/current-banknotes',
'https://www.bankofengland.co.uk/banknotes/withdrawn-banknotes',
'https://www.uscurrency.gov/denominations',
'https://www.rbnz.govt.nz/money-and-cash/banknotes-and-coins/banknotes-in-circulation',
'https://www.boj.or.jp/en/about/press/koen_2024/ko240703a.htm',
'https://banknotes.rba.gov.au/banknote-features/',
'https://www.bok.or.kr/eng/main/contents.do?menuNo=400112',
'https://www.bipm.org/en/measurement-units/si-prefixes',
]
def fetch(url):
 try:
  r=urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'Mozilla/5.0'}),timeout=40)
  raw=r.read().decode('utf-8',errors='replace')
  raw=re.sub(r'<(script|style)\b[^>]*>.*?</\1>', '', raw, flags=re.S|re.I)
  t=re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]+>',' ',raw))).strip()
  name=hashlib.sha256(url.encode()).hexdigest()[:12]+'.txt'
  (BASE/name).write_text(t,encoding='utf-8')
  return {'url':url,'finalUrl':r.url,'file':name,'status':r.status,'characters':len(t)}
 except Exception as e:return {'url':url,'error':str(e)}
if __name__=='__main__':
 with concurrent.futures.ThreadPoolExecutor(max_workers=8) as ex:results=list(ex.map(fetch,URLS))
 (BASE/'manifest.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8')
 print(json.dumps(results,ensure_ascii=False))
