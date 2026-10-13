"""Replace provisional membership-only matching/relations with precise links.

The initial IDs are retained; authoring source snapshots are outside assets.
No record is editorially certified by this program.
"""
import json, itertools, random, collections
from pathlib import Path
from relational_authoring import question, groups, LIT, HER, SPACE
from relational_direct_data import science_pairs, UNITS, MODULES, PRODUCT_ROLES
OUT=Path(__file__).parent
R=random.Random(91372026)

SCIENCE=science_pairs()
CATEGORY_AR={'Physics':'الفيزياء','Chemistry':'الكيمياء','Physiology or Medicine':'الطب أو وظائف الأعضاء','Economic Sciences':'العلوم الاقتصادية'}
UNIT_SOURCE='https://www.bipm.org/en/publications/si-brochure'
MODULE_SOURCE='https://docs.python.org/3.14/library/index.html'
GOOGLE='https://workspace.google.com/'
ADOBE='https://www.adobe.com/products/catalog.html'
units=[dict(left=a,right=b,source=UNIT_SOURCE,kind='units') for a,b in (x.split('|') for x in UNITS.splitlines())]
modules=[dict(left=a,right=b,source=MODULE_SOURCE,kind='modules') for a,b in (x.split('|') for x in MODULES.splitlines())]
products=[dict(left=a,right=b,source=GOOGLE if a.startswith('Google ') or a=='Gmail' else ADOBE,kind='products') for a,b in (x.split('|') for x in PRODUCT_ROLES.splitlines())]
books=[dict(left=book,right=g['label'],source=g['source'],kind='books') for g in groups if g['domain']==LIT for book in g['items']]

def shuffle(x):
    x=x.copy();R.shuffle(x);return x

def make_match(diff,num,pool,label,seen):
    for _ in range(2000):
        triples=R.sample(pool,3)
        if len({x['left'] for x in triples})<3 or len({x['right'] for x in triples})<3:continue
        key=tuple(sorted(x['left']+'→'+x['right'] for x in triples))
        if key not in seen:break
    else:raise ValueError(('matching supply exhausted',diff,label))
    seen.add(key)
    # Reverse some tasks to let descriptions evoke names, rather than testing
    # only recollection of unfamiliar names. Both directions preserve full pairs.
    reverse=diff in ('hard','legendary') and num%3==0
    left=[x['right'] if reverse else x['left'] for x in triples]
    right=[x['left'] if reverse else x['right'] for x in triples]
    answer='؛ '.join(f'{a} ← {b}' for a,b in zip(left,right))
    wrong=['؛ '.join(f'{a} ← {b}' for a,b in zip(left,p)) for p in itertools.permutations(right) if list(p)!=right]
    order=R.choice([[1,2,0],[2,0,1]])
    missing_count=(num-1)%4
    missing=set(R.sample(range(3),missing_count))
    ri=[dict(id=f'r{i+1}',text='؟',missing=True) if i in missing else dict(id=f'r{i+1}',text=right[k]) for i,k in enumerate(order)]
    presentation=dict(type='matching',sections=[dict(id='left',title='الأطراف الأولى',items=[dict(id=f'l{i+1}',text=t) for i,t in enumerate(left)]),dict(id='right',title='الأطراف المقابلة',items=ri)])
    text=f'كوّن الأزواج الثلاثة كاملة في {label}. كل طرف يقابل طرفًا واحدًا وفق العلاقة الدقيقة المذكورة.'
    if missing_count:text+=' استنتج أسماء الأطراف المحذوفة عند «؟»؛ يكفي ذكر الأزواج ولا يُشترط ترتيب الخانات الفارغة.'
    hints={
      'units':'ابدأ بالكمية التي تميزها أبعادها؛ فرّق بين الطاقة والقدرة وبين الفيض وكثافته.',
      'modules':'فكّر في الناتج المحدد لكل مهمة؛ تمثيل البيانات يختلف عن نقلها أو ضغطها.',
      'products':'حدد نوع المستند أو الوسيط الذي ينشئه المنتج أساسًا، لا ميزة جانبية فيه.',
      'books':'تجاهل مدينة الأحداث؛ قارن نسب العمل إلى صاحبه الأصلي.',
      'science':'قارن طبيعة الإنجاز: أداة رصد أم ظاهرة أم نظرية؛ لا تفترض أن كل مساهمة اكتشاف منفرد.',
    }
    kind=triples[0]['kind'] if triples[0]['kind'] in hints else 'science'
    if kind in ('modules','products'):
        text+=' اعتمد الوصف التعريفي الأساسي في دليل الجهة المطورة؛ إمكان استعمال أداة عامة بصورة غير مباشرة لا يكفي للمطابقة.'
    ex='الأزواج الصحيحة: '+answer+'. '
    if kind=='science':ex+='يربط مرجع نوبل كل اسم بهذه المساهمة في تعليل الجائزة؛ النسب لا تدعي أن العالم أنجز العمل منفردًا.'
    elif kind=='units':ex+='هذه كميات SI التي تقابل أسماء الوحدات في الجداول الرسمية. تبديل الكميات يغيّر البعد أو المعنى الفيزيائي.'
    elif kind=='modules':ex+='تعريف كل وحدة في فهرس المكتبة يحدد وظيفتها المقصودة هنا؛ الأوصاف تخص الوظيفة المذكورة ولا تزعم حصر كل إمكانات الوحدة.'
    elif kind=='products':ex+='تذكر صفحات المنتجات الرسمية هذه الوظائف الأساسية؛ قد توجد ميزات إضافية لكنها لا تغير هذه المطابقة المحددة.'
    else:ex+='فهارس الطبعات تنسب كل عمل إلى المؤلف المذكور، بصرف النظر عن المترجم أو أعمال الاقتباس.'
    return question('pair_up',diff,num,text,answer,hints[kind],ex,[x['source'] for x in triples],wrong,presentation)

