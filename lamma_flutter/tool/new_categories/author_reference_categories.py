"""Curated reference-category authoring; staging only, never production assets."""
import json, random, collections
from pathlib import Path

OUT=Path(__file__).parent
DIFFS=['easy','medium','hard','legendary']
BOOKS={}
RNG=random.Random(7319)

def add(cat,diff,text,answer,hint,explanation,source,pool,presentation=None):
    qs=BOOKS.setdefault(cat,[])
    num=1+sum(q['difficulty']==diff for q in qs)
    negatives=list(dict.fromkeys(x for x in pool if x!=answer))
    assert len(negatives)>=5,(text,answer,negatives)
    choices=RNG.sample(negatives,5)
    pos=(len(qs)*5+num//6)%6
    choices.insert(pos,answer)
    q={'id':f'{cat}-{diff}-{num:04d}','categoryId':cat,'difficulty':diff,'text':text,'answer':answer,'acceptedAnswers':[],'hint':hint,'clues':[],'explanation':explanation,'sources':source if isinstance(source,list) else [source],'options':[{'id':chr(65+i),'text':v} for i,v in enumerate(choices)],'correctOptionId':chr(65+pos),'qualityStatus':'unreviewed'}
    if presentation:q['presentation']=presentation
    qs.append(q)

def symbol_group(diff,domain,source,data,pool=None):
    rows=[r.split('|') for r in data.strip().splitlines() if r.strip()]
    if pool is None:pool=[r[1] for r in rows]
    for symbol,answer,hint in rows:
        add('symbols_signals',diff,f'في {domain}، ما دلالة الرمز المعروض؟',answer,hint,f'الرمز «{symbol}» يدل هنا على {answer}. السياق المحدد يميز هذا المعنى عن استخدامات الرمز في مجالات أخرى.',source,pool,{'type':'symbols','sections':[{'id':'symbols','title':'','items':[{'id':'s1','text':symbol}]}]})

def abbreviations(diff,domain,source,data):
    rows=[r.split('|') for r in data.strip().splitlines() if r.strip()]
    pool=[r[1] for r in rows]
    for short,answer,hint in rows:
        add('abbreviations',diff,f'في {domain}، إلى ماذا يشير الاختصار {short}؟',answer,hint,f'{short} هو الاختصار المستخدم في هذا السياق لـ«{answer}».',source,pool)

def facts(diff,source,data,pool=None):
    rows=[r.split('|') for r in data.strip().splitlines() if r.strip()]
    if pool is None:pool=[r[1] for r in rows]
    for text,answer,hint,explanation in rows:
        add('currency_stories',diff,text,answer,hint,explanation,source,pool)

def save():
    reports={}
    for cat,qs in BOOKS.items():
        if cat=='abbreviations':
            from audit_reference_abbreviation_options import findings
            assert not findings(qs),findings(qs)
        counts=collections.Counter(q['difficulty'] for q in qs)
        ids=[q['id'] for q in qs]
        assert len(ids)==len(set(ids))
        # A question consists of text plus displayed elements; generic prompts alone aren't duplicates.
        identities=[json.dumps([q['text'],q.get('presentation'),q.get('imageAsset')],ensure_ascii=False,sort_keys=True) for q in qs]
        assert len(identities)==len(set(identities)),cat
        for q in qs:
            assert all(isinstance(o['text'],str) and o['text'].strip() for o in q['options']), ('Empty option text',q['id'])
            assert len(q['options'])==6 and len(set(o['text'] for o in q['options']))==6
            assert next(o['text'] for o in q['options'] if o['id']==q['correctOptionId'])==q['answer']
            assert q['hint'] and q['explanation'] and q['sources']
        obj={'schemaVersion':1,'categoryId':cat,'targetCount':300,'targetPerDifficulty':75,'status':'draft','questions':qs}
        (OUT/f'{cat}.json').write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        reports[cat]={'count':len(qs),'difficulty':dict(counts),'correctOptionId':dict(collections.Counter(q['correctOptionId'] for q in qs)),'reviewed':0,'uniquePromptAndPresentation':len(set(identities))}
    (OUT/'reference_categories_validation.json').write_text(json.dumps(reports,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(reports,ensure_ascii=False))

