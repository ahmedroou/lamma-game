"""Rebuild and validate the three owned staging files; no production writes."""
import revise_reference_abbreviations
import revise_reference_symbols
import reference_currency_completion
from author_reference_categories import *
import hashlib,re

# Match each literal glyph's source chart instead of citing Mathematical Operators for ASCII.
for q in BOOKS['symbols_signals']:
 if 'imageAsset' in q:continue
 s=q['presentation']['sections'][0]['items'][0]['text']
 if len(s)==1:
  n=ord(s)
  chart=None
  for lo,hi,name in [(0,127,'U0000'),(128,255,'U0080'),(0x2000,0x206f,'U2000'),(0x2100,0x214f,'U2100'),(0x2190,0x21ff,'U2190'),(0x2200,0x22ff,'U2200'),(0x2300,0x23ff,'U2300'),(0x25a0,0x25ff,'U25A0'),(0x2600,0x26ff,'U2600'),(0x1d100,0x1d1ff,'U1D100')]:
   if lo<=n<=hi:chart=name
  if chart and 'unicode' in q['sources'][0]:q['sources']=['https://www.unicode.org/charts/PDF/'+chart+'.pdf']
 if 'التحليل الرياضي؛ اقرأ التعبير كاملًا' in q['text']:
  q['sources'].append('قراءة رمزية أصلية؛ التحقق باستبدال الرموز بتعريفاتها ومراعاة مجالات المتغيرات وترتيب تركيب الدوال.')
  if '∇' in s:q['sources'].append('https://openstax.org/books/calculus-volume-3/pages/6-5-divergence-and-curl')
  if s in ['A×B','A⊆B','A∩B=∅','A∖B','x∈A∩B','x∈A∪B']:q['text']='في نظرية المجموعات، A وB مجموعتان وx عنصر؛ ما قراءة التعبير المعروض كاملة؟'
  if s=='P(A∣B)':q['text']='في الاحتمالات، A وB حدثان وP رمز الاحتمال، مع P(B)>0؛ ما قراءة التعبير المعروض؟'
  if s=='f⁻¹(B)':q['text']='لدالة f منX إلىY ولمجموعةB جزئية منY، ما معنى التعبير المعروض وفق ترميز نظرية المجموعات؟'
  if s=='∣x∣':q['text']='في التحليل الرياضي، x عدد حقيقي؛ ما معنى التعبير المعروض؟'
  if s=='∥v∥':q['text']='في الجبر الخطي، v متجه؛ ما معنى التعبير المعروض في سياق قياس طوله؟'
 if s=='FS':q['presentation']['sections'][0]['items'][0]['text']='F Sta'
 if s=='Lib':q['presentation']['sections'][0]['items'][0]['text']='Liby'
 if s=='𝄂':q['answer']='خط مازورة ختامي';q['explanation']='الخط الختامي للموسيقى يتكون من خط رفيع وخط سميك وينهي القطعة أو قسمًا منها.';next(o for o in q['options'] if o['id']==q['correctOptionId'])['text']=q['answer']

