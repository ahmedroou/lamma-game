"""Twenty constrained two-pair questions, one unknown at either side."""
from pathlib import Path
import json,random
from relational_authoring import question
OUT=Path(__file__).parent
R=random.Random(207513)
facts=json.loads((OUT/'relational_direct_facts.json').read_text(encoding='utf-8'))
basic=facts['units'][:7]
catalog=json.loads((OUT/'relational_fact_pools.json').read_text(encoding='utf-8'))
geo=[g for g in catalog if g['domain'].startswith('تقسيمات M49')]
region_for={country:g['label'] for g in geo for country in g['items']}
unit_recipes=[
 ('كيلوغرام','متر'),('ثانية','كيلوغرام'),('متر','ثانية'),('كيلوغرام','أمبير'),('ثانية','كلفن'),
 ('متر','أمبير'),('ثانية','أمبير'),('كيلوغرام','كلفن'),('متر','كلفن'),('أمبير','كلفن'),
]
geo_recipes=[
 ('مصر','اليابان'),('فرنسا','كازاخستان'),('الهند','المكسيك'),('البرازيل','اليونان'),('الجزائر','منغوليا'),
 ('الصين','إسبانيا'),('تونس','بولندا'),('السعودية','باكستان'),('إيطاليا','تايلاند'),('ألمانيا','الأرجنتين'),
]
byunit={x['left']:x for x in basic}
data=json.loads((OUT/'pair_up.json').read_text(encoding='utf-8'))
replacements=[]
for difficulty,recipes in [('easy',unit_recipes),('medium',geo_recipes)]:
    for n,(known,target) in enumerate(recipes,1):
        reverse=n%2==0
        if difficulty=='easy':
            known_value=byunit[known]['right'];target_value=byunit[target]['right']
            # The task is explicitly about the seven basic SI units only.
            candidates=[u['left'] for u in basic if u['left']!=known]
            source=byunit[target]['source']
            prompt='طابق وحدات SI الأساسية مع كمياتها الأساسية. أكمل الطرف الناقص ثم اذكر الزوجين كاملين.'
            hint='حدد نوع الكمية؛ المطلوب إحدى وحدات SI الأساسية السبع، وليس وحدة مشتقة.'
            explanation=f'في جدول الوحدات الأساسية، {known} وحدة {known_value}، و{target} وحدة {target_value}. لذلك فإن مقابل {target_value} الوحيد ضمن الوحدات الأساسية السبع هو {target}.'
            if reverse:
                left_known=known;right_known=known_value;missing_value=target;right_target=target_value
            else:
                left_known=known_value;right_known=known;left_target=target_value;missing_value=target
        else:
            known_value=region_for[known];target_value=region_for[target]
            assert known_value!=target_value
            asian=['شرق آسيا','وسط آسيا','جنوب آسيا','جنوب شرق آسيا','غرب آسيا','شرق أوروبا','شمال إفريقيا','ميلانيزيا']
            european=['جنوب أوروبا','غرب أوروبا','شرق أوروبا','شمال أوروبا','غرب آسيا','شمال إفريقيا','وسط آسيا']
            american=['أمريكا الوسطى','أمريكا الجنوبية','الكاريبي','غرب أوروبا','شمال إفريقيا','غرب إفريقيا','جنوب أوروبا']
            proximity=asian if 'آسيا' in target_value else european if 'أوروبا' in target_value else american
            choices=[label for label in proximity if label not in (known_value,target_value)]
            candidates=[target_value]+choices[:5]
            source=geo[0]['source']
            prompt='طابق البلدين مع منطقتيهما في تقسيم M49 للأمم المتحدة. أكمل اسم المنطقة الناقص ثم اذكر الزوجين كاملين؛ المطلوب المنطقة المذكورة في التقسيم، وليس القارة.'
            hint='قارن الموقع الجغرافي للبلد بالمنطقة؛ اعتمد تقسيم الأمم المتحدة بدل تعميم القارات.'
            explanation=f'يصنف M49 {known} في {known_value} و{target} في {target_value}. لكل من البلدين موضع واحد في تقسيم المناطق المستخدم هنا، والمفقود اسم المنطقة التي تضم {target}.'
            if reverse:
                left_known=known_value;right_known=known;missing_value=target_value;right_target=target
            else:
                left_known=known;right_known=known_value;left_target=target;missing_value=target_value
        R.shuffle(candidates)
        if reverse:
            answer=f'{left_known} ← {right_known}؛ {missing_value} ← {right_target}'
            wrong=[f'{left_known} ← {right_known}؛ {candidate} ← {right_target}' for candidate in candidates if candidate!=missing_value]
            left=[dict(id='l1',text=left_known),dict(id='l2',text='؟',missing=True)]
            right=[dict(id='r1',text=right_target),dict(id='r2',text=right_known)]
        else:
            answer=f'{left_known} ← {right_known}؛ {left_target} ← {missing_value}'
            wrong=[f'{left_known} ← {right_known}؛ {left_target} ← {candidate}' for candidate in candidates if candidate!=missing_value]
            left=[dict(id='l1',text=left_known),dict(id='l2',text=left_target)]
            right=[dict(id='r1',text='؟',missing=True),dict(id='r2',text=right_known)]
        presentation=dict(type='matching',sections=[dict(id='left',title='الأطراف الأولى',items=left),dict(id='right',title='الأطراف المقابلة',items=right)])
        q=question('pair_up',difficulty,n,prompt,answer,hint,explanation,[source],wrong,presentation)
        index=next(i for i,x in enumerate(data['questions']) if x['id']==q['id'])
        # Preserve the option-location balance of the record being replaced.
        correct=data['questions'][index]['correctOptionId']
        if q['correctOptionId']!=correct:
            old_slot=next(o for o in q['options'] if o['id']==q['correctOptionId'])
            new_slot=next(o for o in q['options'] if o['id']==correct)
            old_slot['text'],new_slot['text']=new_slot['text'],old_slot['text'];q['correctOptionId']=correct
        data['questions'][index]=q
        replacements.append(dict(id=q['id'],family='SI basic' if difficulty=='easy' else 'M49',missingSide='left' if reverse else 'right',pairCount=2))
(OUT/'pair_up.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(OUT/'relational_two_pair_revision.json').write_text(json.dumps(replacements,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(replacements,ensure_ascii=False,indent=2))
