import collections
import json
import sys
from pathlib import Path
from write_batch import ROOT,question,publish,normalized
sys.stdout.reconfigure(encoding='utf-8')
groups=[]
for line in Path(__file__).with_name('meanings_additions.txt').read_text(encoding='utf8').splitlines():
    if not line or line.startswith('#'):continue
    if line.startswith('@'):
        label,difficulty=line[1:].split('|');groups.append((label,difficulty,[]))
    else:
        parts=line.split('~');assert len(parts)==4,line;groups[-1][2].append(parts)
out=[];counts=collections.Counter()
for label,difficulty,entries in groups:
    assert len(entries)==6
    assert len({normalized(x[2]) for x in entries})==6
    for term,context,answer,hint in entries:
        if counts[difficulty]>=25:continue
        counts[difficulty]+=1;number=200+counts[difficulty]
        code,chapter=label.split(' ',1) if ' ' in label else (label,label[1:])
        if label.startswith('T'):
            source='https://www.arabic-keyboard.info/books/ar/read-book/فقه-اللغة-وسر-العربية'
            author='الثعالبي';book='فقه اللغة وسر العربية';reference=label[1:]
        else:
            source=f'https://www.safahat.org/books/85925824/{code[1:]}/'
            author='أحمد الهاشمي';book='جواهر البلاغة';reference=chapter
            if term=='القَسَم':
                source='https://www.safahat.org/books/85925824/1.2/'
                reference='الإنشاء غير الطلبي: القسم'
        text=f'في قولنا «{context}»، ما المعنى المقصود بـ«{term}» في اصطلاح {author}؟'
        distractors=[x[2] for x in entries if x[0]!=term]
        if term=='فَاض':distractors[0]='تجمد الماء في قاع النهر'
        if term=='الإطناب':distractors[distractors.index('زيادة غير متعينة بلا فائدة')]='حذف من العبارة يدل عليه السياق'
        explanation=f'«{term}» في هذا الاستعمال تعني «{answer}». يبين {author} ذلك في {reference} من «{book}». السياق يؤلف المثال ويعيّن المعنى، ولا يقصد استعمالًا آخر للفظ.'
        out.append(question('meanings',difficulty,number,text,answer,distractors,hint,explanation,[f'{author}، {book}، {reference}؛ النص المقروء: {source}']))
assert counts==dict(easy=25,medium=25,hard=25,legendary=25)
Path(__file__).with_name('meanings_added.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
publish('meanings',out)
