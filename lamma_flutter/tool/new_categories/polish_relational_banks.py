"""Editorial pass over saved drafts, retaining identities and counts."""
import json, random, re, itertools, collections
from pathlib import Path
from relational_authoring import question, GEO, HER, CHEMD, COM, PYD, SPACE, SIF, WEB, LIT
from refine_relational_banks import make_match, SCIENCE, units, products, books, modules
OUT=Path(__file__).parent
R=random.Random(611102026)
documents={c:json.loads((OUT/f'{c}.json').read_text(encoding='utf-8')) for c in ['split_groups','pair_up','relationship']}
catalog=json.loads((OUT/'relational_fact_pools.json').read_text(encoding='utf-8'))
changes=collections.Counter()

def update_answer(q,new):
    old=q['answer'];q['answer']=new
    for option in q['options']:
        if option['text']==old:option['text']=new

natural_frame={
 GEO:'هذه البلدان تقع في منطقتين مختلفتين من تقسيم M49 للأمم المتحدة. كوّن مجموعتين متساويتين وسمّ المنطقة التي تجمع كل مجموعة.',
 HER:'هذه المواقع مدرجة في قائمة التراث العالمي لليونسكو تحت دولتين مختلفتين. كوّن مجموعتين متساويتين بحسب الدولة واذكر اسم كل دولة.',
 CHEMD:'تأتي هذه العناصر من مجموعتين في الجدول الدوري. افصلها إلى مجموعتين متساويتين واذكر رقم كل مجموعة وفق ترقيم IUPAC.',
 COM:'ترتبط المنتجات المعروضة بشركتين مختلفتين. كوّن مجموعتين متساويتين واذكر الشركة المطورة لكل مجموعة.',
 PYD:'أسماء الوحدات المعروضة مأخوذة من قسمين في فهرس مكتبة Python 3.14 القياسية. اجمع وحدات كل قسم معًا وسمّ القسمين.',
 SPACE:'تدور هذه الأقمار حول جرمين مختلفين من المجموعة الشمسية. كوّن مجموعتين متساويتين واذكر الجرم الذي تتبعه كل مجموعة.',
 SIF:'أسماء وحدات في النظام الدولي SI. كوّن مجموعتين متساويتين وفق وضعها في بنية النظام، ثم سمّ الرابط الذي يميز كل مجموعة.',
 WEB:'تؤدي عناصر HTML المعروضة دورين مختلفين في بنية المستند وفق مواصفة WHATWG. كوّن مجموعتين متساويتين وسمّ دور كل مجموعة.',
 LIT:'ألّف هذه الأعمال كاتبان مختلفان. كوّن مجموعتين متساويتين واذكر الكاتب الأصلي لأعمال كل مجموعة.',
}
for q in documents['split_groups']['questions']:
    frame=q['text'].split('السياق: ',1)[1].rstrip('.')
    q['text']=natural_frame[frame]
    changes['split_context']+=1
    if q['difficulty']=='easy' and frame==SIF:
        replacements={'كانديلا':'متر','سيفرت':'نيوتن','كاتال':'جول','هنري':'واط'}
        for section in q['presentation']['sections']:
            for item in section['items']:item['text']=replacements.get(item['text'],item['text'])
        for field in ['answer','explanation']:
            for a,b in replacements.items():q[field]=q[field].replace(a,b)
        for option in q['options']:
            for a,b in replacements.items():option['text']=option['text'].replace(a,b)
        changes['easy_split_units_simplified']+=1

EASY_UNITS={'متر','كيلوغرام','ثانية','أمبير','كلفن','نيوتن','باسكال','جول','واط','فولت','أوم','هرتز'}
EASY_PRODUCTS={'Gmail','Google Drive','Google Meet','Google Calendar','Google Chat','Google Docs','Google Sheets','Google Slides','Google Keep','Google Forms','Google Tasks','Google Sites','Photoshop','Acrobat'}
EASY_BOOKS={'قصة مدينتين','آمال عظيمة','أوليفر تويست','ديفيد كوبرفيلد','كبرياء وتحامل','إيما','هاملت','ماكبث','عطيل','الملك لير','حول العالم في ثمانين يومًا','عشرون ألف فرسخ تحت البحر','رحلة إلى مركز الأرض','مغامرات توم سوير','مغامرات هكلبيري فن','الأمير والفقير','جزيرة الكنز','الدكتور جيكل والسيد هايد','كلب آل باسكرفيل','العالم المفقود','الحرب والسلام','آنا كارينينا','صورة دوريان غراي','دراكولا'}
seen=set()
for q in documents['pair_up']['questions']:
    if q['difficulty']!='easy':
        pairs=[tuple(s.split(' ← ')) for s in q['answer'].split('؛ ')]
        # Catalog pairs retain their original direction even when a displayed
        # task asks for the opposite direction.
        original_left={x['left'] for seq in [SCIENCE,units,products,books,modules] for x in seq}
        seen.add(tuple(sorted(a+'→'+b if a in original_left else b+'→'+a for a,b in pairs)))
