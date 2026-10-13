import collections,json,re,sys
from pathlib import Path
from write_batch import ROOT,publish,question,normalized
sys.stdout.reconfigure(encoding='utf-8')
SOURCES={'USGS':('https://www.usgs.gov/glossary/volcano-hazards-program-glossary','USGS، معجم برنامج أخطار البراكين'),
 'GENOME':('https://www.genome.gov/sites/default/files/media/files/2022-05/NHGRI-Talking-Glossary.pdf','NHGRI، Talking Glossary of Genomic and Genetic Terms (2022)')}
rows=[];heading=None
def readable(value):
 value=re.sub(r'([A-Za-z0-9])(?=[\u0600-\u06ff])',r'\1 ',value)
 return re.sub(r'([\u0600-\u06ff])(?=[A-Za-z0-9])',r'\1 ',value)
for file in sorted(Path(__file__).parent.glob('who_*.txt')):
 for line in file.read_text(encoding='utf8').splitlines():
  if not line or line.startswith('#'):continue
  if line.startswith('@'):
   difficulty,mode,source,pool=line[1:].split('|');heading=(difficulty,mode,source,[readable(x) for x in pool.split(';')])
   assert len(heading[3])==6,line
  else:
   fields=[readable(x) for x in line.split('~')];assert len(fields)==6,line
   rows.append((heading,fields))
