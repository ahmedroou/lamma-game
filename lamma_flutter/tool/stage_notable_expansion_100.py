"""Publish only staging JSON from 100 manually authored source-backed rows."""
import json,re,hashlib,unicodedata
from pathlib import Path
from collections import Counter
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf8'))
def norm(t):return re.sub(r'\s+',' ',''.join(c for c in t if not unicodedata.combining(c)and c!='ـ')).strip()
def space(t):return re.sub(r'([0-9A-Za-z])(?=[\u0600-\u06ff])',r'\1 ',re.sub(r'([\u0600-\u06ff])(?=[0-9A-Za-z])',r'\1 ',t))
groups={g:[l.split('|')for l in(ROOT/f'tool/notable_expansion_{g}_25.tsv').read_text(encoding='utf8').splitlines()]for g in ['math','writers','science','rulers']}
assert all(len(v)==25 for v in groups.values())
names={r[1]:r[2]for rs in groups.values()for r in rs}
names.update({r.split('|')[0]:r.split('|')[2]for r in (ROOT/'tool/notable_replacements_195.tsv').read_text(encoding='utf8').splitlines()if r.split('|')[0]not in names})
sources={q['id']:q for q in read('tool/staging/notable_nobel_195_sources.json')}
sources.update({q['id']:q for q in read('tool/staging/notable_modern_25_sources.json')})
math={q['id']:q for q in read('tool/staging/notable_arab_sources.json')if'text'in q}
rulers={q['id']:q for q in read('tool/staging/notable_president_sources.json')if'text'in q}
rulers['albert']=rulers['victoria-r-1837-1901']
birth={'Al-Khwarizmi':780,'Al-Kindi':801,'Al-Karaji':953,'Al-Battani':858,'Al-Biruni':973,'Abu_Kamil':850,'Al-Kashi':1380,'Al-Samawal':1130,'Al-Tusi_Nasir':1201,'Al-Tusi_Sharaf':1135,'Abul-Wafa':940,'Thabit':826,'Al-Khazin':900,'Al-Quhi':940,'Al-Qalasadi':1412,'Al-Uqlidisi':920,'Khayyam':1048,'Ibrahim':908,'Al-Banna':1256,'Avicenna':980,'Al-Haytham':965,'Yunus':950,'Al-Mahani':820,'Al-Sijzi':945,'Al-Khujandi':940}
science_peers={
'ashkin':'gabor kastler zernike haroche wineland','arnold':'smith winter bertozzi wuthrich kornberg','bertozzi':'arnold smith winter stoddart feringa','kilby':'guillaume dalen charpak gabor alvarez',
'wuthrich':'ernst fenn tanaka kornberg tiselius','smoot':'mather davis koshiba giacconi appleton','shimomura':'chalfie tsien kornberg winter wuthrich','chalfie':'shimomura tsien kornberg smith winter','tsien':'shimomura chalfie kornberg wuthrich winter','winter':'smith arnold kornberg chalfie wuthrich',
'fenn':'tanaka wuthrich ernst smith kornberg','tanaka':'fenn wuthrich shirakawa shimomura tsien','sauvage':'stoddart feringa langmuir werner bertozzi','stoddart':'sauvage feringa bertozzi staudinger flory','feringa':'sauvage stoddart bertozzi arnold staudinger','smith':'winter arnold chalfie kornberg wuthrich',
'mather':'smoot davis koshiba giacconi appleton','kornberg':'lefkowitz kobilka wuthrich chalfie tsien','lefkowitz':'kobilka kornberg wuthrich winter smith','kobilka':'lefkowitz kornberg winter wuthrich smith','shechtman':'gennes klitzing wilson charpak gabor','davis':'koshiba giacconi mather smoot perrin','koshiba':'davis giacconi mather smoot yukawa','giacconi':'davis koshiba mather smoot appleton','shirakawa':'tanaka shimomura tsien wuthrich feringa'}
# Two additional modern optical researchers are read from the existing official metadata.
names.update(haroche='سيرج أروش',wineland='ديفيد وينلاند')
poets=set('prudhomme carducci kipling tagore heidenstam spitteler yeats karlfeldt mistral eliot jimenez quasimodo perse'.split())
drama=set('maeterlinck hauptmann benavente shaw pirandello oneill'.split())
def genre(k):return 'poetry'if k in poets else'drama'if k in drama else'prose'
old=read('assets/questions/notable_figures.json')['questions']
retained={norm(q['text'])for q in old if q['difficulty']!='legendary'or int(q['id'].rsplit('-',1)[1])<=5}
replacements=read('tool/staging/notable_replacements_195.json')['questions']
seen=retained|{norm(q['text'])for q in replacements};counts=Counter();questions=[];report=[]
for group,rows in groups.items():
 for difficulty,key,answer,text,hint,explanation in rows:
  assert key in names and names[key]==answer
  if group=='math':
   assert key in math;refs=[math[key]['url']+' — MacTutor، جامعة سانت أندروز، السيرة المقروءة.']
   peers=sorted((k for k in birth if k!=key),key=lambda k:abs(birth[k]-birth[key]))[:5]
   if key=='Yunus':refs.append(math['Al-Mahani']['url']+' — بيان نقل أرصاد المهاني في الزيج الحاكمي.')
  elif group in ['science','writers']:
   q=sources[key];refs=[q['url']+' — NobelPrize.org، السيرة والنص المؤسسي المقروء.']
   if group=='science':peers=science_peers[key].split()
   else:
    peers=sorted((k for k in sources if sources[k]['category']=='Literature'and k!=key),key=lambda k:(0 if genre(k)==genre(key) else 30)+abs(int(sources[k]['year'])-int(q['year']))/2)[:5]
   if key=='kilby':refs.append(read('tool/staging/notable_kilby_biography.json')['url']+' — السيرة الذاتية، فقرة فرق الحاسبة والطابعة والطاقة الشمسية.')
  else:
   refs=[rulers[key]['url']+' — السيرة الرسمية المقروءة؛ أرشيف البيت الأبيض أو الموقع الملكي.']
   pres=[r[1]for r in rows[:22]]
   if key in pres:
    ix=pres.index(key);peers=sorted((k for k in pres if k!=key),key=lambda k:abs(pres.index(k)-ix))[:5]
   else:
    peers={'victoria-r-1837-1901':['الملك إدوارد السابع','الملك وليام الرابع','الملك جورج الرابع','الملك جورج الثالث','الملكة آن'],'george-iii-r-1760-1820':['الملك جورج الثاني','الملك جورج الرابع','الملك وليام الرابع','الملك إدوارد السابع','الأمير ألبرت'],'albert':['الملك إدوارد السابع','الملك وليام الرابع','الملك جورج الرابع','الأمير ألبرت فيكتور','الأمير إرنست أوغست']}[key]
  wrong=[names.get(k,k)for k in peers]
  female_writers=['سلمى لاغرلوف','غراتسيا ديليدا','سيغريد أوندست','بيرل باك','غابرييلا ميسترال','توني موريسون']
  if answer in female_writers:wrong=[n for n in female_writers if n!=answer][:5]
  female_scientists=['فرانسيس أرنولد','كارولين بيرتوزي','آدا يوناث','دوروثي كروفوت هودجكن','روزالين يالو','باربرا مكلينتوك']
  if key in ['arnold','bertozzi']:wrong=[n for n in female_scientists if n!=answer][:5]
  if key=='kilby':wrong=[names[k]for k in ['charpak','gabor','alvarez','klitzing','glaser']]
  if key=='sauvage':wrong=[names[k]for k in ['stoddart','feringa','wuthrich','fenn','bertozzi']]
  if key=='stoddart':wrong=[names[k]for k in ['sauvage','feringa','bertozzi','wuthrich','tanaka']]
  if key=='feringa':wrong=[names[k]for k in ['sauvage','stoddart','bertozzi','arnold','fenn']]
  if key in ['mather','smoot','davis','koshiba','giacconi']:wrong=[names[k]for k in ['mather','smoot','davis','koshiba','giacconi']if k!=key]+['آدم ريس']
  if key=='Al-Kashi':wrong=['أولوغ بيك','قاضي زاده الرومي',names['Al-Qalasadi'],names['Al-Banna'],names['Al-Tusi_Nasir']]
  assert len(wrong)==5
  position=len(questions)%6;values=wrong[:];values.insert(position,answer)
  assert len({norm(t)for t in values})==6,key
  assert norm(answer)not in norm(hint),key
  assert norm(text)not in seen,key;seen.add(norm(text))
  counts[difficulty]+=1;identifier=f'notable_figures-{difficulty}-{200+counts[difficulty]:04d}'
  q=dict(id=identifier,categoryId='notable_figures',difficulty=difficulty,text=space(text),answer=answer,acceptedAnswers=[],hint=space(hint),clues=[],explanation=space(explanation),sources=refs,options=[dict(id=chr(65+i),text=v)for i,v in enumerate(values)],correctOptionId=chr(65+position),qualityStatus='unreviewed')
  if group in ['science','writers']:q['acceptedAnswers']=[sources[key]['name']]
  questions.append(q);report.append(identifier+' | '+answer+' | '+'؛ '.join(wrong))
assert len(questions)==100 and counts==dict(easy=25,medium=25,hard=25,legendary=25),counts
p=ROOT/'tool/staging/notable_expansion_100.json';p.write_text(json.dumps(dict(categoryId='notable_figures',questions=questions),ensure_ascii=False,indent=2)+'\n',encoding='utf8')
(ROOT/'tool/staging/notable_expansion_options_review.txt').write_text('\n'.join(report)+'\n',encoding='utf8')
print('STAGED',len(questions),counts,hashlib.sha256(p.read_bytes()).hexdigest())