# Curated families of near mathematical readings, rather than distant roots vs. integrals.
mathfamilies={
 '+':['الجمع','الطرح','الضرب','القسمة','رفع عدد إلى قوة','أخذ الجذر'],
 '−':['الطرح','الجمع','الضرب','القسمة','باقي القسمة','القيمة المطلقة'],
 '×':['الضرب','الجمع','الطرح','القسمة','رفع عدد إلى قوة','باقي القسمة'],
 '÷':['القسمة','الضرب','الطرح','الجمع','أخذ الجذر','القيمة المطلقة'],
 '=':['المساواة','عدم المساواة','يساوي تقريبًا','تطابق أو مساواة هوية','التناسب','أكبر من'],
 '≠':['عدم المساواة','المساواة','يساوي تقريبًا','التناسب','عدم التقريب','التطابق'],
 '<':['أصغر من','أكبر من','أصغر من أو يساوي','أكبر من أو يساوي','يساوي تقريبًا','عدم المساواة'],
 '>':['أكبر من','أصغر من','أكبر من أو يساوي','أصغر من أو يساوي','يساوي تقريبًا','عدم المساواة'],
 '≤':['أصغر من أو يساوي','أصغر من','أكبر من أو يساوي','أكبر من','المساواة','عدم المساواة'],
 '≥':['أكبر من أو يساوي','أكبر من','أصغر من أو يساوي','أصغر من','المساواة','عدم المساواة'],
 '≈':['يساوي تقريبًا','المساواة','عدم المساواة','التناسب','أصغر بكثير من','أكبر بكثير من'],
 '≔':['تعريف الطرف الأيسر بالطرف الأيمن','تعريف الطرف الأيمن بالطرف الأيسر','مساواة عددية تقريبية','شرط عدم مساواة الطرفين','مساواة بترديد عدد صحيح','تناسب مباشر بين الطرفين'],
 '∈':['ينتمي إلى','لا ينتمي إلى','كل عناصر الطرف الأيسر في الأيمن','كل عناصر الطرف الأيمن في الأيسر','المجموعتان متساويتان','المجموعتان متباينتان'],
 '∉':['لا ينتمي إلى','ينتمي إلى','كل عناصر الطرف الأيسر في الأيمن','كل عناصر الطرف الأيمن في الأيسر','المجموعتان متساويتان','المجموعتان متداخلتان'],
 '∀':['لكل','يوجد','لا يوجد','يوجد واحد فقط','ليس لكل','يوجد عدد منتهٍ من'],
 '∃':['يوجد','لكل','لا يوجد','يوجد واحد فقط','ليس لكل','لكل ما عدا واحدًا'],
 '∄':['لا يوجد','يوجد','لكل','يوجد واحد فقط','ليس لكل','يوجد عدد منتهٍ من'],
 '∧':['و المنطقية','أو المنطقية الشاملة','أو الحصرية','النفي المنطقي','استلزام دلالي','قضية صادقة دائمًا'],
 '∨':['أو المنطقية الشاملة','أو الحصرية','و المنطقية','النفي المنطقي','قضية صادقة دائمًا','قضية كاذبة دائمًا'],
 '⊻':['أو الحصرية','أو المنطقية الشاملة','و المنطقية','النفي المنطقي','نفي الاقتران','نفي الفصل'],
 '∪':['اتحاد مجموعتين','تقاطع مجموعتين','فرق مجموعتين','فرق متناظر لمجموعتين','حاصل ضرب ديكارتي','المجموعة الخالية'],
 '∩':['تقاطع مجموعتين','اتحاد مجموعتين','فرق مجموعتين','فرق متناظر لمجموعتين','حاصل ضرب ديكارتي','مجموعة القوى'],
 '∖':['فرق مجموعتين','فرق متناظر لمجموعتين','اتحاد مجموعتين','تقاطع مجموعتين','حاصل ضرب ديكارتي','مجموعة القوى'],
}
for q in BOOKS['symbols_signals']:
 s=q['presentation']['sections'][0]['items'][0]['text']
 if s in mathfamilies:
  pool=mathfamilies[s].copy();RNG.shuffle(pool)
  q['options']=[{'id':chr(65+i),'text':v} for i,v in enumerate(pool)]
  q['correctOptionId']=next(o['id'] for o in q['options'] if o['text']==q['answer'])

