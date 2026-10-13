"""Compile manually authored replacement facts and coherent, real-name choices."""
import json,hashlib,re,unicodedata
from pathlib import Path
from collections import Counter
ROOT=Path(__file__).resolve().parents[1]
def norm(t):return re.sub(r'\s+',' ',''.join(c for c in t if not unicodedata.combining(c) and c!='ـ')).strip()
def space(t):
 t=re.sub(r'([\u0600-\u06ff])(?=[0-9A-Za-z])',r'\1 ',t)
 t=re.sub(r'([0-9A-Za-z])(?=[\u0600-\u06ff])',r'\1 ',t)
 return t
def main():
 sources={q['id']:q for q in json.loads((ROOT/'tool/staging/notable_nobel_195_sources.json').read_text(encoding='utf8'))}
 extra={q['id']:q for q in json.loads((ROOT/'tool/staging/notable_extra_biographies.json').read_text(encoding='utf8'))}
 rows=[l.split('|') for l in (ROOT/'tool/notable_replacements_195.tsv').read_text(encoding='utf8').splitlines()]
 assert len(rows)==195 and len({r[0] for r in rows})==195
 names={r[0]:r[2] for r in rows}
 biological=set(extra)
 fact_life={'waals','onnes','millikan','hoff','fischer-1902','arrhenius','einthoven'}
 old=json.loads((ROOT/'assets/questions/notable_figures.json').read_text(encoding='utf8'))['questions']
 retained={norm(q['text']) for q in old if q['difficulty']!='legendary' or int(q['id'].rsplit('-',1)[1])<=5}
 new=[];choices_report=[]
 poets=set('prudhomme carducci kipling tagore heidenstam spitteler yeats karlfeldt mistral eliot jimenez quasimodo perse'.split())
 drama=set('maeterlinck hauptmann benavente shaw pirandello oneill'.split())
 def genre(k):return 'poetry' if k in poets else 'drama' if k in drama else 'prose'
 def lang(q):
  m=re.search(r'Language: (.*?) Prize (?:share|motivation):',q['sourceText']);return m.group(1) if m else ''
 for i,(key,text,answer,hint,explanation) in enumerate(rows):
  q=sources[key];cat=q['category'];year=int(q['year']);language=lang(q)
  def score(other):
   oy=int(other['year']);ol=lang(other)
   return (0 if not language or ol==language else 12)+(0 if cat!='Literature' or genre(key)==genre(other['id']) else 30)+abs(oy-year)/2
  peers=sorted((v for v in sources.values() if v['category']==cat and v['id']!=key),key=score)[:5]
  assert len(peers)==5
  wrong=[names[v['id']] for v in peers]
  female_writers=['سلمى لاغرلوف','غراتسيا ديليدا','سيغريد أوندست','بيرل باك','غابرييلا ميسترال','توني موريسون']
  if answer in female_writers:wrong=[n for n in female_writers if n!=answer][:5]
  # Every alternative is an actual person in the same discipline and neighbouring era.
  position=i%6;vals=wrong[:];vals.insert(position,answer)
  assert len({norm(x) for x in vals})==6,key
  assert norm(answer) not in norm(hint),key
  assert norm(text) not in retained,key
  refs=[q['url']+' — NobelPrize.org، النص المؤسسي الأصلي المقروء.']
  if key in biological:refs.append(extra[key]['url']+' — السيرة الأصلية المقروءة؛ استعملت واقعة تختلف عن السؤال القديم.')
  if key=='mcclintock':refs.append('https://pmc.ncbi.nlm.nih.gov/articles/1076098/ — بحث Creighton وMcClintock، PNAS1931، العنوان والمؤلفان والإحالة قرئت.')
  new.append(dict(id=f'notable_figures-legendary-{i+6:04d}',categoryId='notable_figures',difficulty='legendary',text=space(text),answer=answer,
                  acceptedAnswers=[q['name']],hint=space(hint),clues=[],explanation=space(explanation),sources=refs,
                  options=[dict(id=chr(65+j),text=x) for j,x in enumerate(vals)],correctOptionId=chr(65+position),qualityStatus='unreviewed'))
  choices_report.append(f'{i+6:04d} | {answer} | '+ '؛ '.join(wrong))
 out=ROOT/'tool/staging/notable_replacements_195.json';out.write_text(json.dumps(dict(categoryId='notable_figures',questions=new),ensure_ascii=False,indent=2)+'\n',encoding='utf8')
 (ROOT/'tool/staging/notable_replacements_options_review.txt').write_text('\n'.join(choices_report)+'\n',encoding='utf8')
 print('STAGED',len(new),hashlib.sha256(out.read_bytes()).hexdigest())
if __name__=='__main__':main()
