import urllib.request,json,re,html
from html.parser import HTMLParser
from pathlib import Path
class Tables(HTMLParser):
 def __init__(self):super().__init__();self.rows=[];self.cells=None;self.cell=None
 def handle_starttag(self,tag,attrs):
  if tag=='tr':self.cells=[]
  if tag in ('td','th') and self.cells is not None:self.cell=[]
 def handle_data(self,data):
  if self.cell is not None:self.cell.append(data)
 def handle_endtag(self,tag):
  if tag in ('td','th') and self.cell is not None:self.cells.append(' '.join(''.join(self.cell).split()));self.cell=None
  if tag=='tr' and self.cells is not None:
   if self.cells:self.rows.append(self.cells)
   self.cells=None
urls={'medical':'https://medlineplus.gov/appendixb.html','nasa':'https://www.nasa.gov/reference/appendix-b-vol-2/','un':'https://www.un.org/dgacm/en/content/editorial-manual/abbreviations'}
out=Path(__file__).parent/'reference_sources'
if __name__=='__main__':
 result={}
 for name,url in urls.items():
  raw=urllib.request.urlopen(url,timeout=35).read().decode()
  parser=Tables();parser.feed(raw);result[name]=parser.rows
  print(name,json.dumps(parser.rows,ensure_ascii=True))
 (out/'abbreviation_tables.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
 rfc=urllib.request.urlopen('https://www.rfc-editor.org/rfc/rfc4949.txt',timeout=35).read().decode()
 (out/'rfc4949.txt').write_text(rfc,encoding='utf-8')