# Plain visual alt text describes the figure, never its interpretation.
for q in BOOKS['symbols_signals']:
 if 'imageAsset' not in q:continue
 key=Path(q['imageAsset']).stem.removeprefix('new_symbols_')
 if key.startswith('wash'):desc='حوض بخط سطح متموج'+(' وعليه تقاطع' if key=='wash_no' else ' وداخله'+key.split('_')[1].split('-')[0]+'، وتحته'+key.rsplit('-',1)[1]+' خطوط')
 elif key.startswith('bleach'):desc='مثلث بإطار أسود'+({'bleach_all':' فارغ','bleach_oxygen':' وداخله خطان مائلان','bleach_no':' وعليه خطان متقاطعان'}[key])
 elif key.startswith('tumble'):desc='مربع داخله دائرة'+({'tumble_low':' ونقطة واحدة','tumble_normal':' ونقطتان','tumble_no':' وعليه خطان متقاطعان'}[key])
 elif key.startswith('dry'):desc='مربع داخله'+('خط أو خطان عموديان' if 'line' in key else 'خط أو خطان أفقيان')+(' وخط مائل في الزاوية العليا' if 'shade' in key else '')
 elif key.startswith('iron'):desc='شكل مكواة بإطار أسود'+(' وعليه تقاطع' if key=='iron_no' else ' وبداخله'+key.split('_')[1]+' نقط')
 elif key.startswith('clean'):desc='دائرة'+(' وعليها تقاطع' if 'none' in key else ' يتوسطها الحرف'+key.split('_')[1].split('-')[0])+'؛ الخطوط السفلية تظهر كما في الرسم'
 elif key.startswith('warn'):desc='مثلث أبيض بإطار أحمر، بداخله الرسم الأسود المعروض'+(' وثلاث دوائر ملونة رأسية' if 'traffic_lights' in key else '')
 elif key in ['resistor','capacitor','inductor','cell','lamp','variable','potentiometer','polarized','diode','led','photodiode','npn','pnp','spdt']:
  desc={
   'resistor':'مستطيل أفقي فارغ يتصل بخط أفقي من كل جانب',
   'capacitor':'خطّان عموديان متساويان ومتوازيان تفصلهما فجوة، متصلان بخطين أفقيين',
   'inductor':'سلسلة أقواس صغيرة تتصل بخط أفقي من كل طرف',
   'cell':'خطّان عموديان متوازيان، أحدهما أطول من الآخر، متصلان بخطين أفقيين',
   'lamp':'دائرة سوداء فارغة، داخلها خطّان متقاطعان، ومتصل بها خطان أفقيان',
   'variable':'مستطيل أفقي له طرفان أفقيان، يعبره سهم مائل',
   'potentiometer':'مستطيل أفقي يتصل بخطين أفقيين؛ يتصل أعلى المستطيل بسهم رأسي منفصل',
   'polarized':'لوح مستقيم ولوح منحني متقابلان مع علامة زائد قرب اللوح المستقيم',
   'diode':'مثلث فارغ رأسه نحو اليمين، عند الرأس خط عمودي، متصل بخطين أفقيين',
   'led':'مثلث وخط عمودي مع طرفين أفقيين وسهمين صغيرين يتجهان بعيدًا عن الشكل',
   'photodiode':'مثلث وخط عمودي مع طرفين أفقيين وسهمين صغيرين يتجهان نحو الشكل',
   'npn':'خط رأسي يتصل بثلاثة فروع؛ السهم على الفرع السفلي متجه بعيدًا عن الخط الرأسي',
   'pnp':'خط رأسي يتصل بثلاثة فروع؛ السهم على الفرع السفلي متجه نحو الخط الرأسي',
   'spdt':'طرف على اليسار يتصل بذراع مائل نحو أحد طرفين أفقيين منفصلين على اليمين'}[key]
 elif key=='stop':desc='شكل أحمر ثماني الأضلاع يحمل كلمةSTOP باللون الأبيض'
 elif key=='give_way':desc='مثلث مقلوب أبيض بإطار أحمر، داخلهGIVE WAY'
 elif key=='one_way':desc='مستطيل أزرق داخله سهم أبيض إلى الأعلى'
 elif key=='national_limit':desc='دائرة بيضاء يعبرها شريط أسود مائل'
 elif key in ['minimum','maximum']:desc='دائرة'+(' زرقاء' if key=='minimum' else ' بيضاء بإطار أحمر')+'، داخلها الرقم30'
 else:desc='لوحة دائرية ملونة، تتضمن الخطوط أو الأسهم أو الأشكال الموضحة في الرسم'
 q['imageDescription']=desc
 if key in ['npn','pnp']:q['sources']=['https://learn.sparkfun.com/tutorials/transistors/all']
 if key in ['diode','led','photodiode']:q['sources']=['https://learn.sparkfun.com/tutorials/diodes/all']
 if key=='cell':q['sources']=['https://learn.sparkfun.com/tutorials/how-to-read-a-schematic/all.pdf']
 if key=='lamp':q['sources']=['https://www.learningaboutelectronics.com/Articles/Lamp-schematic-symbol.php']

