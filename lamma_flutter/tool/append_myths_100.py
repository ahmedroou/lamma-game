"""Package 100 manually authored questions from 100 distinct primary fables."""
import json
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def main():
    folder = ROOT / 'tool/authoring_myths'
    pages = {p['number']: p for p in json.loads((folder/'primary_pages.json').read_text(encoding='utf-8'))}
    path = ROOT/'assets/questions/myths.json'
    original = path.read_bytes()
    doc = json.loads(original.decode('utf-8-sig'))
    old = [q for q in doc['questions'] if int(q['id'].rsplit('-',1)[1]) <= 200]
    assert len(old) == 800
    seen = {q['text'].strip() for q in old}
    counts = Counter()
    additions, source_numbers = [], set()
    for line in (folder/'expansion.tsv').read_text(encoding='utf-8').splitlines():
        if not line or line.startswith('#'):
            continue
        level, number, text, answer, wrong, hint, explanation = line.split('|')
        number = int(number)
        assert number in pages and number not in source_numbers
        source_numbers.add(number)
        counts[level] += 1
        qid = f'myths-{level}-{200+counts[level]:04}'
        choices = [answer, *wrong.split('~')]
        assert len(choices) == len(set(choices)) == 6, qid
        assert text not in seen, qid
        seen.add(text)
        position = len(additions) % 6
        choices = choices[1:position+1]+[answer]+choices[position+1:]
        page = pages[number]
        additions.append(dict(id=qid, categoryId='myths', difficulty=level,
            text=text, answer=answer, acceptedAnswers=[], hint=hint, clues=[], explanation=explanation,
            sources=[f'{page["url"]} — مكتبة الكونغرس، The Aesop for Children (1919)، حكاية {page["title"]}؛ قُرئ متن الحكاية في 2026-10-13. السؤال يختبر هذه الرواية تحديداً، والصياغة العربية من تأليفنا.'],
            options=[dict(id=chr(65+i),text=t) for i,t in enumerate(choices)],
            correctOptionId=chr(65+position), qualityStatus='reviewed'))
    assert counts == dict.fromkeys(('easy','medium','hard','legendary'),25), counts
    assert path.read_bytes() == original, 'Concurrent edit; re-read before merging.'
    doc.update(targetCount=900,targetPerDifficulty=225,status='draft',questions=old+additions)
    path.write_text(json.dumps(doc,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (folder/'authored_questions.json').write_text(json.dumps(additions,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(categoryId='myths',added=len(additions),distinctSourceFables=len(source_numbers),count=len(doc['questions']))))

if __name__ == '__main__':
    main()