labels={'units':'صِل كل وحدة SI بالكمية التي تقيسها.', 'products':'صِل كل منتج بوظيفته الأساسية كما يقدمها مطوره.', 'books':'صِل كل عمل أدبي بمؤلفه الأصلي.', 'science':'صِل كل باحث بالمساهمة التي تذكرها مؤسسة نوبل في تعليل جائزته.', 'modules':'صِل كل وحدة من مكتبة Python 3.14 بوصف وظيفتها الأساسية في دليل اللغة.'}
for index,q in enumerate(documents['pair_up']['questions']):
    num=int(q['id'].rsplit('-',1)[1])
    if q['difficulty']=='easy':
        choice=(num-1)%3
        pool=[x for x in [units,products,books][choice] if x['left'] in [EASY_UNITS,EASY_PRODUCTS,EASY_BOOKS][choice]]
        label=['ربط وحدات SI بالكميات الفيزيائية','ربط المنتجات بوظائفها الأساسية','ربط الأعمال الأدبية بمؤلفيها'][choice]
        # The composition helper has its own direction-invariant guard. The
        # independently checked set of existing tasks remains disjoint by kind.
        q=make_match('easy',num,pool,label,seen)
        documents['pair_up']['questions'][index]=q
        changes['easy_matching_recomposed']+=1
    raw=q['text']
    kind='modules' if 'Python' in raw else 'science' if 'الباحثين' in raw else 'units' if 'وحدات SI' in raw else 'books' if 'الأعمال الأدبية' in raw else 'products'
    reverse=(q['difficulty'] in ('hard','legendary') and num%3==0)
    if reverse:
        text={'modules':'صِل كل وصف وظيفي بالوحدة المناسبة من مكتبة Python 3.14.', 'science':'صِل كل مساهمة بالباحث الذي تُنسب إليه في تعليل جائزته لدى مؤسسة نوبل.', 'books':'صِل كل مؤلف بالعمل الذي كتبه.'}[kind]
    else:text=labels[kind]
    missing=sum(bool(i.get('missing')) for i in q['presentation']['sections'][1]['items'])
    if missing:text+=' استنتج أسماء الأطراف الناقصة مكان «؟»، ثم اذكر الأزواج الثلاثة كاملة. لا يهم ترتيب الخانات الفارغة.'
    else:text+=' اذكر الأزواج الثلاثة كاملة.'
    q['text']=text
    changes['matching_context']+=1

M49=[g for g in catalog if g['domain']==GEO and g['label'] in {'شمال إفريقيا','غرب آسيا','جنوب آسيا','شرق آسيا','غرب أوروبا','جنوب أوروبا','أمريكا الجنوبية','أمريكا الوسطى','شمال أوروبا','شرق أوروبا'}]
country_tasks=[]
for g in M49:
    combos=list(itertools.combinations(g['items'][:5],2));R.shuffle(combos)
    country_tasks.extend((g,p) for p in combos)
R.shuffle(country_tasks)
used_countries=set()
rolemap={x['left']:x for seq in [units,products,books,modules] for x in seq}
for index,q in enumerate(documents['relationship']['questions']):
    tokens=re.findall('«([^»]+)»',q['text'])
    left=tokens[0]
    if q['difficulty']=='easy' and ((left in {x['left'] for x in units} and left not in EASY_UNITS) or (left in {x['left'] for x in products} and left not in EASY_PRODUCTS) or (left in {x['left'] for x in books} and left not in EASY_BOOKS)):
        while country_tasks:
            g,(a,b)=country_tasks.pop();key=frozenset([a,b])
            if key not in used_countries:used_countries.add(key);break
        wrong_groups=R.sample([h for h in M49 if h['label']!=g['label']],5)
        answer=f'تقع «{a}» و«{b}» في {g["label"]} وفق تقسيم M49 للأمم المتحدة'
        wrong=[f'تقع «{a}» و«{b}» في {h["label"]} وفق تقسيم M49 للأمم المتحدة' for h in wrong_groups]
        new=question('relationship','easy',int(q['id'].rsplit('-',1)[1]),f'ما المنطقة الجغرافية التي تجمع «{a}» و«{b}» في تقسيم M49 للأمم المتحدة؟',answer,'حدّد موقع البلدين في الخريطة؛ المطلوب منطقة أضيق من القارة.',f'يصنف الجدول الرسمي للأمم المتحدة {a} و{b} في {g["label"]}. يستند السؤال إلى هذا التقسيم المحدد للمناطق.',[g['source']],wrong)
        documents['relationship']['questions'][index]=new
        changes['advanced_easy_relations_replaced']+=1
        continue
    if 'سجل الجوائز' in q['text']:
        x=next(x for x in SCIENCE if x['left']==left)
        q['text']=f'ما الجائزة التي تربط «{left}» بمساهمته في «{x["right"]}»، وفي أي سنة مُنحت له؟'
        if x['kind']=='Economic Sciences':
            title='جائزة بنك السويد في العلوم الاقتصادية تخليدًا لألفرد نوبل'
        else:
            title='جائزة نوبل في '+{'Physics':'الفيزياء','Chemistry':'الكيمياء','Physiology or Medicine':'الطب أو وظائف الأعضاء'}[x['kind']]
        update_answer(q,f'نال {left} {title} سنة {x["year"]} تقديرًا لهذه المساهمة')
        changes['award_relations_naturalized']+=1
    elif 'الأدبية الأصلية' in q['text']:
        x=rolemap[left]
        update_answer(q,f'{x["right"]} كتب «{left}»')
        q['text']=f'ما الصلة الأدبية بين «{left}» و«{x["right"]}»؟'
        changes['book_relations_naturalized']+=1
    elif 'النظام الدولي للوحدات' in q['text']:
        x=rolemap[left]
        update_answer(q,f'«{left}» وحدة قياس {x["right"]} في النظام الدولي')
        changes['unit_relations_naturalized']+=1
    elif 'دليل المطور' in q['text']:
        x=rolemap[left]
        q['text']=f'ما الصلة بين «{left}» و«{x["right"]}» في تعريف الأداة ووظيفتها الأساسية؟'
        update_answer(q,f'وظيفة «{left}» الأساسية في هذا التعريف هي {x["right"]}')
        changes['tool_relations_naturalized']+=1

for cat,doc in documents.items():
    (OUT/f'{cat}.json').write_text(json.dumps(doc,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(OUT/'relational_polish_changes.json').write_text(json.dumps(dict(changes),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(dict(changes))