# Additional primary documentation for the first-series €500 architectural style.
for q in BOOKS['currency_stories']:
 if 'ورقة500 يورو' in q['text']:q['sources']=['https://www.ecb.europa.eu/press/key/date/2004/html/sp040811.es.html']
 if q['hint'].startswith('ختلفت'):q['hint']='ا'+q['hint']
 for old_event,date in [
  ('بداية طرح الإصدار السادس الورقي والمعدني السعودي','26 ديسمبر2016'),
  ('طرح5 ريالات السعودية البوليمر لأول مرة','28 سبتمبر2020'),
  ('إضافة200 ريال إلى الإصدار السادس السعودي','4 يناير2021'),
  ('أول طرح100 و50 ريالًا في الإصدار الخامس السعودي','21 مايو2007'),
  ('أول طرح10 و5 ريالات في الإصدار الخامس السعودي','16 يوليو2007')]:
  if old_event in q['text']:
   q['text']=q['text'].replace('في أي سنة ميلادية حدث','ما التاريخ الميلادي الذي حدث فيه')
   q['answer']=date
   pool=['26 ديسمبر2016','28 سبتمبر2020','4 يناير2021','21 مايو2007','16 يوليو2007','17 سبتمبر2007']
   RNG.shuffle(pool);q['options']=[{'id':chr(65+i),'text':v} for i,v in enumerate(pool)]
   q['correctOptionId']=next(o['id'] for o in q['options'] if o['text']==date)
   q['explanation']=f'يسجل البنك المركزي السعودي تاريخ الحدث المحدد في السؤال: {date}. يميز اليوم والشهر بين دفعات طرحت في السنة نفسها.'
for q in BOOKS['abbreviations']:
 if 'الاختصار UNODC' in q['text']:
  q['sources']=['https://www.un.org/dgacm/en/content/editorial-manual/abbreviations','https://sherloc.unodc.org/cld/ar/education/tertiary/organized-crime/module-14/key-issues/unodc.html']

# Equal placement over the whole category, 12 or 13 of each letter in each difficulty.
patterns=[[0,1,2],[3,4,5],[0,2,4],[1,3,5]]
for cat,qs in BOOKS.items():
 assert len(qs)==300,cat
 for di,diff in enumerate(DIFFS):
  group=[q for q in qs if q['difficulty']==diff]
  assert len(group)==75,(cat,diff,len(group))
  positions=list(range(6))*12+patterns[di];RNG.shuffle(positions)
  for q,pos in zip(group,positions):
   wrong=[o['text'] for o in q['options'] if o['text']!=q['answer']]
   assert len(wrong)==5;RNG.shuffle(wrong);wrong.insert(pos,q['answer'])
   q['options']=[{'id':chr(65+i),'text':v} for i,v in enumerate(wrong)]
   q['correctOptionId']=chr(65+pos)
for cat,qs in BOOKS.items():
 for q in qs:
  for field in ['text','answer','hint','explanation','imageDescription']:
   if field in q:q[field]=re.sub(r'([\u0600-\u06ff])([A-Za-z0-9])',r'\1 \2',re.sub(r'([A-Za-z0-9])([\u0600-\u06ff])',r'\1 \2',q[field]))
  for option in q['options']:
   option['text']=re.sub(r'([\u0600-\u06ff])([A-Za-z0-9])',r'\1 \2',re.sub(r'([A-Za-z0-9])([\u0600-\u06ff])',r'\1 \2',option['text']))
media=OUT/'media/manifest.json'
manifest=json.loads(media.read_text(encoding='utf-8'))
for entry in manifest:
 q=next(q for q in BOOKS['symbols_signals'] if q.get('imageAsset','').endswith(entry['name']))
 entry['source']=q['sources'][0]
media.write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
save()
print('All 900 staged records pass exact counts and structural checks; qualityStatus remains unreviewed.')
