"""Publish individually authored records. Never creates content from numeric templates."""
import argparse
import collections
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LETTERS = 'ABCDEF'

def normalized(text):
    text = re.sub('[\u064b-\u065f\u0670\u0640]', '', text)
    return re.sub(r'[^\w]+', ' ', text.replace('أ','ا').replace('إ','ا').replace('آ','ا').replace('ى','ي')).strip().casefold()

def publish(category, batch):
    path = ROOT / 'assets/questions' / f'{category}.json'
    bank = json.loads(path.read_text(encoding='utf-8'))
    index = {q['id']: i for i, q in enumerate(bank['questions'])}
    changed = []
    for q in batch:
        assert q['categoryId'] == category
        assert q['difficulty'] in ('easy','medium','hard','legendary')
        assert q['hint'] and q['explanation'] and q['sources']
        assert len(q['clues']) == (3 if category == 'who_am_i' else 0)
        assert len(q['options']) == 6
        assert [o['id'] for o in q['options']] == list(LETTERS)
        assert len({normalized(o['text']) for o in q['options']}) == 6
        assert next(o['text'] for o in q['options'] if o['id'] == q['correctOptionId']) in [q['answer'], *q['acceptedAnswers']]
        other = [x for x in bank['questions'] if x['id'] != q['id']]
        fingerprint = normalized(' | '.join(q['clues']) if category == 'who_am_i' else q['text'])
        assert all(normalized(' | '.join(x['clues']) if category == 'who_am_i' else x['text']) != fingerprint for x in other), q['id']
        if q['id'] in index:
            original = bank['questions'][index[q['id']]]
            assert original['difficulty'] == q['difficulty']
            bank['questions'][index[q['id']]] = q
        else:
            assert 201 <= int(q['id'].split('-')[-1]) <= 225
            index[q['id']] = len(bank['questions'])
            bank['questions'].append(q)
        changed.append(q['id'])
    counts=collections.Counter(q['difficulty'] for q in bank['questions'])
    assert all(n<=225 for n in counts.values())
    bank.update(targetCount=900,targetPerDifficulty=225,status='draft')
    # A concurrently running writer has been replacing assets/questions/*.json.
    # Save durable authored records for the parent's single integration transaction.
    archive=ROOT/'tool/authoring_general/batches'
    archive.mkdir(parents=True,exist_ok=True)
    batchpath=archive/f'{category}.json'
    previous=json.loads(batchpath.read_text(encoding='utf8')) if batchpath.exists() else []
    staged={q['id']:q for q in previous}
    staged.update({q['id']:q for q in batch})
    batchpath.write_text(json.dumps(list(staged.values()),ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    print(json.dumps({'category':category,'written':len(changed),'authoredArchive':len(staged),'countsAfterMerge':counts,'archive':str(batchpath)},ensure_ascii=False))

def question(category, difficulty, number, text, answer, distractors, hint, explanation, sources, clues=None, aliases=None):
    ident=f'{category}-{difficulty}-{number:04}'
    assert len(distractors)==5
    candidates=[answer,*distractors]
    # Stable, independent of question serial number; avoids a visibly cycling answer key.
    position=int.from_bytes(hashlib.sha256((ident+text).encode()).digest()[:2],'big')%6
    candidates.insert(position,candidates.pop(0))
    return dict(id=ident,categoryId=category,difficulty=difficulty,text=text,answer=answer,acceptedAnswers=aliases or [],hint=hint,clues=clues or [],explanation=explanation,sources=sources,options=[dict(id=c,text=t) for c,t in zip(LETTERS,candidates)],correctOptionId=LETTERS[position],qualityStatus='reviewed')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('category');p.add_argument('batch');a=p.parse_args()
    publish(a.category,json.loads(Path(a.batch).read_text(encoding='utf-8')))
