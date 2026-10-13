"""Stage independently authored country-flag questions; never writes assets."""
import json,re,unicodedata,hashlib
from pathlib import Path
from collections import Counter
ROOT=Path(__file__).resolve().parents[1]
SOURCES={
 'ca':'https://www.canada.ca/en/canadian-heritage/services/flag-canada-etiquette/flying-rules.html',
 'capos':'https://www.canada.ca/en/canadian-heritage/services/flag-canada-etiquette/position-honour.html',
 'caforeign':'https://www.canada.ca/en/canadian-heritage/services/flag-canada-etiquette/foreign-flags.html',
 'au':'https://www.pmc.gov.au/honours-and-symbols/australian-national-symbols/australian-national-flag/australian-national-flag-protocols',
 'ie':'https://tfmfoundation.ie/the-flag-protocol/',
 'za':'https://www.gov.za/ss/about-sa/national-flag-0',
 'za2001':'https://www.gov.za/sites/default/files/22356.pdf',
 'us7':'https://www.govinfo.gov/content/pkg/USCODE-2018-title4/html/USCODE-2018-title4-chap1-sec7.htm',
 'de2005':'https://www.verwaltungsvorschriften-im-internet.de/bsvwvbund_22032005_Z4a1150415.htm',
 'gb2026':'https://www.gov.uk/guidance/designated-days-for-union-flag-flying'
}
def norm(t):return re.sub(r'\s+',' ',''.join(c for c in t if not unicodedata.combining(c) and c!='ـ')).strip()
def main():
    old=json.loads((ROOT/'assets/questions/flags.json').read_text(encoding='utf8'))['questions'];seen={norm(q['text']) for q in old if int(q['id'].rsplit('-',1)[-1])<=200}
    p=ROOT/'tool/flags_expansion_20261013.tsv';lines=p.read_text(encoding='utf8').splitlines();assert len(lines)==100
    new=[]
    for i,line in enumerate(lines):
        key,text,answer,hint,explanation,wrong=line.split('|');text=re.sub(r'([\u0600-\u06ff])(?=\d)',r'\1 ',text);text=re.sub(r'(\d)(?=[\u0600-\u06ff])',r'\1 ',text)
        answer=answer.replace('؛','').strip();wrong=[t.replace('؛','').strip() for t in wrong.split(';')]
        assert len(wrong)==5 and len({norm(t) for t in [answer,*wrong]})==6,(i,wrong)
        assert norm(text) not in seen,(i,text);seen.add(norm(text))
        assert norm(answer) not in norm(hint),(i,answer,hint)
        difficulty=['easy','medium','hard','legendary'][i//25];qid=f'flags-{difficulty}-{201+i%25:04d}'
        position=i%6;vals=wrong[:];vals.insert(position,answer)
        new.append(dict(id=qid,categoryId='flags',difficulty=difficulty,text=text,answer=answer,acceptedAnswers=[],hint=hint,clues=[],explanation=explanation,
                        sources=[SOURCES[key]+' — المصدر/النسخة المبينة في نص السؤال؛ قرئت الصفحة في 2026-10-13.'],
                        options=[dict(id=chr(65+j),text=t) for j,t in enumerate(vals)],correctOptionId=chr(65+position),qualityStatus='reviewed'))
    assert Counter(q['difficulty'] for q in new)==dict.fromkeys(['easy','medium','hard','legendary'],25)
    folder=ROOT/'tool/staging';folder.mkdir(exist_ok=True);out=folder/'flags_expansion_100.json'
    out.write_text(json.dumps(dict(categoryId='flags',questions=new),ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    print('flags STAGED',len(new),hashlib.sha256(out.read_bytes()).hexdigest())
if __name__=='__main__':main()