def relation_science(diff,num,x):
    # Keep exact award year and award category in the relation. This is an
    # institutional attribution, not a potentially contested priority claim.
    cat=CATEGORY_AR[x['kind']]
    award='جائزة نوبل' if x['kind']!='Economic Sciences' else 'جائزة بنك السويد في العلوم الاقتصادية تخليدًا لألفرد نوبل'
    answer=f'هذه مساهمة وردت في تعليل منح {x["left"]} {award} في {cat} سنة {x["year"]}'
    year=int(x['year'])
    alternatives=[]
    # Adjacent dates and adjacent subject labels form five complete, false
    # institutional attributions, not claims about general fields of interest.
    othercats=[c for k,c in CATEGORY_AR.items() if k!=x['kind']]
    for yr,c in [(year-1,cat),(year+1,cat),(year,othercats[0]),(year,othercats[1]),(year+2,cat)]:
        alternatives.append(f'هذه مساهمة وردت في تعليل منح {x["left"]} {award} في {c} سنة {yr}')
    text=f'ما الصلة الرسمية المحددة بين «{x["left"]}» و«{x["right"]}» في سجل الجوائز، مع ذكر المجال والسنة؟'
    explanation=f'يسجل مصدر نوبل هذه المساهمة في تعليل جائزة {cat} سنة {year}. يشمل التعليل العمل المذكور ولا يلزم منه أن المساهمة اكتشاف منفرد أو أن كل تفاصيل أبحاثه محصورة فيه.'
    return question('relationship',diff,num,text,answer,'قد يكون تخصص الباحث أوسع من مجال الجائزة؛ ثبّت صلة العمل بتعليل الجائزة وزمنها.',explanation,[x['source']],alternatives)

