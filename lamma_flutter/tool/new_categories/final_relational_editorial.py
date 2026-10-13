"""Symmetric option wording and cautious difficulty swaps of existing content."""
import json,re,collections
from pathlib import Path
import ast
OUT=Path(__file__).parent
parsed=ast.parse((OUT/'polish_relational_banks.py').read_text(encoding='utf-8'))
EASY_BOOKS=next(ast.literal_eval(node.value) for node in parsed.body if isinstance(node,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='EASY_BOOKS' for t in node.targets))
changes=collections.Counter()
path=OUT/'relationship.json';data=json.loads(path.read_text(encoding='utf-8'))
for q in data['questions']:
    if 'ما الجائزة' in q['text']:
        for option in q['options']:
            if option['text'].startswith('هذه مساهمة وردت في تعليل منح '):
                option['text']='نال '+option['text'].removeprefix('هذه مساهمة وردت في تعليل منح ')+' تقديرًا لهذه المساهمة'
        changes['award_option_sets_naturalized']+=1
    elif 'كيف يرتبط' in q['text']:
        for option in q['options']:
            if ' وحدة SI لقياس ' in option['text']:
                actor,quantity=option['text'].split(' وحدة SI لقياس ',1)
                option['text']=actor+' وحدة قياس '+quantity+' في النظام الدولي'
        changes['unit_option_sets_naturalized']+=1
    elif 'ما الصلة الأدبية' in q['text']:
        book,author=re.findall('«([^»]+)»',q['text'])
        choices=[f'«{author}» كتب «{book}»',f'«{author}» ترجم «{book}» إلى العربية',f'«{author}» شخصية داخل «{book}»',f'«{author}» أخرج أول اقتباس سينمائي لـ«{book}»',f'«{author}» نشر أول طبعة لـ«{book}»',f'«{author}» كتب الرواية التي اقتُبس منها «{book}»']
        q['answer']=choices[0]
        wrong=iter(choices[1:])
        for option in q['options']:option['text']=q['answer'] if option['id']==q['correctOptionId'] else next(wrong)
        changes['book_option_sets_naturalized']+=1
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

path=OUT/'split_groups.json';data=json.loads(path.read_text(encoding='utf-8'));qs=data['questions']
def displayed(q):return [i['text'] for s in q['presentation']['sections'] for i in s['items']]
def clearly_advanced(q):
    if 'ألّف' in q['text']:return sum(i not in EASY_BOOKS for i in displayed(q))>=3
    if 'M49' in q['text']:return any(x in q['answer'] for x in ['بولينيزيا:','ميلانيزيا:','ميكرونيزيا:'])
    return False
def accessible(q):
    if 'M49' not in q['text']:return False
    excluded=['بولينيزيا:','ميلانيزيا:','ميكرونيزيا:','وسط إفريقيا:','شرق إفريقيا:','جنوب إفريقيا:','غرب إفريقيا:']
    return not any(x in q['answer'] for x in excluded)
easy=[q for q in qs if q['difficulty']=='easy' and clearly_advanced(q)]
medium=[q for q in qs if q['difficulty']=='medium' and accessible(q)]
for a,b in zip(easy,medium):
    identity_keys=['id','categoryId','difficulty']
    ai={k:a[k] for k in identity_keys};bi={k:b[k] for k in identity_keys}
    abody={k:v for k,v in a.items() if k not in identity_keys};bbody={k:v for k,v in b.items() if k not in identity_keys}
    a.clear();a.update(ai);a.update(bbody)
    b.clear();b.update(bi);b.update(abody)
    changes['easy_medium_content_swaps']+=1
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(OUT/'relational_final_editorial_changes.json').write_text(json.dumps(dict(changes),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(dict(changes))
