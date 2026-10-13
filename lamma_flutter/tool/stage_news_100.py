"""Stage individually written news questions; leaves production bank untouched."""
import json
import re
from collections import Counter
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]

def readable(text):
    return re.sub(r'(?<=[ء-ي])(?=[A-Za-z0-9])|(?<=[A-Za-z0-9])(?=[ء-ي])',' ',text).strip()

def main():
    folder=ROOT/'tool/authoring_news'
    urls=json.loads((folder/'sources.json').read_text(encoding='utf-8'))
    counts=Counter()
    authored=[]
    for line in (folder/'expansion.tsv').read_text(encoding='utf-8').splitlines():
        if not line or line.startswith('#'):
            continue
        level,key,text,answer,wrong,hint,explanation=line.split('|')
        text,answer,hint,explanation=map(readable,(text,answer,hint,explanation))
        choices=[answer,*map(readable,wrong.split('~'))]
        assert len(choices)==len(set(choices))==6,(key,level)
        counts[level]+=1
        qid=f'breaking_news-{level}-{200+counts[level]:04}'
        position=len(authored)%6
        choices=choices[1:position+1]+[answer]+choices[position+1:]
        authored.append(dict(id=qid,categoryId='breaking_news',difficulty=level,
            text=text,answer=answer,acceptedAnswers=[],hint=hint,clues=[],explanation=explanation,
            sources=[f'{urls[key]} — بيان رسمي قُرئ في2026-10-13؛ المرجع يثبت الحدث والجانب المطلوب فيه، ولا يُقدّم التقدير المستقبلي كحدث وقع.'],
            options=[dict(id=chr(65+i),text=value) for i,value in enumerate(choices)],
            correctOptionId=chr(65+position),qualityStatus='unreviewed'))
    assert counts==dict.fromkeys(('easy','medium','hard','legendary'),25),counts
    assert len({q['text'] for q in authored})==100
    staging=ROOT/'tool/staging'
    staging.mkdir(parents=True,exist_ok=True)
    (staging/'breaking_news_expansion_100.json').write_text(json.dumps(authored,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(staged=len(authored),difficulties=counts,correctPositions=Counter(q['correctOptionId'] for q in authored))))

if __name__=='__main__':
    main()
