"""Verify the 100-per-category expansion and preservation of existing IDs.

This gate checks delivery and structural defects, not factual certification.
It uses the pre-expansion archive, which is excluded from app assets.
"""
import hashlib
import json
import re
from collections import Counter
from pathlib import Path
from audit_question_quality import is_placeholder, question_signature, normalize_option

ROOT = Path(__file__).resolve().parents[1]
LEVELS = ('easy', 'medium', 'hard', 'legendary')

def verify():
    failures, result = [], []
    all_ids, all_texts = set(), {}
    for path in sorted((ROOT / 'assets/questions').glob('*.json')):
        raw = path.read_bytes()
        doc = json.loads(raw.decode('utf-8-sig'))
        category = doc['categoryId']
        old = json.loads((ROOT / 'design_sources/questions_before_900' / path.name).read_text(encoding='utf-8-sig'))
        questions = doc['questions']
        by_id = {q['id']: q for q in questions}
        old_ids = {q['id'] for q in old['questions']}
        expected_additions = {f'{category}-{level}-{i:04}' for level in LEVELS for i in range(201, 226)}
        if doc.get('targetCount') != 900 or doc.get('targetPerDifficulty') != 225:
            failures.append(f'{category}: target headers must be 900/225')
        if len(questions) != 900 or Counter(q['difficulty'] for q in questions) != dict.fromkeys(LEVELS, 225):
            failures.append(f'{category}: expected 900 rows and 225 in each difficulty')
        if set(by_id) != old_ids | expected_additions:
            failures.append(f'{category}: missing/changed original ID or missing/extraneous new ID')
        rebuilt = 0
        for previous in old['questions']:
            if previous.get('qualityStatus') != 'quarantined' and not is_placeholder(previous):
                continue
            replacement = by_id.get(previous['id'], {})
            # The identity card keeps its neutral "من أنا؟" title. Its actual
            # question is the three authored clues, which must all be replaced.
            content_field='clues' if category=='who_am_i' else 'text'
            substantive=(content_field,'answer','hint','explanation','options')
            if any(replacement.get(key) == previous.get(key) for key in substantive):
                failures.append(f'{previous["id"]}: reauthor all substantive placeholder fields')
            else:
                rebuilt += 1
        for q in questions:
            qid = q['id']
            if qid in all_ids:
                failures.append(f'{qid}: duplicate global ID')
            all_ids.add(qid)
            if q.get('qualityStatus') == 'quarantined' or is_placeholder(q):
                failures.append(f'{qid}: unresolved quarantined/placeholder content')
            if not q.get('sources') or not q.get('hint') or not q.get('explanation'):
                failures.append(f'{qid}: missing source/hint/explanation')
            options = q.get('options', [])
            accepted = {normalize_option(q['answer']), *(normalize_option(a) for a in q.get('acceptedAnswers', []))}
            matching = [o['id'] for o in options if normalize_option(o['text']) in accepted]
            if len(options) != 6 or {o['id'] for o in options} != set('ABCDEF') or len({normalize_option(o['text']) for o in options}) != 6 or matching != [q.get('correctOptionId')]:
                failures.append(f'{qid}: invalid six-option/reference-answer mapping')
            if category == 'who_am_i' and (len(q.get('clues', [])) != 3 or len(set(q.get('clues', []))) != 3):
                failures.append(f'{qid}: three distinct identity clues required')
            text = question_signature(q)
            if text in all_texts:
                failures.append(f'{qid}: repeated normalized question/clues with {all_texts[text]}')
            all_texts[text] = qid
            if qid in expected_additions:
                if not re.fullmatch(r'.+-[a-z]+-02(?:0[1-9]|1[0-9]|2[0-5])', qid):
                    failures.append(f'{qid}: unexpected addition range')
                # The added correct position should not form a uniform answer pattern.
        distribution = Counter(by_id[qid]['correctOptionId'] for qid in expected_additions if qid in by_id)
        if len(distribution) < 6 or max(distribution.values(), default=0) > 25:
            failures.append(f'{category}: added correct-option positions are overly concentrated: {distribution}')
        result.append(dict(categoryId=category, questions=len(questions),
            additions=len(expected_additions & set(by_id)), rebuiltDamaged=rebuilt,
            qualityStatuses=dict(Counter(q.get('qualityStatus', 'unreviewed') for q in questions)),
            addedCorrectPositions=dict(distribution), sha256=hashlib.sha256(raw).hexdigest()))
    report = dict(totalQuestions=sum(r['questions'] for r in result),
        addedQuestions=sum(r['additions'] for r in result),
        rebuiltDamaged=sum(r['rebuiltDamaged'] for r in result),
        categories=result, failures=failures,
        scope='Delivery/structural checks only; does not certify all factual claims or distractor semantics.')
    (ROOT / 'QUESTION_EXPANSION_VALIDATION.json').write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({k:report[k] for k in ('totalQuestions', 'addedQuestions', 'rebuiltDamaged')}, ensure_ascii=False))
    print(json.dumps(dict(failureCount=len(failures), firstFailures=failures[:30]), ensure_ascii=False))
    return not failures

if __name__ == '__main__':
    raise SystemExit(0 if verify() else 1)