counters=collections.Counter();out=[]
for (difficulty,mode,source,pool),(answer,c1,c2,c3,hint,reference) in rows:
 counters[(difficulty,mode)]+=1
 if mode=='replace':number=(100 if difficulty=='hard' else 0)+counters[(difficulty,mode)]
 else:number=200+counters[(difficulty,mode)]
 assert answer in pool,answer
 assert len({normalized(c1),normalized(c2),normalized(c3)})==3
 assert not any(normalized(answer) in normalized(c) for c in (c1,c2,c3)),answer
 url,title=SOURCES.get(source,(source,'مرجع موثق مقروء'))
 if source.startswith('UNESCO'):
  url=f'https://whc.unesco.org/en/list/{source[6:]}/'
  title='UNESCO، مركز التراث العالمي، وصف الموقع والقيمة العالمية الاستثنائية'
 if source.startswith('PHY'):
  volume,chapter=source[3:].split('.')
  url=f'https://openstax.org/books/university-physics-volume-{volume}/pages/{chapter}-key-terms'
  title=f'OpenStax، University Physics Volume {volume}، مصطلحات الفصل {chapter}'
 explanation=f'الهوية هي «{answer}»: '+c1+' '+c2+' '+c3+f' تدعم مادة {reference} القرائن الثلاث، والبدائل لا تجمعها كلها.'
 if source.startswith('PHY'):
  explanation=f'الهوية «{answer}». القرينة المحددة هنا: {c3} يعرّف المرجع هذا المفهوم، وتكمل القرينتان السابقتان سياقه.'
 distractors=[x for x in pool if x!=answer]
 if answer=='التكرار المترادف':distractors[distractors.index('السواتل الدقيقة')]='التكرار المبعثر'
 if answer=='السواتل الدقيقة':distractors[distractors.index('التكرار المترادف')]='التكرار الساتلي الكبير'
 if answer=='البلازميد':distractors[distractors.index('الناقل الجيني')]='الناقل الفيروسي'
 if answer=='الصفة متعددة الجينات':distractors[distractors.index('النمط الظاهري')]='الصفة أحادية الجين'
 if answer=='RNA الرسول':distractors[distractors.index('RNA')]='DNA المتمم'
 if answer=='RNA الناقل':distractors[distractors.index('RNA')]='DNA المتمم'
 if answer=='RNA الريبوسومي':distractors[distractors.index('RNA')]='DNA المتمم'
 if answer=='أفق الحدث':distractors[distractors.index('نصف قطر شوارزشيلد')]='الأوج المداري'
 if answer=='طفرة عديمة المعنى':distractors[distractors.index('طفرة انزياح الإطار')]='الطفرة الصامتة'
 if answer=='الفسيفسائية الوراثية':distractors[distractors.index('اختلال الصيغة الصبغية')]='تعدد الأشكال الوراثية'
 if answer=='الإدخال الجيني':distractors[distractors.index('التضاعف الجيني')]='فقدان تغاير الزيجوت'
 if answer=='التضاعف الجيني':distractors[distractors.index('الإدخال الجيني')]='التحويل الجيني'
 if answer=='الثوران البخاري':distractors[distractors.index('الانفجار الحراري المائي')]='انهيار جدار الفوهة'
 if answer=='الانفجار الحراري المائي':distractors[distractors.index('الثوران البخاري')]='انهيار جدار الفوهة'
 if answer=='النمط الظاهري':distractors[distractors.index('الصفة متعددة الجينات')]='الاستعداد الوراثي'
 if answer=='علم الجينومات':
  distractors[distractors.index('الميتاجينوميات')]='علم البروتيومات'
  distractors[distractors.index('جينوميات السكان')]='علم النسخ الشامل'
 if answer in ('الميتاجينوميات','جينوميات السكان'):
  distractors[distractors.index('علم الجينومات')]='علم البروتيومات'
 if answer in ('الكروموديناميكا الكمومية','الديناميكا الكهربائية الكمومية'):
  distractors[distractors.index('النموذج المعياري')]='النسبية الخاصة'
  distractors[distractors.index('نظرية التوحيد الكبرى')]='ميكانيكا المصفوفات'
 refname=reference.split('،')[0]
 aliases=[refname] if re.fullmatch('[A-Za-z -]+',refname) else []
 if source.startswith('https://www.nigms.nih.gov/'):
  aliases={'النواة الخلوية':['Nucleus'],'الميتوكوندريا':['Mitochondria'],
   'جهاز غولجي':['Golgi apparatus'],'الجسيم الحال':['Lysosome'],
   'الشبكة الإندوبلازمية الخشنة':['Rough endoplasmic reticulum'],
   'الشبكة الإندوبلازمية الملساء':['Smooth endoplasmic reticulum']}[answer]
 aliases+= {'الحلبة الجليدية':['الحوض الجليدي','الدائرة الجليدية'],
  'القضاعة':['ثعلب الماء'],'وحيد القرن':['الكركدن'],
  'الفلامنغو':['النحام'],'المدرع':['الأرماديلو'],
  'السطح الكروي':['سطح الكرة'],'السطح الحلقي ذو الثقب الواحد':['التورس','السطح الحلقي'],
  'القطع الناقص غير الدائري':['القطع الناقص','الشكل البيضاوي'],
  'الأسطوانة الدائرية القائمة':['الأسطوانة'],'المخروط الدائري القائم':['المخروط'],
  'رباعي الوجوه المنتظم':['الهرم الثلاثي المنتظم'],
  'جيش التيراكوتا':['محاربو التيراكوتا','جيش الطين'],
  'ماتشو بيتشو':['ماشو بيتشو'],'جزيرة القيامة':['جزيرة الفصح','رابا نوي'],
  'دار أوبرا سيدني':['أوبرا سيدني'],'قصر فرساي':['قصر فيرساي'],
  'شلالات إيغوازو':['إغواسو'],'RNA الرسول':['mRNA'],
  'RNA الناقل':['tRNA'],'RNA الريبوسومي':['rRNA'],
  'DNA المتمم':['cDNA'],'التسلسل العشوائي':['تسلسل الشوتغن'],
  'ميدان نقش جهان':['ميدان الإمام في أصفهان']}.get(answer,[])
 sources=[f'{title}، مادة {reference}: {url}']
 if answer=='فقدان تغاير الزيجوت':
  sources.append('Massive interstitial copy-neutral loss-of-heterozygosity as evidence for cancer being a disease of the DNA-damage response (2015)، ملخص الدراسة الأصلي: https://pubmed.ncbi.nlm.nih.gov/26208496/')
 out.append(question('who_am_i',difficulty,number,'من أنا؟',answer,distractors,hint,explanation,sources,clues=[c1,c2,c3],aliases=aliases))
assert counters.get(('hard','replace'),0)<=100 and counters.get(('legendary','replace'),0)<=200
assert all(n<=25 for (d,m),n in counters.items() if m=='add')
Path(__file__).with_name('who_authored.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
publish('who_am_i',out)
print(dict(counters))
