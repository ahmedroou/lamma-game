import json,collections,hashlib,re
from pathlib import Path
from audit_reference_abbreviation_options import findings as abbreviation_artifacts
BASE=Path(__file__).parent
report={}
for cat in ['abbreviations','symbols_signals','currency_stories']:
 p=BASE/(cat+'.json');d=json.loads(p.read_text(encoding='utf-8'));qs=d['questions'];assert len(qs)==300
 if cat=='abbreviations':assert not abbreviation_artifacts(qs),abbreviation_artifacts(qs)
 assert d['schemaVersion']==1 and d['categoryId']==cat and d['targetCount']==300 and d['targetPerDifficulty']==75
 ids=set();identities=set();images=set();sourceurls=set();diffs=collections.Counter();letters=collections.Counter()
 for q in qs:
  assert q['id'] not in ids;ids.add(q['id']);diffs[q['difficulty']]+=1;letters[q['correctOptionId']]+=1
  assert q['categoryId']==cat and q['clues']==[]
  assert all(q.get(f) for f in ['text','answer','hint','explanation','sources','qualityStatus'])
  assert isinstance(q['acceptedAnswers'],list)
  assert [o['id'] for o in q['options']]==list('ABCDEF')
  assert all(isinstance(o['text'],str) and o['text'].strip() for o in q['options']), ('Empty option text',q['id'])
  assert len({o['text'] for o in q['options']})==6
  assert next(o['text'] for o in q['options'] if o['id']==q['correctOptionId'])==q['answer']
  assert not any(o['text'] in q['acceptedAnswers'] for o in q['options'] if o['id']!=q['correctOptionId'])
  if 'presentation' in q:
   pres=q['presentation'];assert pres['type']=='symbols';assert len(pres['sections'])==1
   assert 1<=len(pres['sections'][0]['items'])<=6
   itemids=[it['id'] for sec in pres['sections'] for it in sec['items']];assert len(set(itemids))==len(itemids)
  if 'imageAsset' in q:
   media=BASE/'media'/Path(q['imageAsset']).name;assert media.is_file();digest=hashlib.sha256(media.read_bytes()).hexdigest();images.add(digest);assert q['imageDescription']
  else:digest=''
  key=json.dumps([q['text'],q.get('presentation'),digest],ensure_ascii=False,sort_keys=True);assert key not in identities;identities.add(key)
  sourceurls.update(s for s in q['sources'] if s.startswith('https://'))
 for diff in ['easy','medium','hard','legendary']:
  assert diffs[diff]==75;assert all(f'{cat}-{diff}-{n:04d}' in ids for n in range(1,76))
 assert all(letters[c]==50 for c in 'ABCDEF')
 report[cat]={'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'count':len(qs),'perDifficulty':dict(diffs),'answersByLetter':dict(letters),'uniqueDisplayedQuestions':len(identities),'uniqueImages':len(images),'primarySourceURLs':len(sourceurls),'nonemptyOptionsChecked':len(qs)*6,'emptyOptions':0,'reviewed':sum(q['qualityStatus']=='reviewed' for q in qs),'unreviewed':sum(q['qualityStatus']=='unreviewed' for q in qs)}
manifest=json.loads((BASE/'media/manifest.json').read_text(encoding='utf-8'))
expected_images={Path(q['imageAsset']).name for q in json.loads((BASE/'symbols_signals.json').read_text(encoding='utf-8'))['questions'] if q.get('imageAsset')}
assert len(manifest)>=74 and {m['name'] for m in manifest}==expected_images and len(manifest)==len(expected_images)
for m in manifest:assert hashlib.sha256((BASE/'media'/m['name']).read_bytes()).hexdigest()==m['sha256']
report['media']={'images':len(manifest),'manifestChecks':f'{len(manifest)}/{len(manifest)} SHA-256 matched'}
(BASE/'reference_categories_validation.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
