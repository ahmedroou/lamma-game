"""Merge immutable, authored batches over the pre-expansion bank.

Prepares all 14 banks before changing production. Keeps stable original IDs,
validates the +100 allocation, archives current files, and saves result hashes.
"""
import hashlib
import json
import random
from collections import Counter
from pathlib import Path
from audit_question_quality import is_placeholder, normalize_option, question_signature

ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'design_sources/questions_before_900'
STAGE=ROOT/'tool/staging'
LEVELS=('easy','medium','hard','legendary')

def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def rows(path):
    value=read(path)
    return value['questions'] if isinstance(value,dict) else value

def distribute_new_options(index,category):
    rng=random.Random(hashlib.sha256(category.encode()).hexdigest())
    for level_index,level in enumerate(LEVELS):
        positions=list(range(6))*4+[level_index]
        rng.shuffle(positions)
        for number,position in zip(range(201,226),positions):
            q=index[f'{category}-{level}-{number:04}']
            correct=next(o['text'] for o in q['options'] if o['id']==q['correctOptionId'])
            wrong=[o['text'] for o in q['options'] if o['id']!=q['correctOptionId']]
            rng.shuffle(wrong)
            wrong.insert(position,correct)
            q['options']=[dict(id=chr(65+i),text=text) for i,text in enumerate(wrong)]
            q['correctOptionId']=chr(65+position)

def authored(category):
    if category in ('how_it_works','maps','riddles'):
        bank=read(STAGE/f'{category}.json')
        baseline=read(BASE/f'{category}.json')
        targets={q['id'] for q in baseline['questions'] if q.get('qualityStatus')=='quarantined' or is_placeholder(q)}
        # Only authored rows are merged; staged copies of legacy rows cannot
        # accidentally certify or replace records outside this author's scope.
        return [q for q in bank['questions'] if q['id'] in targets or int(q['id'].rsplit('-',1)[1])>200]
    if category in ('meanings','who_am_i'):
        items=rows(ROOT/f'tool/authoring_general/batches/{category}.json')
        if category=='who_am_i':
            items+=rows(STAGE/'who_existing_fixes.json')
        return items
    if category=='geography':
        return rows(ROOT/'tool/authoring_geography/additions.json')
    if category=='myths':
        return rows(ROOT/'tool/authoring_myths/authored_questions.json')
    if category=='notable_figures':
        items=rows(STAGE/'notable_replacements_195.json')+rows(STAGE/'notable_expansion_100.json')
        fixes=STAGE/'notable_existing_fixes.json'
        return items+(rows(fixes) if fixes.exists() else [])
    return rows(STAGE/f'{category}_expansion_100.json')

def main():
    prepared={}
    seen_ids, seen_texts=set(),{}
    summary=[]
    for original_path in sorted(BASE.glob('*.json')):
        if original_path.name=='baseline.json':
            continue
        doc=read(original_path)
        category=doc['categoryId']
        index={q['id']:q for q in doc['questions']}
        records=authored(category)
        batch_ids=set()
        for q in records:
            assert q['categoryId']==category and q['id'] not in batch_ids,(category,q['id'])
            batch_ids.add(q['id'])
            if q['id'] in index:
                assert index[q['id']]['difficulty']==q['difficulty'],q['id']
            else:
                assert 201<=int(q['id'].rsplit('-',1)[1])<=225,q['id']
            index[q['id']]=q
        expected={f'{category}-{level}-{i:04}' for level in LEVELS for i in range(1,226)}
        assert set(index)==expected,(category,'missing/extra IDs')
        assert Counter(q['difficulty'] for q in index.values())==dict.fromkeys(LEVELS,225),category
        distribute_new_options(index,category)
        for q in index.values():
            assert not is_placeholder(q) and q.get('qualityStatus')!='quarantined',q['id']
            assert q['id'] not in seen_ids,q['id']
            seen_ids.add(q['id'])
            options=q['options']
            accepted={normalize_option(q['answer']),*(normalize_option(a) for a in q.get('acceptedAnswers',[]))}
            matches=[o['id'] for o in options if normalize_option(o['text']) in accepted]
            assert len(options)==len({normalize_option(o['text']) for o in options})==6,q['id']
            assert {o['id'] for o in options}==set('ABCDEF') and matches==[q['correctOptionId']],q['id']
            signature=question_signature(q)
            assert signature not in seen_texts,(q['id'],seen_texts.get(signature))
            seen_texts[signature]=q['id']
        doc.update(targetCount=900,targetPerDifficulty=225,status='draft',questions=sorted(index.values(),key=lambda q:(LEVELS.index(q['difficulty']),q['id'])))
        output=(json.dumps(doc,ensure_ascii=False,indent=2)+'\n').encode('utf-8')
        prepared[original_path.name]=output
        summary.append(dict(categoryId=category,questions=900,
            authoredRecords=len(records),added=100,
            reviewed=sum(q.get('qualityStatus')=='reviewed' for q in index.values()),
            sha256=hashlib.sha256(output).hexdigest()))
    assert len(prepared)==14
    archive=ROOT/'design_sources/questions_before_publication_900'
    archive.mkdir(parents=True,exist_ok=True)
    final=ROOT/'tool/staging_final'
    final.mkdir(parents=True,exist_ok=True)
    # All content validated in memory before any production write.
    for name,output in prepared.items():
        path=ROOT/'assets/questions'/name
        archive_path=archive/name
        if not archive_path.exists():
            archive_path.write_bytes(path.read_bytes())
        (final/name).write_bytes(output)
        path.write_bytes(output)
    report=dict(totalQuestions=12600,addedQuestions=1400,categories=summary,
        scope='Authored batches plus retained legacy content; draft status preserves outstanding editorial review.')
    (ROOT/'QUESTION_EXPANSION_PUBLISHED.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(totalQuestions=12600,added=1400,authoredRecords=sum(c['authoredRecords'] for c in summary))))

if __name__=='__main__':
    main()
