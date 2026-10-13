"""Remove candidates whose capabilities overlap, retaining exact identities."""
import json, random, re, collections
from pathlib import Path
from relational_authoring import question, GEO
OUT=Path(__file__).parent
R=random.Random(12226613)
facts=json.loads((OUT/'relational_direct_facts.json').read_text(encoding='utf-8'))
modules=facts['modules'];units=facts['units'];products=facts['products']
module_families=[
 {'base64','binascii'}, {'math','cmath','decimal','fractions','statistics'},
 {'pickle','shelve'}, {'zlib','gzip','bz2','lzma','zipfile','tarfile'},
 {'threading','multiprocessing','subprocess','queue','heapq'},
 {'glob','pathlib','filecmp','shutil','tempfile'},
 {'pkgutil','modulefinder','runpy','importlib','zipimport'},
 {'ast','symtable','token','tokenize','keyword','py_compile','compileall','tabnanny'},
 {'unittest','unittest.mock','pydoc'}, {'html.parser','xml.etree.ElementTree'},
 {'argparse','getpass'}, {'datetime','calendar','zoneinfo'},
 {'socket','ssl','selectors','signal','mmap'},
]
product_families=[{'Photoshop','Illustrator','Lightroom','InDesign'}, {'Premiere','After Effects','Audition'}, {'Google Docs','Google Sheets','Google Slides'}, {'Google Calendar','Google Keep','Google Tasks'}, {'Gmail','Google Meet','Google Chat'}]
def family(x,sets):
    return next((s for s in sets if x in s),{x})
counter=collections.Counter()
path=OUT/'relationship.json';data=json.loads(path.read_text(encoding='utf-8'))
for q in data['questions']:
    if not q['text'].endswith('في تعريف الأداة ووظيفتها الأساسية؟'):continue
    left=re.findall('«([^»]+)»',q['text'])[0]
    pool=modules if left in {x['left'] for x in modules} else products
    excluded=family(left,module_families if pool is modules else product_families)
    candidates=[x for x in pool if x['left'] not in excluded]
    R.shuffle(candidates)
    wrong=[f'وظيفة «{left}» الأساسية في هذا التعريف هي {x["right"]}' for x in candidates[:5]]
    correct=q['correctOptionId']
    iterator=iter(wrong)
    for option in q['options']:
        option['text']=q['answer'] if option['id']==correct else next(iterator)
    # These descriptions make the end product explicit, distinguishing e.g.
    # a binary representation from textual encoding or file storage.
    q['hint']='حدّد الناتج المطلوب: نوع الملف أو التمثيل أو الوظيفة النهائية، ثم قارنه بتعريف الأداة.'
    counter['function_options_rebuilt']+=1
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

# Reject crossings inside matching sets when interchangeable general-purpose
# operations could obscure the intended association. Replace such sets with
# equally sized tasks from three clearly distinct functional families.
from refine_relational_banks import make_match
path=OUT/'pair_up.json';data=json.loads(path.read_text(encoding='utf-8'))
seen=set()
allleft={x['left'] for seq in facts.values() for x in seq}
for q in data['questions']:
    pairs=[tuple(s.split(' ← ')) for s in q['answer'].split('؛ ')]
    seen.add(tuple(sorted(a+'→'+b if a in allleft else b+'→'+a for a,b in pairs)))
for idx,q in enumerate(data['questions']):
    if 'Python' not in q['text']:continue
    pairs=[tuple(s.split(' ← ')) for s in q['answer'].split('؛ ')]
    names=[a if a in {x['left'] for x in modules} else b for a,b in pairs]
    overlap=any(b in family(a,module_families) for a,b in __import__('itertools').combinations(names,2))
    if not overlap:continue
    for _ in range(100):
        new=make_match(q['difficulty'],int(q['id'].rsplit('-',1)[1]),modules,'ربط وحدات Python 3.14 القياسية بوظائفها',seen)
        newpairs=[tuple(s.split(' ← ')) for s in new['answer'].split('؛ ')]
        ns=[a if a in {x['left'] for x in modules} else b for a,b in newpairs]
        if not any(b in family(a,module_families) for a,b in __import__('itertools').combinations(ns,2)):break
    reverse=q['difficulty'] in ('hard','legendary') and int(q['id'].rsplit('-',1)[1])%3==0
    new['text']='صِل كل وصف وظيفي بالوحدة المناسبة من مكتبة Python 3.14.' if reverse else 'صِل كل وحدة من مكتبة Python 3.14 بوصف وظيفتها الأساسية في دليل اللغة.'
    missing=sum(bool(i.get('missing')) for i in new['presentation']['sections'][1]['items'])
    new['text']+=(' استنتج أسماء الأطراف الناقصة مكان «؟»، ثم اذكر الأزواج الثلاثة كاملة. لا يهم ترتيب الخانات الفارغة.' if missing else ' اذكر الأزواج الثلاثة كاملة.')
    data['questions'][idx]=new;counter['overlapping_matching_sets_replaced']+=1
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(OUT/'relational_option_polish.json').write_text(json.dumps(dict(counter),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(dict(counter))
