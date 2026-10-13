from fetch_reference_sources import fetch,BASE
import concurrent.futures,json
URLS=['https://www.un.org/ar/about-us/un-system','https://www.un.org/ar/about-us/funds-programmes-specialized-agencies-and-others','https://www.un.org/ar/about-us/specialized-agencies','https://www.un.org/ar/about-us/un-system-directory','https://www.kuna.net.kw/Pages/History.aspx?Language=ar','https://www.qna.org.qa/ar-QA/About-QNA','https://www.wam.ae/ar/about-us','https://www.spa.gov.sa/ar/']
if __name__=='__main__':
 with concurrent.futures.ThreadPoolExecutor(max_workers=8) as ex:r=list(ex.map(fetch,URLS))
 (BASE/'arabic_manifest.json').write_text(json.dumps(r,ensure_ascii=False,indent=2),encoding='utf-8')
 for v in r:
  print(v)
  if 'file' in v:print((BASE/v['file']).read_text(encoding='utf-8')[-15000:])
