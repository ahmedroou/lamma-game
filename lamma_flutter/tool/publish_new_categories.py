"""Validate and publish only the ten new categories; retain legacy banks verbatim."""
import hashlib,json,shutil,random
from collections import Counter
from pathlib import Path
from assign_question_usage_ids import assign,atomic_write
from audit_question_quality import normalize_option,is_placeholder
from triage_question_bank import editorial_signature

ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'tool/new_categories'
READY=ROOT/'tool/new_categories_ready'
CATEGORIES=('symbols_signals','abbreviations','first_last','split_groups','pair_up',
 'currency_stories','one_wrong','complete_sequence','relationship','numbers')
LEVELS=('easy','medium','hard','legendary')

def read(path):return json.loads(path.read_text(encoding='utf-8-sig'))
def encoded(doc):return (json.dumps(doc,ensure_ascii=False,indent=2)+'\n').encode('utf-8')
def balance_options(category,doc):
 rng=random.Random(hashlib.sha256(category.encode()).hexdigest())
 for level_index,level in enumerate(LEVELS):
  positions=list(range(6))*12+[(level_index*3+i)%6 for i in range(3)]
  rng.shuffle(positions)
  questions=sorted((q for q in doc['questions']if q['difficulty']==level),key=lambda q:q['id'])
  for q,position in zip(questions,positions):
   correct=next(o['text']for o in q['options']if o['id']==q['correctOptionId'])
   wrong=[o['text']for o in q['options']if o['id']!=q['correctOptionId']];rng.shuffle(wrong);wrong.insert(position,correct)
   q['options']=[dict(id=chr(65+i),text=value)for i,value in enumerate(wrong)];q['correctOptionId']=chr(65+position)
def validate(category,doc):
 assert (doc['categoryId'],doc['schemaVersion'],doc['targetCount'],doc['targetPerDifficulty'])==(category,1,300,75),category
 qs=doc['questions'];assert len(qs)==300 and Counter(q['difficulty']for q in qs)==dict.fromkeys(LEVELS,75),category
 expected={f'{category}-{level}-{i:04}'for level in LEVELS for i in range(1,76)}
 assert {q['id']for q in qs}==expected and len({editorial_signature(q)for q in qs})==300,(category,'IDs or duplicated premises')
 for q in qs:
  assert q['categoryId']==category and not is_placeholder(q) and q.get('qualityStatus')!='quarantined',q['id']
  assert all(q.get(key) for key in ('text','answer','hint','explanation','sources')) and q.get('clues')==[],q['id']
  opts=q['options'];accepted={normalize_option(q['answer']),*(normalize_option(a)for a in q['acceptedAnswers'])}
  assert len(opts)==6 and {o['id']for o in opts}==set('ABCDEF') and all(isinstance(o['text'],str) and o['text'].strip()for o in opts) and len({normalize_option(o['text'])for o in opts})==6,q['id']
  assert [o['id']for o in opts if normalize_option(o['text'])in accepted]==[q['correctOptionId']],q['id']
  p=q.get('presentation')
  if p:
   assert p['type']in('matching','grouping','statements','sequence','comparison','symbols') and 1<=len(p['sections'])<=2,q['id']
   items=[item for section in p['sections']for item in section['items']]
   assert len({i['id']for i in items})==len(items) and all(i['text'].strip()for i in items),q['id']
   assert all(i['text']=='؟'for i in items if i.get('missing')),q['id']
   sizes=[len(s['items'])for s in p['sections']]
   if p['type']=='matching':assert len(sizes)==2 and sizes[0]==sizes[1] and 2<=sizes[0]<=4,q['id']
   else:
    assert len(sizes)==1,q['id']
    size=sizes[0]
    if p['type']=='grouping':assert size in(6,8),q['id']
    elif p['type']=='statements':assert size in(4,5),q['id']
    elif p['type']=='sequence':assert 3<=size<=8 and any(i.get('missing')for i in items),q['id']
    elif p['type']=='comparison':assert 3<=size<=6,q['id']
    else:assert 1<=size<=6,q['id']
  if q.get('imageAsset'):
   assert q['imageAsset'].startswith('assets/question_media/') and '..'not in q['imageAsset'] and '\\'not in q['imageAsset'],q['id']
   assert q.get('imageDescription') and (ROOT/q['imageAsset']).exists(),q['id']
 for level in LEVELS:
  counts=Counter(q['correctOptionId']for q in qs if q['difficulty']==level)
  assert set(counts)==set('ABCDEF') and max(counts.values())-min(counts.values())<=1,(category,level,counts)
 if category=='numbers':
  types=('number_owner','number_wrong','number_nearest','number_matching','number_ordering')
  for level in LEVELS:assert Counter(q['subtype']for q in qs if q['difficulty']==level)==dict.fromkeys(types,15),(category,level)

def main():
 (READY/'assets/questions').mkdir(parents=True,exist_ok=True);(READY/'tool').mkdir(exist_ok=True)
 registry=ROOT/'tool/question_usage_ids.json';old_registry=registry.read_bytes()
 old_banks={p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in (ROOT/'assets/questions').glob('*.json')if p.stem not in CATEGORIES}
 media=read(SOURCE/'media/manifest.json')
 for item in media:
  path=SOURCE/'media'/item['name'];assert path.name==item['name'] and '..'not in path.name
  assert hashlib.sha256(path.read_bytes()).hexdigest()==item['sha256'],path
  dest=ROOT/'assets/question_media'/path.name
  if dest.exists():assert dest.read_bytes()==path.read_bytes(),dest
  else:shutil.copyfile(path,dest)
 docs={c:read(SOURCE/f'{c}.json')for c in CATEGORIES}
 for c,d in docs.items():balance_options(c,d);validate(c,d);atomic_write(READY/f'assets/questions/{c}.json',encoded(d))
 atomic_write(READY/'tool/question_usage_ids.json',old_registry)
 usage=assign(READY)
 assert registry.read_bytes()==old_registry,'Concurrent registry change; retry rather than replacing IDs'
 # Reserve the numbers first so a partial publication recovers identical IDs.
 atomic_write(registry,(READY/'tool/question_usage_ids.json').read_bytes())
 result=[]
 for c in CATEGORIES:
  path=READY/f'assets/questions/{c}.json';doc=read(path);validate(c,doc)
  atomic_write(ROOT/f'assets/questions/{c}.json',path.read_bytes())
  result.append(dict(categoryId=c,count=300,perDifficulty=75,sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
   qualityStatuses=dict(Counter(q.get('qualityStatus','unreviewed')for q in doc['questions']))))
 for name,digest in old_banks.items():assert hashlib.sha256((ROOT/'assets/questions'/name).read_bytes()).hexdigest()==digest,'Legacy bank changed during publication'
 report=dict(addedCategories=10,addedQuestions=3000,totalCategories=24,totalQuestions=sum(len(read(p)['questions'])for p in(ROOT/'assets/questions').glob('*.json')),
  usageIds=usage,categories=result,mediaFiles=len(media),mediaBytes=sum((SOURCE/'media'/i['name']).stat().st_size for i in media),
  scope='Delivery and structural verification; retained legacy quarantine/review statuses and no automatic editorial certification.')
 atomic_write(ROOT/'NEW_CATEGORIES_VALIDATION.json',encoded(report));print(json.dumps({k:report[k]for k in('addedCategories','addedQuestions','totalCategories','totalQuestions','mediaFiles','mediaBytes')}))
if __name__=='__main__':main()
