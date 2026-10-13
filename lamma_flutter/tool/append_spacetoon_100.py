"""Package 100 handwritten, source-read questions; no numeric fact generation."""
import json,re,unicodedata,sys
from pathlib import Path
from collections import Counter
ROOT=Path(__file__).resolve().parents[1]
def plain(t):return re.sub(r'\s+',' ',''.join(c for c in t if not unicodedata.combining(c) and c!='ـ')).strip()
def main():
    sources={}
    for file in ['spacetoon_official_source.json','spacetoon_bluey_source.json','spacetoon_masha_characters_source.json','spacetoon_modern_source.json']:
        for q in json.loads((ROOT/'tool'/file).read_text(encoding='utf8')):
            if 'text' in q:sources['np-'+str(q['id']) if isinstance(q['id'],int) else q['id']]=q['url']
    p=ROOT/'assets/questions/spacetoon.json';original=p.read_bytes();bank=json.loads(original)
    old=[q for q in bank['questions'] if int(q['id'].rsplit('-',1)[-1])<=200];assert len(old)==800
    seen={plain(q['text']) for q in old};new=[]
    aliases={'بينغو':['Bingo','بنجو'],'بلوي':['Bluey','بلووي'],'بانديت':['Bandit'],'تشيلي':['Chilli'],'سوكس':['Socks'],'ليلا':['Lila'],'هاني':['Honey'],'كلوي':['Chloe'],'وينتون':['Winton'],'سنيكرز':['Snickers'],'كاليبسو':['Calypso'],'فلوبّي':['Floppy'],'ماري':['Mary'],'هيكتور مالو':['Hector Malot'],'ليزا تتسنر':['Lisa Tetzner'],'يوهان دافيد فيس':['Johann David Wyss']}
    for i,line in enumerate((ROOT/'tool/spacetoon_expansion_20261013.tsv').read_text(encoding='utf8').splitlines()):
        key,text,answer,hint,explanation,wrong=line.split('|');key=key.lower()
        assert key in sources,key
        difficulty=['easy','medium','hard','legendary'][i//25];qid=f'spacetoon-{difficulty}-{201+i%25:04d}'
        vals=wrong.split(';');assert len(vals)==5
        position=i%6;vals.insert(position,answer)
        assert len({plain(t) for t in vals})==6,qid
        assert plain(text) not in seen,qid;seen.add(plain(text))
        assert plain(answer) not in plain(hint),qid
        source=[sources[key]+' — صفحة المنتج/صاحب الشخصيات، قرئت في 2026-10-13.']
        if key.startswith('char-') or key.startswith('ep-'):source.append('https://www.youtube.com/watch?v=zxjM6VO21MM — إعلان بلوي على قناة سبيستون الرسمية في فقرة أنا وطفلي (2024).')
        new.append(dict(id=qid,categoryId='spacetoon',difficulty=difficulty,text=text,answer=answer,
                        acceptedAnswers=aliases.get(answer,[]),hint=hint,clues=[],explanation=explanation,
                        sources=source,options=[dict(id=chr(65+j),text=t) for j,t in enumerate(vals)],
                        correctOptionId=chr(65+position),qualityStatus='reviewed'))
    assert len(new)==100
    assert Counter(q['difficulty'] for q in new)==dict.fromkeys(['easy','medium','hard','legendary'],25)
    if '--staging' in sys.argv:
        folder=ROOT/'tool/staging';folder.mkdir(exist_ok=True)
        (folder/'spacetoon_expansion_100.json').write_text(json.dumps(dict(categoryId='spacetoon',questions=new),ensure_ascii=False,indent=2)+'\n',encoding='utf8')
        print('spacetoon STAGED',len(new));return
    assert p.read_bytes()==original,'Concurrent edit detected'
    bank.update(targetCount=900,targetPerDifficulty=225,status='draft',questions=old+new)
    p.write_text(json.dumps(bank,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    print('spacetoon',len(bank['questions']),Counter(q['difficulty'] for q in bank['questions']))
if __name__=='__main__':main()