def relation_role(diff,num,x,pool,kind):
    if kind=='books':
        answer=f'«{x["right"]}» هو المؤلف الأصلي لعمل «{x["left"]}»'
        choices=['هو مترجم هذا العمل إلى العربية','هو شخصية داخل هذا العمل','هو مخرج الاقتباس السينمائي الأول لهذا العمل','هو ناشر الطبعة الأولى من هذا العمل','هو صاحب الرواية التي اقتبس منها هذا العمل']
        wrong=[f'«{x["right"]}» {v}' for v in choices]
        hint='ميّز الاسم خارج النص من الاسم الذي يعيش داخله، ولا تفترض أن اقتباسًا سينمائيًا هو الأصل.'
        text=f'ما العلاقة الأدبية الأصلية بين «{x["left"]}» و«{x["right"]}»؟'
        ex=f'ينسب فهرس النص «{x["left"]}» إلى {x["right"]} بصفة المؤلف. المطلوب النسب الأدبي؛ الترجمة والاقتباس وظائف مختلفة.'
    elif kind=='units':
        answer=f'«{x["left"]}» وحدة SI لقياس {x["right"]}'
        others=shuffle([z for z in pool if z['right']!=x['right']])[:5]
        wrong=[f'«{x["left"]}» وحدة SI لقياس {z["right"]}' for z in others]
        hint='ركّز على البعد الفيزيائي للكمية، ولا تخلط المعدل بالقيمة الكلية.'
        text=f'كيف يرتبط «{x["left"]}» بـ«{x["right"]}» في النظام الدولي للوحدات؟'
        ex=f'في جدول SI تُقاس {x["right"]} بوحدة {x["left"]}. الوحدات قد تتساوى شكليًا في كتابة الأبعاد أحيانًا لكن السياق يميز الكميات المقصودة.'
    else:
        stem='تعريفها الأساسي في دليل المطور هو' if kind=='modules' else 'يقدمها مطورها أساسًا لغرض'
        answer=f'«{x["left"]}» {stem} {x["right"]}'
        others=shuffle([z for z in pool if z['right']!=x['right']])[:5]
        wrong=[f'«{x["left"]}» {stem} {z["right"]}' for z in others]
        hint='فكّر في نوع الناتج ومدى المهمة، لا في الاسم التجاري أو قصر الاسم البرمجي.'
        text=f'ما الصلة التعريفية الأساسية بين «{x["left"]}» ومهمة «{x["right"]}» بحسب دليل المطور، دون تعميم إلى كل ما يمكن تنفيذه بوسائل غير مباشرة؟'
        ex=f'يوثق المرجع هذه المهمة ضمن وظيفة {x["left"]}: {x["right"]}. المطلوب الوظيفة المحددة وليس القول إنه يؤدي كل مهمة معالجة ممكنة.'
    return question('relationship',diff,num,text,answer,hint,ex,[x['source']],wrong)

def save(cat,qs):
    data=json.loads((OUT/f'{cat}.json').read_text(encoding='utf-8'))
    data['questions']=qs
    (OUT/f'{cat}.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

def build():
    science=shuffle(SCIENCE);bookorder=shuffle(books);unitorder=shuffle(units);productorder=shuffle(products);moduleorder=shuffle(modules)
    assert len(science)==135,len(science)
    slices={
      'easy':[(unitorder,'units'),(productorder,'products'),(bookorder[:29],'books')],
      'medium':[(science[:40],'science'),(bookorder[29:64],'books')],
      'hard':[(science[40:85],'science'),(moduleorder[:30],'modules')],
      'legendary':[(science[85:135],'science'),(moduleorder[30:55],'modules')],
    }
    relations=[]
    for diff,parts in slices.items():
        batch=[]
        for seq,kind in parts:
            for x in seq:
                num=len(batch)+1
                batch.append(relation_science(diff,num,x) if kind=='science' else relation_role(diff,num,x,books if kind=='books' else units if kind=='units' else products if kind=='products' else modules,kind))
        assert len(batch)==75,(diff,len(batch));relations.extend(batch)
    save('relationship',relations)
    settings={
      'easy':[(units,'ربط وحدات SI بالكميات الفيزيائية'),(products,'ربط المنتجات بوظائفها الأساسية'),(books,'ربط الأعمال الأدبية بمؤلفيها')],
      'medium':[(SCIENCE,'ربط الباحثين بالمساهمات التي تذكرها تعليلات جوائزهم'),(units,'ربط وحدات SI بالكميات الفيزيائية'),(books,'ربط الأعمال الأدبية بمؤلفيها')],
      'hard':[(SCIENCE,'ربط الباحثين بالمساهمات التي تذكرها تعليلات جوائزهم'),(modules,'ربط وحدات Python 3.14 القياسية بوظائفها'),(books,'ربط الأعمال الأدبية بمؤلفيها')],
      'legendary':[(SCIENCE,'ربط الباحثين بالمساهمات التي تذكرها تعليلات جوائزهم'),(modules,'ربط وحدات Python 3.14 القياسية بوظائفها')],
    }
    matches=[];seen=set()
    for diff,parts in settings.items():
        for num in range(1,76):
            pool,label=parts[(num-1)%len(parts)]
            matches.append(make_match(diff,num,pool,label,seen))
        save('pair_up',matches)
    manifest=dict(science=SCIENCE,units=units,modules=modules,products=products,books=books)
    (OUT/'relational_direct_facts.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(dict(pair_up=len(matches),relationship=len(relations)))

if __name__=='__main__':build()
