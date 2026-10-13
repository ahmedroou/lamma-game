"""Archive primary documents used by the four ordered/numeric draft categories."""
from pathlib import Path
from urllib.request import Request, urlopen
import json, re, html, hashlib
BASE=Path(__file__).parent/'numeric_sources'
URLS={
 'nobel':'https://api.nobelprize.org/2.1/nobelPrizes?limit=1000',
 'quran':'https://tanzil.net/res/text/metadata/quran-data.xml',
 'elements':'https://physics.nist.gov/PhysRefData/Elements/per_noframes.html',
 'planets':'https://nssdc.gsfc.nasa.gov/planetary/factsheet/',
 'planet_sizes':'https://science.nasa.gov/solar-system/planet-sizes-and-locations-in-our-solar-system/',
 'royal':'https://www.royal.uk/kings-and-queens-1066',
 'nobel_physics':'https://www.nobelprize.org/prizes/lists/all-nobel-prizes-in-physics/all/',
 'nobel_chemistry':'https://www.nobelprize.org/prizes/lists/all-nobel-prizes-in-chemistry/all/',
 'nobel_literature':'https://www.nobelprize.org/prizes/lists/all-nobel-prizes-in-literature/all/',
 'nobel_medicine':'https://www.nobelprize.org/prizes/lists/all-nobel-prizes-in-physiology-or-medicine/all/',
 'alice':'https://www.gutenberg.org/cache/epub/11/pg11-images.html',
 'looking_glass':'https://www.gutenberg.org/cache/epub/12/pg12-images.html',
 'sherlock_adventures':'https://www.gutenberg.org/cache/epub/1661/pg1661-images.html',
 'sherlock_memoirs':'https://www.gutenberg.org/cache/epub/834/pg834-images.html',
 'sherlock_return':'https://www.gutenberg.org/cache/epub/108/pg108-images.html',
 'jungle':'https://www.gutenberg.org/cache/epub/236/pg236-images.html',
 'oz':'https://www.gutenberg.org/cache/epub/55/pg55-images.html',
 'stratigraphy':'https://stratigraphy.org/ICSchart/ChronostratChart2024-12.pdf',
 'si':'https://www.bipm.org/documents/20126/41483022/SI-Brochure-9.pdf',
 'si_prefixes':'https://www.bipm.org/en/-/2022-12-19-si-prefixes',
 'osi':'https://www.itu.int/rec/dologin_pub.asp?lang=e&id=T-REC-X.200-199407-I!!PDF-E&type=items',
 'olympics':'https://olympics.com/en/olympic-games',
 'fifa':'https://www.fifa.com/en/tournaments/mens/worldcup',
 'apollo':'https://www.nasa.gov/mission/apollo/',
 'shuttles':'https://www.nasa.gov/space-shuttle/',
 'missions':'https://science.nasa.gov/solar-system/',
 'apollo_history':'https://www.nasa.gov/history/apollo-missions/',
 'spectrum':'https://science.nasa.gov/ems/',
 'constitution':'https://constitution.congress.gov/constitution/',
 'presidents':'https://www.whitehouse.gov/about-the-white-house/presidents/',
 'eu':'https://european-union.europa.eu/principles-countries-history/eu-countries_en',
 'olympic_hosts':'https://olympics.com/ioc/olympic-games',
 'fifa_winners':'https://www.fifa.com/en/articles/world-cup-winners-list',
 'biology':'https://openstax.org/books/biology-2e/pages/20-1-organizing-life-on-earth',
 'ozma':'https://www.gutenberg.org/cache/epub/33361/pg33361-images.html',
 'pinocchio':'https://www.gutenberg.org/cache/epub/500/pg500-images.html',
 'cldr_ar':'https://raw.githubusercontent.com/unicode-org/cldr/release-48/common/main/ar.xml',
 'quran_doc':'https://tanzil.net/docs/Quran_Metadata',
 'planet_notes':'https://nssdc.gsfc.nasa.gov/planetary/factsheet/fact_notes.html',
 'arabic_chart':'https://www.unicode.org/charts/PDF/U0600.pdf',
 'spaceflight':'https://science.nasa.gov/learn/basics-of-space-flight/chapter1-2/',
}
if __name__=='__main__':
 BASE.mkdir(parents=True,exist_ok=True)
 manifest={}
 for key,url in URLS.items():
  existing=BASE/(key+'.raw')
  try:
   data=existing.read_bytes() if existing.exists() else urlopen(Request(url,headers={'User-Agent':'Mozilla/5.0'}),timeout=25).read()
   existing.write_bytes(data)
   text=data.decode('utf-8',errors='replace')
   if not data.startswith(b'%PDF'):
    text=re.sub(r'<(script|style)\b[^>]*>.*?</\1>', '',text,flags=re.S|re.I)
    text=html.unescape(re.sub('<[^>]+>',' ',text))
    text=re.sub(r'\s+',' ',text)
    (BASE/(key+'.txt')).write_text(text,encoding='utf-8')
   manifest[key]={'url':url,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'status':'archived'}
   print(key,len(data))
  except Exception as e:
   manifest[key]={'url':url,'status':'failed','error':str(e)}
   print(key,str(e))
 (BASE/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
