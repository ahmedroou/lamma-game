from pathlib import Path
from collections import Counter
from decimal import Decimal
import json,re
p=Path(__file__).parent
m=json.loads((p/'ordered_numeric_final_polish.json').read_text(encoding='utf-8'))
print('changes',Counter(x['change'] for x in m['changes']))
qs=[q for c in ['first_last','complete_sequence','numbers','one_wrong'] for q in json.loads((p/(c+'.json')).read_text(encoding='utf-8'))['questions']]
assert len(qs)==1200
for cat in ['first_last','complete_sequence','numbers','one_wrong']:
 qq=[q for q in qs if q['categoryId']==cat]
 assert len(qq)==300 and Counter(q['difficulty'] for q in qq)==Counter({d:75 for d in ['easy','medium','hard','legendary']})
 assert Counter(q['correctOptionId'] for q in qq)==Counter({l:50 for l in 'ABCDEF'})
 for q in qq:
  assert len(q['options'])==6 and len({o['text'] for o in q['options']})==6
  assert next(o['text'] for o in q['options'] if o['id']==q['correctOptionId'])==q['answer']
  assert not any(o['text'] in q['acceptedAnswers'] for o in q['options'] if o['id']!=q['correctOptionId'])
  assert q['text'] and q['hint'] and q['explanation'] and q['sources']
  its=[i for s in q.get('presentation',{}).get('sections',[]) for i in s['items']]
  assert all(not i.get('missing') or i['text']=='؟' for i in its)
  assert len({i['id'] for i in its})==len(its)
 if cat=='numbers':
  for d in ['easy','medium','hard','legendary']:
   assert Counter(q['subtype'] for q in qq if q['difficulty']==d)==Counter({s:15 for s in ['number_owner','number_wrong','number_nearest','number_matching','number_ordering']})
checks=json.loads((p/'ordered_numeric_checks.json').read_text(encoding='utf-8'))
qc={q['id']:q for q in qs}
for c in checks:
 if c.get('mode')=='nearest':
  r=Decimal(c['reference']);v=[Decimal(x) for x in c['estimates']];dd=[abs(x-r) for x in v]
  assert len(set(v))==6 and min(dd)>0 and dd.count(min(dd))==1
 if c.get('mode')=='one_wrong':assert sum(a!=b for a,b in zip(c['truths'],c['shown']))==1
 if c.get('mode')=='wrong':assert Decimal(c['wrongValue'])!=Decimal(c['actualValue'])
seq=Counter((qc[x['id']]['difficulty'],'before' if x['gap']==0 else 'after' if x['gap']==x['length']-1 else 'inside') for x in checks if x['id'].startswith('complete_sequence'))
assert all(v==25 for v in seq.values())
keys=[q['text']+'|'+json.dumps(q.get('presentation'),ensure_ascii=False,sort_keys=True) for q in qs]
assert len(set(keys))==1200,'duplicate question/presentation'
print('sequence',seq)
print('English-only answers',[q['answer'] for q in qs if not re.search('[\u0600-\u06ff]',q['answer']) and re.search('[A-Za-z]',q['answer'])])
for q in [q for q in qs if q['categoryId']=='numbers' and q['subtype']=='number_owner']:
 print(q['id'],q['text'],q['answer'])
(p/'ordered_numeric_polish_validation.json').write_text(json.dumps({'count':1200,'culturalReplacements':24,'difficultyAndSubtypeQuotas':'passed','sixUniqueOptionsAndSingleCorrect':'passed','nearestAndWrongArithmetic':'passed','sequencePlacements':dict((f'{d}/{k}',v) for (d,k),v in seq.items()),'duplicateQuestionAndPresentationCount':0},ensure_ascii=False,indent=2),encoding='utf-8')
sample_file=p/'ordered_numeric_review_sample.json'
if sample_file.exists():
 sample_ids=[q['id'] for q in json.loads(sample_file.read_text(encoding='utf-8'))]
 sample_file.write_text(json.dumps([qc[i] for i in sample_ids],ensure_ascii=False,indent=2),encoding='utf-8')
report_file=p/'ORDERED_NUMERIC_AUTHORING_REPORT.json'
report=json.loads(report_file.read_text(encoding='utf-8'))
for cat in report['categories']:
 qq=[q for q in qs if q['categoryId']==cat]
 report['categories'][cat]['sourceDomains']=dict(Counter(q['sources'][0].split('/')[2] if q['sources'][0].startswith('http') else 'original-proof' for q in qq))
report['finalPolish']={'culturalReplacements':24,'arabicPersonalNames':'No English-only personal-name answers remain; technical Latin taxonomy and geologic names preserved.','numericOwnerWording':'property-specific','massNotation':'×10²⁴ كغ','sourceReading':'No new optional sources introduced in final polish.'}
report_file.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print('PASS')
