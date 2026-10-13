"""Packaging only: the lexical meanings, contexts and hints are authored in TXT."""
import json
import re
import sys
from pathlib import Path
from write_batch import ROOT, normalized, question, publish

sys.stdout.reconfigure(encoding='utf-8')
SOURCE='https://www.arabic-keyboard.info/books/ar/read-book/فقه-اللغة-وسر-العربية'
groups=[]
for line in Path(__file__).with_name('meanings_lexicon.txt').read_text(encoding='utf-8').splitlines():
    if not line or line.startswith('#'): continue
    if line.startswith('@'):
        label,difficulty=line[1:].split('|');groups.append((label,difficulty,[]))
    else:
        parts=line.split('~');assert len(parts)==4,line
        groups[-1][2].append(parts)

bank=json.loads((ROOT/'assets/questions/meanings.json').read_text(encoding='utf-8'))
targets=[q['id'] for q in bank['questions'] if q.get('qualityStatus')=='quarantined']
# Idempotent packaging after review: replacements retain their original 0006..0200 IDs.
if not targets: targets=[f'meanings-legendary-{n:04}' for n in range(6,201)]
assert len(targets)==195
rows=[];collisions=[]
existing=[q for q in bank['questions'] if q['id'] not in targets]
for label,difficulty,entries in groups:
    assert len(entries)==6,(label,len(entries))
    assert len({normalized(x[2]) for x in entries})==6,label
    for term,context,answer,hint in entries:
        focus=normalized(term)
        for old in existing:
            # Compare the queried term, not incidental words in the surrounding context.
            quoted=re.findall('«([^»]+)»',old['text'])
            if any(normalized(x).removeprefix('ال')==focus.removeprefix('ال') for x in quoted):
                collisions.append((term,old['id'],old['text']))
        rows.append((label,difficulty,entries,term,context,answer,hint))
print('candidate_count',len(rows));print('focus_collisions',json.dumps(collisions,ensure_ascii=False))
if '--check' in sys.argv: sys.exit()
assert len(rows)>=195
out=[]
for ident,row in zip(targets,rows):
    label,difficulty,entries,term,context,answer,hint=row
    number=int(ident.split('-')[-1])
    text=f'في عبارة «{context}»، ما الدلالة الدقيقة لـ«{term}» بحسب تخصيص الثعالبي في باب {label.split(" ",1)[-1]} من «فقه اللغة»؟'
    distractors=[x[2] for x in entries if x[0]!=term]
    # Broad descriptions must not compete with their narrower readings.
    # Each substitute below is a plausible but unsupported reading, never a synonym.
    if term == 'المُور':
        distractors[0]='تراب يجرفه السيل في الوادي'
    elif term == 'السَّافِيَاء':
        distractors[0]='تراب ينهال من سقف الكهف'
    elif term == 'الصَّمَع':
        distractors[0]='كبر الأذن مع ضيق فتحتها'
    elif term == 'السَّكَك':
        distractors[0]='صغر فتحة الأذن دون ظاهرها'
    elif term == 'الوَقْر':
        distractors[distractors.index('صمم لا يسمع معه الرعد')]='حدة السمع للأصوات البعيدة'
    elif term == 'الصَّلَخ':
        distractors[distractors.index('ثقل في السمع')]='سمع الأصوات الخافتة دون المرتفعة'
    explanation=f'يذكر الثعالبي في {label} أن «{term}» يدل على «{answer}». العبارة مؤلفة لتعيين هذا الاستعمال، والخيارات الأخرى تخص معاني ألفاظ أخرى في التقسيم نفسه.'
    out.append(question('meanings',difficulty,number,text,answer,distractors,hint,explanation,[f'الثعالبي، فقه اللغة وسر العربية، {label}؛ النص المقروء: {SOURCE}']))
Path(__file__).with_name('meanings_rebuilt.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
publish('meanings',out)
