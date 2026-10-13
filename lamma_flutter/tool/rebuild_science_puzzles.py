"""Original constraint problems; preserves good rows and stable quarantined IDs.

These records are draft/unreviewed: exhaustive solution checks are not an
editorial certification. No external service or gameplay state is touched.
"""
from pathlib import Path
from collections import Counter, deque
from fractions import Fraction as F
from itertools import product, permutations, combinations
import random, json, math, hashlib, re

ROOT=Path(__file__).resolve().parents[1]
RNG=random.Random(20261013)
LEVELS=['easy','medium','hard','legendary']
LEDGER=[]
def num(x):
    x=F(x)
    return str(x.numerator) if x.denominator==1 else f'{x.numerator}/{x.denominator}'
def choices(answer, wrong, seed):
    vals=list(dict.fromkeys([answer,*wrong]))
    assert len(vals)>=6,(answer,wrong)
    vals=vals[:6]; random.Random(seed).shuffle(vals)
    return [dict(id=chr(65+i),text=v) for i,v in enumerate(vals)],chr(65+vals.index(answer))
def problem(text,answer,wrong,hint,explanation,sources=None,proof=None):
    options,correct=choices(answer,wrong,text)
    assert len(answer.split())<3 or answer not in hint
    return dict(text=text,answer=answer,acceptedAnswers=[],hint=hint,clues=[],
                explanation=explanation,sources=sources or ['مسألة أصلية؛ التحقق المستقل: '+explanation],
                options=options,correctOptionId=correct,qualityStatus='unreviewed',_proof=proof)
def numeric(text,answer,hint,explanation,unit='',sources=None,proof=None):
    a=F(answer); wrong=[]
    for d in [1,-1,2,-2,3,-3,F(1,2),F(-1,2),4,-4,5,-5]:
        b=a+d
        if b>=0 and b!=a:wrong.append(num(b)+unit)
    return problem(text,num(a)+unit,wrong,hint,explanation,sources,proof)
def bits(b):return ''.join(map(str,b))
def ordertext(p):return ' ← '.join(p)
def keep_minimal(candidates,rules,truth):
    RNG.shuffle(rules)
    for r in rules[:]:
        test=[x for x in rules if x is not r]
        if len([c for c in candidates if all(t[1](c) for t in test)])==1: rules.remove(r)
    out=[c for c in candidates if all(r[1](c) for r in rules)]
    assert out==[truth]
    return rules

def knights(level,k):
    n={'easy':3,'medium':3,'hard':4,'legendary':5}[level]; labels=list('أبجدهو')[:n]
    while True:
        rules=[]; exprs=[]
        for i in range(n):
            j,h=RNG.sample(range(n),2); kind=RNG.choice(['eq','xor','both','either','not','implies'])
            if kind=='eq': f=lambda b,j=j,h=h:b[j]==b[h]; t=f'{labels[j]} و{labels[h]} من النوع نفسه'
            elif kind=='xor':f=lambda b,j=j,h=h:b[j]!=b[h];t=f'{labels[j]} و{labels[h]} من نوعين مختلفين'
            elif kind=='both':f=lambda b,j=j,h=h:b[j] and b[h];t=f'{labels[j]} و{labels[h]} كلاهما صادق'
            elif kind=='either':f=lambda b,j=j,h=h:b[j] or b[h];t=f'أحد {labels[j]} و{labels[h]} على الأقل صادق'
            elif kind=='not':f=lambda b,j=j:not b[j];t=f'{labels[j]} كاذب'
            else:f=lambda b,j=j,h=h:not b[j] or b[h];t=f'إذا كان {labels[j]} صادقًا فإن {labels[h]} صادق'
            rules.append(f);exprs.append(f'{labels[i]}: «{t}».')
        sol=[b for b in product([0,1],repeat=n) if all(bool(b[i])==bool(rules[i](b)) for i in range(n))]
        if len(sol)==1 and 0<sum(sol[0])<n:break
    def desc(b):return 'الصادقون: '+ '، '.join(labels[i] for i in range(n) if b[i]) if any(b) else 'الجميع كاذبون'
    ans=desc(sol[0]);wrong=[desc(b) for b in product([0,1],repeat=n) if b!=sol[0]]
    proof={'engine':'truth','n':n,'solution':list(sol[0]),'statements':exprs}
    exp='اعتُبرت كل عبارة صحيحة إذا وفقط إذا كان قائلها صادقًا. باختبار كل الاحتمالات '+str(2**n)+'، التعيين الوحيد المتسق هو '+ans+'. '
    exp+='؛ '.join(labels[i]+(' يقول الحق' if sol[0][i] else ' يقول عبارة خاطئة') for i in range(n))+'.'
    return problem('في جزيرة، كل شخص إما صادق دائمًا أو كاذب دائمًا. '+ ' '.join(exprs)+' من الصادقون؟',ans,wrong,
                   'لا يكفي تصديق عبارة منفردة؛ جرّب فرضية عن قائلها وتابع أثرها على بقية العبارات.',exp,proof=proof)

def order_puzzle(level,k):
    n={'easy':3,'medium':4,'hard':5,'legendary':6}[level]; labels=list('أبجدهو')[:n]
    candidates=list(permutations(labels)); truth=RNG.choice(candidates); pos={a:truth.index(a) for a in labels};rules=[]
    for a,b in combinations(labels,2):
        if pos[a]<pos[b]:rules.append((f'{a} قبل {b}',lambda p,a=a,b=b:p.index(a)<p.index(b)))
        else:rules.append((f'{b} قبل {a}',lambda p,a=a,b=b:p.index(b)<p.index(a)))
        if abs(pos[a]-pos[b])==1:rules.append((f'{a} و{b} متجاوران',lambda p,a=a,b=b:abs(p.index(a)-p.index(b))==1))
        else:rules.append((f'{a} و{b} غير متجاورين',lambda p,a=a,b=b:abs(p.index(a)-p.index(b))!=1))
        if abs(pos[a]-pos[b])==2:rules.append((f'بين {a} و{b} عنصر واحد',lambda p,a=a,b=b:abs(p.index(a)-p.index(b))==2))
    rules=keep_minimal(candidates,rules,truth)
    context=RNG.choice(['متسابقون يعبرون خط النهاية دون تعادل','كتب مختلفة ترتب من اليسار إلى اليمين على رف','عربات مختلفة تمر من بوابة واحدة','عروض تقدم تباعًا على مسرح','حقائب تصطف من المقدمة إلى الخلف'])
    ans=ordertext(truth);wrong=[ordertext(p) for p in candidates if p!=truth]; RNG.shuffle(wrong)
    return problem(f'{context}، ورموزها '+ '، '.join(labels)+'. الشروط: '+ '؛ '.join(r[0] for r in rules)+'. ما ترتيبها؟ (ابدأ من الطرف المكتوب أولًا في الخيار.)',
       ans,wrong,'ابدأ بالعلاقات التي تفرض التجاور أو تفصل عنصرين؛ ثم اختبر أي طرف يمكن أن يبدأ الترتيب.',
       'فُحصت جميع التباديل '+str(math.factorial(n))+'. الترتيب الوحيد المطابق لكل الشروط هو '+ans+'. كل خيار آخر يخالف شرطًا واحدًا على الأقل.',proof={'engine':'order','n':n,'solution':list(truth),'constraints':[r[0] for r in rules]})

def lock(level,k):
    n={'easy':2,'medium':3,'hard':4,'legendary':4}[level]; digits=range(1,8 if n==3 else 7)
    cand=list(permutations(digits,n));truth=RNG.choice(cand); rules=[];names=['الأول','الثاني','الثالث','الرابع']
    for i,j in combinations(range(n),2):
        d=truth[i]-truth[j]
        if d>0:rules.append((f'الرقم {names[i]} أكبر من {names[j]}',lambda p,i=i,j=j:p[i]>p[j]))
        else:rules.append((f'الرقم {names[i]} أصغر من {names[j]}',lambda p,i=i,j=j:p[i]<p[j]))
        rules.append((f'مجموع {names[i]} و{names[j]} هو {truth[i]+truth[j]}',lambda p,i=i,j=j,s=truth[i]+truth[j]:p[i]+p[j]==s))
        rules.append((f'الفارق المطلق بين {names[i]} و{names[j]} هو {abs(d)}',lambda p,i=i,j=j,d=abs(d):abs(p[i]-p[j])==d))
    if level=='legendary':
        for i in range(n):
            a,b=(i+1)%n,(i+2)%n;val=(truth[i]*truth[a]+truth[b])%7
            rules.append((f'باقي ({names[i]}×{names[a]}+{names[b]}) عند القسمة على7 هو{val}',lambda p,i=i,a=a,b=b,val=val:(p[i]*p[a]+p[b])%7==val))
    rules=keep_minimal(cand,rules,truth);answer=bits(truth)
    wrong=sorted((p for p in cand if p!=truth),key=lambda p:sum(a!=b for a,b in zip(p,truth)))
    return problem(f'قفل برمز من {n} أرقام مختلفة، كل رقم بين1 و{max(digits)}. يُقرأ الرمز من اليسار إلى اليمين. '+ '؛ '.join(r[0] for r in rules)+'. ما الرمز؟',answer,[bits(p) for p in wrong],
       'استخدم شروط الأزواج معًا؛ وجود أرقام صحيحة في مواقع خاطئة لا يفتح القفل.',
       'بتعداد كل الرموز ذات الأرقام المختلفة، الرمز الوحيد الذي يحقق جميع المعادلات والعلاقات هو '+answer+'. '+ '؛ '.join(r[0] for r in rules)+'.',proof={'engine':'lock','solution':list(truth),'constraints':[r[0] for r in rules]})

def switches(level,k):
    n={'easy':3,'medium':3,'hard':4,'legendary':5}[level]
    while True:
        cols=[RNG.randrange(1,1<<n) for _ in range(n)]
        def output(b):
            x=0
            for i,v in enumerate(b):
                if v:x^=cols[i]
            return x
        outputs=[output(b) for b in product([0,1],repeat=n)]
        if len(set(outputs))==(1<<n):break
    t=RNG.randrange(1,1<<n); target='، '.join(str(i+1) for i in range(n) if t>>i&1)
    sol=next(b for b in product([0,1],repeat=n) if output(b)==t)
    def desc(b):return 'اضغط '+ '، '.join(chr(65+i) for i in range(n) if b[i]) if any(b) else 'لا تضغط أي زر'
    clauses=[chr(65+i)+' يقلب المصابيح '+ '، '.join(str(j+1) for j in range(n) if c>>j&1) for i,c in enumerate(cols)]
    answer=desc(sol);wrong=[desc(b) for b in product([0,1],repeat=n) if b!=sol]
    return problem(f'لوحة فيها{n} مصابيح مطفأة. كل ضغطة تقلب حالة المصابيح المرتبطة بالزر، ويُضغط كل زر مرة واحدة كحد أقصى. '+ '؛ '.join(clauses)+'. أي أزرار تترك المصابيح '+target+' مضاءة، والباقي مطفأ؟',answer,wrong,
       'المصباح ينطفئ مجددًا إذا تأثر بضغطتين؛ عدّ مرات التأثر فرديًا أو زوجيًا.',
       'تُجمع آثار الأزرار بتبديل ثنائي XOR. التعداد الكامل أعطى حلًا واحدًا: '+answer+'. فحص كل مصباح يؤكد أنه يتبدل عددًا فرديًا إذا كان مطلوبًا إضاءته وزوجيًا خلاف ذلك.',proof={'engine':'switch','columns':cols,'target':t,'solution':list(sol)})

def subset(level,k):
    n={'medium':6,'hard':7,'legendary':8}[level];labels=list('ABCDEFGH')[:n];size=3 if level=='medium' else 4
    while True:
        attributes=[tuple(RNG.randrange(1,10) for _ in range(3)) for _ in range(n)]
        chosen=tuple(sorted(RNG.sample(range(n),size)));tot=tuple(sum(attributes[i][j] for i in chosen) for j in range(3))
        sol=[c for c in combinations(range(n),size) if tuple(sum(attributes[i][j] for i in c) for j in range(3))==tot]
        if sol==[chosen]:break
    desc=lambda c:' + '.join(labels[i] for i in c)
    cases=RNG.choice([('صناديق شحن','الوزن، والحجم، وعدد القطع'),('وجبات مصغّرة','وحدات البروتين، والكربوهيدرات، والدهون'),('قطع لبناء جهاز','وحدات الكلفة، والطاقة، والمساحة'),('حقائب رحلة','وحدات الوزن، والأدوات، والطعام')])
    table='؛ '.join(labels[i]+': ('+', '.join(map(str,a))+')' for i,a in enumerate(attributes))
    return problem(f'لديك {cases[0]}؛ ثلاثية كل صندوق تذكر {cases[1]} على الترتيب: '+table+f'. مطلوب اختيار{size} صناديق مختلفة مجموعها بالترتيب ('+', '.join(map(str,tot))+'). ما المجموعة؟',desc(chosen),[desc(c) for c in combinations(range(n),size) if c!=chosen],
       'المطابقة في المجموع الأول وحده لا تكفي؛ طبّق المجاميع الثلاثة على المجموعة نفسها.',
       'تجمع المجموعة '+desc(chosen)+' إلى ('+', '.join(map(str,tot))+') بالترتيب. التعداد الكامل للمجموعات ذات الحجم المحدد لم يعط مجموعة ثانية تطابق المجاميع الثلاثة.',proof={'engine':'subset','attributes':attributes,'size':size,'target':tot,'solution':chosen})

def secret(level,k):
    # Different logical relations, not altered names/numbers in a stock riddle.
    n={'easy':3,'medium':4,'hard':5,'legendary':6}[level];labels=list('أبجدهو')[:n];candidates=list(product([0,1],repeat=n))
    truth=RNG.choice([c for c in candidates if any(c) and not all(c)]);rules=[]
    for i,j in combinations(range(n),2):
        if truth[i]==truth[j]:rules.append((f'{labels[i]} و{labels[j]} إما معًا أو لا أحد منهما',lambda b,i=i,j=j:b[i]==b[j]))
        else:rules.append((f'واحد فقط من {labels[i]} و{labels[j]} حاضر',lambda b,i=i,j=j:b[i]!=b[j]))
        if not truth[i] or truth[j]:rules.append((f'حضور {labels[i]} يستلزم حضور {labels[j]}',lambda b,i=i,j=j:not b[i] or b[j]))
    for inds in combinations(range(n),3):
        total=sum(truth[i] for i in inds)
        rules.append(('عدد الحاضرين بين '+ '، '.join(labels[i] for i in inds)+f' هو{total}',lambda b,inds=inds,total=total:sum(b[i] for i in inds)==total))
    rules=keep_minimal(candidates,rules,truth)
    desc=lambda b: '، '.join(labels[i] for i in range(n) if b[i]) if any(b) else 'لم يحضر أحد'
    return problem('اجتماع مغلق لأشخاص رموزهم '+ '، '.join(labels)+'. يعلم الحارس الشروط الآتية فقط: '+ '؛ '.join(r[0] for r in rules)+'. من حضر؟',desc(truth),[desc(b) for b in candidates if b!=truth],
                   'الاستلزام لا يعني العكس؛ غياب الشخص الأول لا يفرض غياب الثاني.',
                   'فُحصت كل المجموعات الممكنة. المجموعة '+desc(truth)+' تحقق الشروط جميعًا، ولا تحققها مجموعة أخرى.',proof={'engine':'secret','n':n,'solution':list(truth),'constraints':[r[0] for r in rules]})

def graph_data(n):
    # Weighted topology includes genuine different paths and junctions.
    edges=[]
    for i in range(n-1):edges.append((i,i+1,RNG.randrange(2,10)))
    for i,j in combinations(range(n),2):
        if j>i+1 and RNG.random()<.30:edges.append((i,j,RNG.randrange(2,13)))
    return edges
def all_paths(n,edges,start=0,end=None):
    end=n-1 if end is None else end;adj={i:[] for i in range(n)}
    for a,b,w in edges:adj[a].append((b,w));adj[b].append((a,w))
    result=[]
    def dfs(at,path,cost):
        if at==end:result.append((tuple(path),cost));return
        for nxt,w in adj[at]:
            if nxt not in path:dfs(nxt,path+[nxt],cost+w)
    dfs(start,[start],0);return result
def graph_problem(level,k,category='riddles'):
    n={'medium':5,'hard':6,'legendary':7}[level];labels=list('ABCDEFG')[:n]
    while True:
        edges=graph_data(n); paths=all_paths(n,edges)
        mode=RNG.choice(['via','avoid','few','budget'])
        m=RNG.randrange(1,n-1)
        valid=[];extra=''
        if mode=='via':valid=[p for p in paths if m in p[0]];extra=f'يجب المرور بالمحطة{labels[m]}'
        elif mode=='avoid':valid=[p for p in paths if m not in p[0]];extra=f'المحطة{labels[m]} مغلقة ولا يجوز المرور بها'
        elif mode=='few':
            limit=RNG.randrange(3,n);valid=[p for p in paths if len(p[0])-1<=limit];extra=f'لا يجوز استخدام أكثر من{limit} وصلات'
        else:
            # Two required waypoints changes topology of the constrained task.
            x,y=RNG.sample(range(1,n-1),2);valid=[p for p in paths if x in p[0] and y in p[0] and p[0].index(x)<p[0].index(y)];extra=f'يجب زيارة{labels[x]} ثم{labels[y]} بهذا الترتيب'
        if valid:
            best=min(p[1] for p in valid);opt=[p for p in valid if p[1]==best]
            if len(opt)==1 and len(paths)>=6:break
    desc=lambda p:' → '.join(labels[i] for i in p)
    sol=opt[0];wrong=sorted((p for p in paths if p[0]!=sol[0]),key=lambda p:abs(p[1]-best))
    network='؛ '.join(f'{labels[a]}↔{labels[b]}: {w}' for a,b,w in edges)
    context='خريطة طرق خيالية؛ الأعداد أزمنة بالثواني' if category=='maps' else 'نفق هروب له غرف؛ الأعداد زمن عبور الممر بالدقائق'
    return problem(f'{context}، والروابط الثنائية الوحيدة هي: '+network+f'. من{labels[0]} إلى{labels[-1]}، '+extra+'. اختر الطريق الأقل زمنًا دون تكرار محطة.',desc(sol[0]),[desc(p[0]) for p in wrong],
       'الوصلة الأقصر الآن قد تفرض التفافًا لاحقًا؛ افحص الطريق كاملًا مع شرط المرور.',
       'جُمعت كلفة كل طريق بسيط يحقق الشرط. الطريق '+desc(sol[0])+f' مجموع زمنه{best}، وهو الأقل وحده بين الطرق المسموح بها.',proof={'engine':'graph','n':n,'edges':edges,'mode':mode,'extra':extra,'solution':list(sol[0]),'cost':best})

LATERAL=[
('تريد قطع قالب مستطيل إلى ثماني قطع متساوية الحجم بثلاث قطوع مستوية فقط، ويجوز ترتيب القطع فوق بعضها. كيف؟','اقطع نصفين، رصّهما واقطعهما، ثم رصّ الأرباع واقطعها','ثلاث قطوع متوازية دون رص|قطعان طوليان ثم قطوع قطرية|قطع الزوايا الثلاث فقط|قطع واحد في الوسط واثنان في الأطراف|ثلاث قطوع تمر من الحافة نفسها','فكّر في تأثير القطع الواحد بعد إعادة ترتيب ما قُطع.','كل قطع ينصف جميع القطع المكدسة فيضاعف عددها:2 ثم4 ثم8.'),
('ثلاثة صناديق مغلقة ملصقاتها: تفاح، برتقال، خليط. كل ملصق خاطئ. يسمح بسحب ثمرة واحدة من صندوق واحد لتحديد الثلاثة. من أي صندوق تسحب؟','الصندوق المكتوب عليه خليط','الصندوق المكتوب عليه تفاح|الصندوق المكتوب عليه برتقال|أي صندوق بلا فرق|يجب السحب من صندوقين|لا تكفي ثمرة واحدة','ابدأ بالصندوق الذي يضمن ملصقه الخاطئ تجانس محتواه.','صندوق الخليط لا يمكن أن يكون خليطًا؛ الثمرة تحدد نوعه، ثم تُحسم الصناديق الأخرى باشتراط خطأ كل ملصق.'),
('شخصان أمام باب؛ أحدهما يصدق دائمًا والآخر يكذب دائمًا. أحد بابين يؤدي إلى الخروج. تسأل واحدًا مرة واحدة وتستطيع الإشارة للباب. أي سؤال يضمن معرفة باب الخروج؟','أي باب سيقول الآخر إنه باب الخروج؟ ثم اختر المقابل','أي باب هو الخروج؟ ثم اختر المشار إليه|هل أنت الصادق؟ ثم اختر اليمين|هل الآخر يكذب؟ ثم اختر اليسار|هل هذا باب الخروج؟ ثم اختر نعم|أي باب تفضّل؟ ثم اختر المقابل','اجعل جواب الشخص يتضمن أثر طريقة كلام الآخر.','الصادق ينقل كذبة الآخر، والكاذب يحرّف جواب الصادق؛ كلاهما يشير للباب الخطأ، فتختار المقابل.'),
('أمامك3 مفاتيح لمصباح متوهج في غرفة مغلقة. تستطيع التعامل مع المفاتيح ثم دخول الغرفة مرة واحدة. كيف تحدد مفتاحه؟','شغّل الأول ثم أطفئه، وشغّل الثاني، وافحص الضوء والحرارة','شغّل الثلاثة ثم افحص الضوء|شغّل الأول فقط ثم افحص الضوء|أطفئ الثلاثة ثم افحص الضوء|شغّل الثاني والثالث ثم افحص الضوء|بدّل الأول والثاني معًا ثم افحص الضوء','توجد خاصية محسوسة للمصباح حتى بعد إطفائه.','المضيء للثاني، والمطفأ الدافئ للأول، والمطفأ البارد للثالث؛ يشترط مصباحًا متوهجًا يسخن ووقتًا كافيًا.'),
('ساعة رملية مدتها7 دقائق وأخرى11 دقيقة. بدأتا معًا. عند فراغ الأولى قلبتها، وعند فراغ الثانية بدأت المهمة. متى توقفها لقياس3 دقائق بالضبط؟','عند فراغ ساعة7 دقائق للمرة الثانية','عند فراغ ساعة11 دقائق للمرة الثانية|عند قلب ساعة11 دقائق لأول مرة|عند فراغ ساعة7 دقائق للمرة الثالثة|بعد قلب الساعتين معًا مرة أخرى|عند فراغ الساعتين معًا','تتبّع الأوقات منذ البداية بدلًا من إضافة مدد الساعتين.','الأولى تفرغ عند7 ثم14، والثانية عند11؛ المدة من11 إلى14 ثلاث دقائق.'),
('حبلان، يحترق كل منهما في ساعة لكن بمعدل غير منتظم. أشعلت الأول من طرفيه والثاني من طرف واحد. عند انتهاء الأول أشعلت الطرف الآخر للثاني. ما المدة الإجمالية؟','45 دقيقة','30 دقيقة|35 دقيقة|40 دقيقة|50 دقيقة|60 دقيقة','الإشعال من طرفين يقسم زمن الاحتراق المتبقي إلى نصفين ولو تفاوتت سماكة الحبل.','الأول ينتهي بعد30 دقيقة، وفي الثاني30 دقيقة احتراق متبقية؛ إشعال الطرف الآخر يخفضها إلى15، فالإجمالي45.'),
('أربعة أصدقاء يسلّم كل واحد منهم على الآخرين مرة واحدة دون أن يسلّم على نفسه. كم مصافحة تمت؟','6 مصافحات','4 مصافحات|5 مصافحات|7 مصافحات|8 مصافحات|12 مصافحة','عدّ الأزواج، وتجنب عدّ المصافحة نفسها من الطرفين.','كل مصافحة زوج غير مرتب:4×3÷2=6.'),
('في سباق دون تعادل تجاوزت صاحب المركز الثاني، ولم يحدث تجاوز آخر في اللحظة نفسها. ما مركزك الآن؟','الثاني','الأول|الثالث|الرابع|قبل الأخير|الأخير','تأخذ موضع الشخص الذي تجاوزته، ولا تتجاوز من أمامه تلقائيًا.','صاحب المركز الأول بقي أمامك، وأنت أخذت المركز الثاني.'),
('ما أقل عدد من الأشخاص اللازم لضمان أن اثنين وُلدا في شهر واحد، دون اعتبار السنة؟','13 شخصًا','11 شخصًا|12 شخصًا|14 شخصًا|15 شخصًا|24 شخصًا','اعتبر الشهور صناديق وأماكن الميلاد عناصر موزعة بينها.','يمكن توزيع12 شخصًا على12 شهرًا؛ الشخص13 يشارك شهرًا حتمًا.'),
('صندوق فيه جوارب حمراء وزرقاء بكميات كبيرة. تسحب في الظلام دون تمييز اللون. ما أقل عدد يضمن زوجًا من اللون نفسه؟','3 جوارب','جوربان|4 جوارب|5 جوارب|6 جوارب|جورب واحد','ابن أسوأ حالة قبل السحبة التي تضمن التكرار.','أول اثنين قد يختلفان؛ الثالث يطابق أحد اللونين حتمًا.'),
('سلم له10 درجات. تقف على الدرجة السادسة من الأسفل. كم درجة تقع فوقك؟','4 درجات','3 درجات|5 درجات|6 درجات|7 درجات|10 درجات','لا تحسب الدرجة التي تقف عليها ضمن ما هو فوقك.','الدرجات7 و8 و9 و10 أربع درجات.'),
('كيس فيه عشر كرات بيضاء وعشر سوداء. ما أقل سحب أعمى يضمن ثلاث كرات من لون واحد؟','5 كرات','3 كرات|4 كرات|6 كرات|7 كرات|8 كرات','ما أكبر عدد يمكن سحبه مع بقاء كل لون أقل من ثلاثة؟','يمكن سحب اثنتين من كل لون فقط دون ثلاث متشابهة؛ الخامسة تضمن اللون الثالث.'),
('قلم وممحاة سعرهما معًا11 ريالًا، والقلم أغلى من الممحاة9 ريالات. كم سعر الممحاة؟','ريال واحد','ريالان|3 ريالات|4 ريالات|5 ريالات|نصف ريال','بعد طرح فرق السعر يبقى ثمن عنصرين متساويين.','إذا كان ثمن الممحاة س فالقلم س+9، ولذلك2س+9=11 ومنه س=1.'),
('عامل ينجز طلاء جدار في ساعتين وآخر في3 ساعات بمعدل ثابت. يعملان معًا على الجدار نفسه دون إعاقة. كم دقيقة يستغرقان؟','72 دقيقة','60 دقيقة|66 دقيقة|75 دقيقة|80 دقيقة|90 دقيقة','اجمع أجزاء الجدار التي ينجزها كل عامل في الساعة.','المعدل1/2+1/3=5/6 جدار في الساعة؛ الزمن6/5 ساعة=72 دقيقة.'),
('إبريق فيه لتر عصير مركز. أفرغت نصفه وملأته ماء ثم كررت العملية مرة أخرى. كم لترًا من العصير الأصلي بقي؟','ربع لتر','نصف لتر|ثلاثة أرباع لتر|خُمس لتر|ثُمن لتر|لا شيء','السحبة الثانية تزيل نصف الخليط، وليس الماء وحده.','تبقى نصف كمية المركز بعد الأولى، ثم نصف هذا النصف بعد الثانية:1/4 لتر.'),
('ورقة طُويت إلى نصفين مرتين؛ كل طية تضاعف الطبقات. ثقبت الطبقات كلها مرة واحدة بعيدًا عن خطوط الطي. كم ثقبًا يظهر بعد فرد الورقة؟','4 ثقوب','ثقبان|3 ثقوب|5 ثقوب|6 ثقوب|8 ثقوب','كل طبقة مثقوبة تتحول إلى موضع مستقل عند الفرد.','عدد الطبقات2×2=4، والثقب يمر بكلها بعيدًا عن خطوط الطي فتظهر4 ثقوب.'),
('أب وولده عمرهما معًا50 سنة؛ عمر الأب4 أمثال عمر ولده. كم عمر الولد؟','10 سنوات','8 سنوات|9 سنوات|11 سنة|12 سنة|15 سنة','قسّم مجموع العمر إلى حصص متساوية بحسب النسبة.','الأب4 حصص والولد حصة، فالحصص5؛50÷5=10.'),
('ستة أشخاص يجلسون في دائرة. كل واحد يصافح جارَيه فقط، وكل مصافحة تحسب مرة واحدة. كم مصافحة؟','6 مصافحات','5 مصافحات|7 مصافحات|8 مصافحات|10 مصافحات|12 مصافحة','كل حافة بين مقعدين متجاورين تمثل مصافحة واحدة.','عدد العلاقات6×2÷2=6، فكل مصافحة تُذكر عند شخصين.'),
('عندك9 عملات، واحدة أخف والباقي متساوٍ. ميزان كفتين بلا أثقال. كم وزنة تكفي لضمان العثور على الخفيفة؟','وزنتان','وزنة واحدة|3 وزنات|4 وزنات|5 وزنات|6 وزنات','قسّم الاحتمالات إلى ثلاث مجموعات، لأن للميزان ثلاث نتائج.','وازن3 مقابل3؛ النتيجة تحدد مجموعة من3. وازن واحدة مقابل أخرى منها لتحدد الأخف في الوزنة الثانية.'),
('ثمانية لاعبين في بطولة خروج مغلوب، ولا تعادل ولا انسحاب. كم مباراة يلزم لتحديد بطل واحد؟','7 مباريات','4 مباريات|6 مباريات|8 مباريات|9 مباريات|12 مباراة','كل مباراة تخرج لاعبًا واحدًا من المنافسة.','يلزم إخراج7 لاعبين، فتحتاج7 مباريات مهما كان شكل الجدول.'),
('لوحة3×3 خلايا. كم مربعًا تحتوي إذا عُدّت المربعات الكبيرة والصغيرة معًا؟','14 مربعًا','9 مربعات|10 مربعات|12 مربعًا|13 مربعًا|15 مربعًا','قسّم العدّ بحسب طول ضلع المربع بالخلايا.','9 من حجم1×1 و4 من2×2 و1 من3×3؛ المجموع14.'),
('تكتب أرقام الصفحات من1 إلى20. كم مرة تكتب الرقم1؟','12 مرة','9 مرات|10 مرات|11 مرة|13 مرة|14 مرة','افصل ظهوره في خانة العشرات عن خانة الآحاد.','يظهر في الآحاد في1 و11، وفي العشرات في10 إلى19 عشر مرات؛ الإجمالي12.'),
('شخص صعد3 درجات ثم نزل درجتين؛ كرر ذلك حتى وصل أول مرة للدرجة التاسعة. كم مرة صعد3 درجات؟','7 مرات','5 مرات|6 مرات|8 مرات|9 مرات|10 مرات','في الحركة الأخيرة يصل إلى الهدف ولا يحتاج إلى نزول جديد.','بعد6 دورات يكون عند6، ثم الصعود السابع يوصله إلى9.'),
('مزرعة فيها دجاج وأرانب:10 رؤوس و28 قدمًا. كم أرنبًا فيها؟','4 أرانب','3 أرانب|5 أرانب|6 أرانب|7 أرانب|8 أرانب','ابدأ بافتراض أن كل الرؤوس لدجاج، ثم فسّر الأرجل الزائدة.','عشرة دجاجات تعطي20 قدمًا؛ كل أرنب يزيد2، فالثمانية الزائدة تعني4 أرانب.'),
('كيف تقلب كلمة «ليل» بترتيب حروفها من النهاية للبداية دون تغيير شكل الكلمة؟','لأن ترتيب حروفها متناظر','لأنها بلا نقاط|لأن الحروف كلها متصلة|لأنها من ثلاثة حروف فقط|لأن أولها يشبه آخرها صوتيًا فقط|لأنها اسم وقت','قارن الحروف في المواقع المتقابلة.','حروفها ل،ي،ل؛ عكس الترتيب يعطي الحروف نفسها في المواقع نفسها.'),
]

def build_riddles():
    pools={d:[] for d in LEVELS}
    # Avoid adding classic riddles already represented among the preserved200.
    for engine in [knights,order_puzzle,lock,switches,secret]:
        seen_easy=set()
        while len(seen_easy)<5:
            q=engine('easy',len(seen_easy))
            if q['text'] not in seen_easy:
                seen_easy.add(q['text']);pools['easy'].append(q)
    engines=[knights,order_puzzle,lock,switches,secret,graph_problem]
    need={'medium':119,'hard':224,'legendary':224}
    seen=set()
    for level,count in need.items():
        i=0
        while len(pools[level])<count:
            e=engines[i%len(engines)];q=e(level,i);i+=1
            signature=re.sub(r'\d+','#',q['text'])
            if signature in seen:continue
            seen.add(signature);pools[level].append(q)
    return pools

def cell(i,n):return chr(65+i%n)+str(i//n+1)
def neigh(i,n):return [j for j in range(n*n) if abs(j//n-i//n)+abs(j%n-i%n)==1]
def grid_problem(level,k,kind='flow'):
    n=4 if level=='hard' else 5
    if kind=='flow':
        heights=RNG.sample(range(10,10+n*n*3),n*n);start=RNG.randrange(n*n)
        def descend(i):
            low=[j for j in neigh(i,n) if heights[j]<heights[i]]
            return min(low,key=lambda j:heights[j]) if low else None
        path=[start]
        while descend(path[-1]) is not None:path.append(descend(path[-1]))
        end=path[-1]
        if len(path)<3:return grid_problem(level,k,kind)
        table='؛ '.join(f'الصف{r+1}: '+ '، '.join(f'{chr(65+c)}={heights[r*n+c]}' for c in range(n)) for r in range(n))
        text=f'خريطة ارتفاعات شبكية بالمتر. الصف1 في الشمال والأعمدة منA شرقًا. '+table+f'. ماء ينطلق من{cell(start,n)}، وينتقل في كل خطوة إلى الجار الأقل ارتفاعًا بين الشمالي والجنوبي والشرقي والغربي فقط، بشرط أن يكون أخفض منه. إذا لم يجد جارًا أخفض توقف. أين يتجمع؟'
        return problem(text,cell(end,n),[cell(i,n) for i in range(n*n) if i!=end],
          'تتبع الانحدار خطوة خطوة؛ أخفض خلية في الخريطة ليست بالضرورة متصلة بمسار الماء.',
          'المسار بحسب قاعدة الجوار هو '+ ' → '.join(cell(i,n) for i in path)+f'. عند{cell(end,n)} كل الجيران أعلى، لذلك يتوقف الماء هناك.',proof={'engine':'drainage','n':n,'heights':heights,'start':start,'solution':end})
    blocked=set(RNG.sample(range(1,n*n-1),RNG.randrange(2,n+2)));start=0;end=n*n-1
    heights=RNG.sample(range(n*n*2),n*n)
    weight=lambda i,j:1+max(0,heights[j]-heights[i])
    dist={start:0};prev={};todo=[(0,start)]
    import heapq
    while todo:
        d,i=heapq.heappop(todo)
        if d!=dist[i]:continue
        for j in neigh(i,n):
            if j in blocked:continue
            nd=d+weight(i,j)
            if nd<dist.get(j,math.inf):dist[j]=nd;prev[j]=i;heapq.heappush(todo,(nd,j))
    if end not in dist:return grid_problem(level,k,kind)
    path=[end]
    while path[-1]!=start:path.append(prev[path[-1]])
    path.reverse();table='؛ '.join(f'الصف{r+1}: '+ '، '.join(f'{chr(65+c)}='+('مغلق' if r*n+c in blocked else str(heights[r*n+c])) for c in range(n)) for r in range(n))
    ans=dist[end]
    return numeric('خريطة مشي شبكية؛ الصف1 في الشمال والأعمدةA ثمB شرقًا. ارتفاعات الخلايا بالمتر: '+table+f'. من{cell(start,n)} إلى{cell(end,n)} يسمح فقط بانتقال إلى جار ذي ضلع مشترك وغير مغلق. كلفة الانتقال وحدة واحدة، مضافًا إليها مقدار الصعود إن كان الجار أعلى؛ النزول لا يضيف كلفة. ما أقل كلفة ممكنة؟',ans,
      'قد يكون الالتفاف حول قمة أقل كلفة من الطريق الأقصر عددًا من الخطوات.',
      'أقصر كلفة على الشبكة هي'+str(ans)+'. يحققها الطريق '+ ' → '.join(cell(i,n) for i in path)+'. فحص جميع الحواف بتحديث المسافات يؤكد عدم وجود مسار أقل.',proof={'engine':'terrain_path','n':n,'heights':heights,'blocked':sorted(blocked),'start':start,'end':end,'solution':ans})

def region_problem(level,k):
    n=4 if level=='hard' else 5
    grid=[RNG.randrange(2) for _ in range(n*n)]
    regions=[];remaining={i for i in range(n*n) if grid[i]}
    while remaining:
        queue=[remaining.pop()];reg=set(queue)
        while queue:
            i=queue.pop()
            for j in neigh(i,n):
                if j in remaining:remaining.remove(j);reg.add(j);queue.append(j)
        regions.append(sorted(reg))
    if not regions or len(regions)<2:return region_problem(level,k)
    table=' / '.join(''.join('ب' if grid[r*n+c] else 'م' for c in range(n)) for r in range(n))
    typ=RNG.choice(['number','largest','coast','join'])
    if typ=='number':answer=len(regions);ask='كم جزيرة منفصلة فيها؟';exp='المكونات المتصلة بالضلع عددها '+str(answer)
    elif typ=='largest':answer=max(map(len,regions));ask='كم خلية يابسة تحتوي أكبر جزيرة؟';exp='أحجام الجزر '+ '، '.join(str(len(r)) for r in regions)+f'؛ أكبرها{answer}'
    elif typ=='coast':
        answer=sum(4-sum(grid[j] for j in neigh(i,n)) for i in range(n*n) if grid[i]);ask='إذا كان ضلع الخلية1 كم، فما طول حدود اليابسة مع الماء، مع احتساب خارج الشبكة ماءً؟';exp='كل ضلع ليابسة لا يجاور يابسة أخرى يحسب مرة، والمجموع '+str(answer)+' كم'
    else:
        water=[i for i in range(n*n) if not grid[i]];scores={i:1+sum(len(r) for r in regions if any(j in r for j in neigh(i,n))) for i in water}
        answer=max(scores.values()) if scores else n*n;ask='تحول خلية ماء واحدة فقط إلى يابسة. ما أكبر مساحة لجزيرة متصلة يمكن الحصول عليها، بوحدة الخلية؟';exp='يفحص كل موضع ماء وتجمع الجزر المختلفة الملامسة له مع الخلية الجديدة، وأكبر مجموع '+str(answer)
    return numeric(f'خريطة مربعة ذات{n}صفوف و{n}أعمدة. «ب» يابسة و«م» ماء. الصفوف من الشمال للجنوب، داخل كل صف من الغرب للشرق: '+table+'. الاتصال يكون بالضلع فقط ولا يكفي الركن. '+ask,answer,
       'الملامسة عند زاوية لا تصل جزيرتين؛ كوّن المجموعات باستخدام الأضلاع فقط.',
       exp+'.',proof={'engine':'regions','n':n,'grid':grid,'mode':typ,'solution':answer})

MAP_EASY=[
('على خريطة، رمز نجمة يحدد مكان المستشفى وفق المفتاح. ماذا يمثل المفتاح هنا؟','معاني الرموز المستخدمة','ارتفاع الأرض فقط|تاريخ الطباعة فقط|خطوط الطول وحدها|اتجاه الرياح فقط|حدود الدول وحدها','الرمز لا يحمل معناه ما لم توجد وسيلة لفك دلالته.','المفتاح يربط كل علامة بما تمثله؛ النجمة هنا تعني مستشفى بحسب المعطى.'),
('خريطة رسم فيها سهم الشمال باتجاه يمين الورقة. في أي اتجاه على الورقة تكون جهة الغرب؟','أعلى الورقة','أسفل الورقة|يمين الورقة|يسار الورقة|أعلى اليمين|أسفل اليسار','دُر مع سهم الشمال؛ العلاقة بين الجهات ثابتة مهما دارت الورقة.','الغرب يقع90 درجة عكس اتجاه عقارب الساعة من الشمال؛ وإذا كان الشمال يمينًا كان الغرب أعلى.'),
('على مخطط، شارع يمر من الغرب إلى الشرق. مدرسة تقع شماله ومكتبة جنوبه عند خط الطول نفسه. أين المدرسة بالنسبة إلى المكتبة؟','إلى الشمال','إلى الجنوب|إلى الشرق|إلى الغرب|إلى الجنوب الشرقي|إلى الجنوب الغربي','قارن الموقعين، لا اتجاه سير الشارع.','المدرسة والمكتبة على المحاذاة نفسها، والمدرسة شمال الشارع والمكتبة جنوبه.'),
('رمز الطريق في خريطة طريق خط أحمر متصل، والخط الأزرق نهر. هل لون الخط وحده يحدد المعنى في جميع الخرائط؟','لا؛ يجب الرجوع إلى مفتاح الخريطة','نعم؛ الأحمر دائمًا طريق|نعم؛ الأزرق دائمًا طريق|نعم؛ كل الخطوط حدود دول|لا؛ طول الخط وحده يكفي|لا؛ حجم الورقة وحده يكفي','قد تستعمل خريطتان اللون نفسه لغرضين مختلفين.','الرموز اصطلاح يحدده مفتاح الخريطة، وليست كل خريطة ملزمة بالدلالة اللونية نفسها.'),
('خريطة شبكية؛ الصفوفA ثمB ثمC من الشمال للجنوب، والأعمدة1 ثم2 ثم3 من الغرب للشرق. أينB2؟','الخلية الوسطى','الزاوية الشمالية الغربية|الزاوية الشمالية الشرقية|الزاوية الجنوبية الغربية|الزاوية الجنوبية الشرقية|منتصف الحافة الشمالية','حدد صفها وعمودها كلًا على حدة.','B الصف الثاني و2 العمود الثاني؛ تقاطعهما الخلية الوسطى.'),
]

def simple_map(k,level):
    # Independently authored route structure: varied turns, not a scale-number substitution.
    directions=[('شمالًا',0,1),('جنوبًا',0,-1),('شرقًا',1,0),('غربًا',-1,0)]
    length=3 if level=='easy' else 5;moves=[RNG.choice(directions) for _ in range(length)]
    x=sum(m[1] for m in moves);y=sum(m[2] for m in moves)
    answer=f'({x}، {y})';wrong=[f'({a}، {b})' for a,b in [(x+1,y),(x-1,y),(x,y+1),(x,y-1),(y,x),(-x,-y),(x+2,y+1),(x-2,y-1)] if (a,b)!=(x,y)]
    return problem('مخطط شبكي، كل حركة تعبر خلية واحدة. الإحداثي الأول يزيد شرقًا والثاني يزيد شمالًا. من(0،0) تحركت: '+ ' ثم '.join(m[0] for m in moves)+'. ما إحداثيات موضعك النهائي؟',answer,wrong,
       'افصل مجموع التحركات الأفقية عن العمودية؛ الحركة العكسية تلغي السابقة.',
       f'المحصلة الأفقية{x} خلية، والعمودية{y} خلية، لذلك الموضع النهائي{answer}.',proof={'engine':'map_walk','steps':[[m[1],m[2]] for m in moves],'solution':[x,y]})

def build_maps():
    pools={d:[] for d in LEVELS};seen=set()
    for t,a,w,h,e in MAP_EASY:pools['easy'].append(problem(t,a,w.split('|'),h,e))
    for level,count in [('easy',25),('medium',25),('hard',94),('legendary',225)]:
        i=0
        while len(pools[level])<count:
            if level in ['easy','medium']:q=simple_map(i,level)
            elif i%4==0:q=graph_problem(level,i,'maps')
            elif i%4==1:q=grid_problem(level,i,'flow')
            elif i%4==2:q=grid_problem(level,i,'path')
            else:q=region_problem(level,i)
            i+=1
            signature=re.sub(r'\d+','#',q['text'])
            if signature in seen:continue
            seen.add(signature);pools[level].append(q)
    return pools

BASE='https://openstax.org/books/college-physics-2e/pages/'
SCI_SOURCES={
 'electric':BASE+'21-3-kirchhoffs-rules',
 'capacitor':BASE+'19-6-capacitors-in-series-and-parallel',
 'heat':BASE+'14-5-conduction',
 'fluid':BASE+'12-4-viscosity-and-laminar-flow-poiseuilles-law',
 'spring':BASE+'16-1-hookes-law-stress-and-strain-revisited',
 'magnet':BASE+'23-2-faradays-law-of-induction-lenzs-law',
 'transformer':BASE+'23-7-transformers',
 'rc':BASE+'21-6-dc-circuits-containing-resistors-and-capacitors',
 'reflection':BASE+'25-2-the-law-of-reflection',
 'refraction':BASE+'25-3-the-law-of-refraction',
 'tir':BASE+'25-4-total-internal-reflection',
 'radiation':BASE+'14-7-radiation',
 'hydraulic':BASE+'11-5-pascals-principle',
 'flow':BASE+'12-1-flow-rate-and-its-relation-to-velocity',
}
SCI_EASY=[
('سلسلة مصابيح على التوالي تعطلت منها فتيلة وانقطعت تمامًا. لماذا تنطفئ البقية؟','لأن مسار التيار الوحيد انقطع','لأن جهد البطارية انعكس|لأن مقاومة البقية صارت صفرًا|لأن المصابيح فقدت لونها|لأن التيار زاد في الفروع|لأن كل مصباح صار مصدرًا','تتبّع الطريق الذي يجب أن يمر به التيار.','التوصيل التسلسلي لا يتيح طريقًا بديلًا حول الفتيلة المنقطعة.','electric'),
('يوضع حساس حرارة في منتصف قضيب يصل طرفًا ساخنًا بآخر بارد. لماذا تتغير قراءته إذا عُزل الجزء القريب من الطرف الساخن؟','لأن العزل يغيّر معدل وصول الحرارة إليه','لأن العزل يولد حرارة كهربائية حتمًا|لأن البرد مادة تتكاثر|لأن الطرف البارد يفقد كل طاقته|لأن العزل يبدّل وحدة القياس|لأن طول القضيب يصبح صفرًا','راقب مسارات انتقال الطاقة بين الطرفين والحساس.','درجة نقطة وسطية ترتبط بتوازن انتقال الحرارة؛ إضعاف الاتصال الحراري بالطرف الساخن يميل بها نحو البارد.','heat'),
('لماذا تتأخر استجابة دائرة شحن مقاومة ومكثف إذا زادت المقاومة مع بقاء المكثف نفسه؟','لأن ثابت الزمن حاصل ضرب المقاومة والسعة يزداد','لأن المكثف يفقد كل سعته|لأن مصدر الجهد يضاعف تردده|لأن الشحنة تنتقل دون تيار|لأن ثابت الزمن يصبح مقلوب السعة|لأن المقاومة تصبح بطارية','ربط المقاومة بسرعة مرور الشحنة يفسر التأخير.','في نموذجRC، ثابت الزمنR×C؛ زيادةR مع ثباتC تجعل الشحن أبطأ.','rc'),
('تفتح صمامًا في أنبوب رفيع يزيد مساحة المجرى. عند ثبات فرق الضغط والتدفق الصفحي، لماذا يزيد التدفق؟','لأن مقاومة المجرى للسريان تقل','لأن الضغطين يصبحان سالبين|لأن لزوجة السائل تنعدم حتمًا|لأن السائل يتوقف عن الاحتكاك|لأن حجم كل جزيء يتضاعف|لأن الماء يتحول إلى غاز حتمًا','اتساع المجرى يغير مقدار الإعاقة أمام السريان.','قانون بوازوي يربط التدفق بقوة رابعة نصف القطر؛ الاتساع يقلل مقاومة السريان.','fluid'),
('في رافعة هيدروليكية مثالية، لماذا يتحرك المكبس الكبير مسافة أقصر من المكبس الصغير؟','لأن الحجم المزاح نفسه يتوزع على مساحة أكبر','لأن ضغط الكبير أقل دائمًا|لأن السائل يفقد حجمه|لأن القوة تختفي في الأنبوب|لأن السائل ينضغط إلى الصفر|لأن المكبس الكبير ليس متصلًا','وازن حجم السائل الخارج من أحد الطرفين بالداخل إلى الآخر.','السائل غير القابل للانضغاط يحافظ على الحجم؛ المسافة=الحجم÷المساحة، فتقل عند زيادة المساحة.','hydraulic'),
('لملف مولد العدد نفسه من اللفات، زادت سرعة تغير الفيض خلاله. لماذا يرتفع مقدار الجهد المستحث؟','لأن الجهد يتناسب مع معدل تغير الفيض','لأن الجهد يتناسب مع ثبات الفيض|لأن عدد اللفات انخفض|لأن الشحنة المغناطيسية تنفد|لأن الملف يتوقف عن الحركة|لأن مقاومة الهواء تولد جهدًا','الكمية المهمة ليست شدة المجال وحدها بل كيفية تغيره مع الزمن.','قانون فاراداي: مقدار الجهد=N×مقدار تغير الفيض في الزمن.','magnet'),
('لماذا لا يعطي محول تقليدي خرجًا مستمرًا من بطارية ثابتة بعد انتهاء لحظة التوصيل؟','لأن الفيض لا يتغير في الحالة المستقرة','لأن النحاس لا يمرر التيار المستمر|لأن البطارية لا تملك قطبين|لأن الملفين يجب أن يتلامسا|لأن الجهد المستمر موجة صوتية|لأن القلب الحديدي ينعدم','فرّق بين لحظة التوصيل والحالة التي تليها.','الحث يحتاج تغير الفيض؛ التيار المستقر في الأولي لا يولد تغيرًا مستمرًا في الفيض للثانوي.','transformer'),
('في محول مثالي يضاعف جهد الخرج، لماذا ينخفض تيار الخرج إلى النصف عند نقل القدرة نفسها؟','لأن القدرة تساوي حاصل ضرب الجهد والتيار','لأن الشحنة تختفي في القلب|لأن تردد الخرج ينخفض للنصف|لأن عدد الإلكترونات في الكون يقل|لأن الخرج يصبح تيارًا مستمرًا|لأن المقاومة السلكية تصبح صفرًا','القيمة التي تبقى ثابتة في النموذج المثالي هي الطاقة المنقولة في الزمن.','إذا بقيP=VI ثابتًا وتضاعفV فلا بد أن ينصفI.','transformer'),
('لماذا يُصنع قلب المحول من صفائح رقيقة معزولة بدل كتلة موصلة متصلة؟','لتقليل التيارات الدوامية والتسخين الناتج عنها','لمنع أي فيض مغناطيسي|لإلغاء جميع اللفات الثانوية|لتحويل التيار المتناوب إلى صوت|لزيادة مسارات التيارات الدوامية|لمنع مرور الحرارة نهائيًا','فكّر في الحلقات الكهربائية التي يمكن أن تتشكل داخل المعدن نفسه.','العزل بين الصفائح يحد من مسارات التيارات الدوامية الكبيرة ويخفض فقد الطاقة.','transformer'),
('تقترب مغناطيسًا من حلقة موصلة مغلقة. لماذا يكون تأثير التيار المستحث معارضًا للاقتراب؟','لأن مجاله يعارض تغير الفيض الذي سببه','لأن التيار يمنع كل مجال دائمًا|لأن الحلقة تصير عازلة تمامًا|لأن المغناطيس يفقد قطبيه|لأن اتجاه التيار لا يتعلق بالحركة|لأن الشحنات تنفصل بلا مجال','طبّق قاعدة الاتجاه على التغير، وليس على المجال الموجود فقط.','قانون لنز يجعل أثر التيار المستحث يعارض تغير الفيض؛ في هذه الحالة يقاوم اقتراب المغناطيس.','magnet'),
('مرآة مستوية دارت قليلًا بينما الشعاع الساقط ثابت. لماذا يدور الشعاع المنعكس بضعف زاوية دوران المرآة؟','لأن دوران العمود يغير زاويتي السقوط والانعكاس معًا','لأن سرعة الضوء تتضاعف|لأن طول موجة الضوء ينصف|لأن الانعكاس يتحول إلى انكسار|لأن سطح المرآة يضاعف مساحته|لأن مصدر الضوء يدور تلقائيًا','قِس الزوايا من العمود على السطح.','قانون الانعكاس يساوي الزاويتين بالنسبة إلى العمود؛ تدوير العمود يغير اتجاه المنعكس بضعف الدوران.','reflection'),
('لماذا يخفق ليف ضوئي في حبس شعاع إذا زادت زاويته مع محور الليف كثيرًا فتقل زاوية سقوطه على الجدار عن الحرجة؟','لأن شرط الانعكاس الداخلي الكلي لم يعد متحققًا','لأن الزجاج أصبح معدنًا|لأن الضوء فقد تردده|لأن اللب صار مفرغًا حتمًا|لأن سرعة الضوء صارت صفرًا|لأن الغلاف تولد منه بطارية','شرط الحبس يُقاس بالنسبة إلى العمود على جدار الليف.','عند السقوط دون الزاوية الحرجة يمكن أن ينكسر جزء من الشعاع إلى الوسط الآخر بدل الانعكاس الكلي.','tir'),
('عند دخول شعاع من الهواء إلى زجاج ذي معامل انكسار أكبر بزاوية مائلة، لماذا ينحني نحو العمود؟','لأن سرعته تقل ويحقق قانون الانكسار','لأن تردده يزيد تلقائيًا|لأن الضوء يكتسب كتلة ساكنة|لأن السطح يمتص كل الضوء|لأن زاوية الخروج تساوي دائمًا90 درجة|لأن الضوء يتحول إلى صوت','اربط تغيّر سرعة الانتشار بتغيّر زاوية الجبهة الموجية.','قانون سنيل يربط جيب الزاوية بمعامل الانكسار؛ زيادة المعامل تخفض الزاوية مع العمود.','refraction'),
('لماذا لا يحدث انعكاس داخلي كلي لشعاع يحاول الانتقال من الهواء إلى الزجاج العادي؟','لأنه ينتقل من معامل أصغر إلى معامل أكبر','لأن الهواء لا يمرر الضوء|لأن الزجاج ليس له معامل انكسار|لأن الضوء لا يسقط بزاوية|لأن الهواء يمتص جميع الألوان|لأن العمود على السطح لا يوجد','راجع جهة الانتقال التي تسمح أصلًا بوجود زاوية حرجة.','الانعكاس الداخلي الكلي يتطلب انتقالًا من معامل انكسار أكبر إلى أصغر؛ الهواء إلى الزجاج هو الاتجاه المعاكس.','tir'),
('لماذا يتغير طول موجة ضوء داخل الزجاج مع بقاء تردده ثابتًا؟','لأن سرعة انتشاره تتغير وطوله يساوي السرعة على التردد','لأن الزمن يتوقف داخل الزجاج|لأن التردد يصبح بلا وحدة|لأن كل فوتون ينقسم إلى اثنين|لأن المصدر يزيد قدرته حتمًا|لأن الطول لا يرتبط بالسرعة','فكّر في المسافة التي تقطعها الموجة خلال دورة واحدة.','العلاقةv=fλ؛ إذا ثبتf وتغيرتv تغيرλ بالنسبة نفسها.','refraction'),
('لماذا يسخن جسم أسود غير لامع تحت مصدر إشعاع أكثر من جسم عاكس مماثل عند الظروف نفسها؟','لأنه يمتص نسبة أكبر من الإشعاع الساقط','لأنه يعكس نسبة أكبر من الإشعاع|لأن الأسود يولد الطاقة من العدم|لأن الهواء حوله يخلو من الجزيئات|لأن الضوء لا يصل إلى العاكس|لأن سعة الأسود الحرارية صفر دائمًا','افصل الطاقة المرتدة عن الطاقة التي تبقى في الجسم.','ارتفاع الامتصاص يزيد الطاقة الحرارية المكتسبة من المصدر مع تماثل بقية الظروف.','radiation'),
('في فراغ بين سطحين بدرجتي حرارة مختلفتين، كيف يمكن انتقال الحرارة رغم غياب المادة؟','بالإشعاع الكهرومغناطيسي','بالحمل الهوائي|بالتوصيل عبر جزيئات الهواء|بحركة فقاعات الماء|بانتشار جزيئات الفراغ|بانسياب الإلكترونات في الهواء','ابحث عن طريقة انتقال لا تتطلب وسطًا ماديًا.','الإشعاع ينتشر في الفراغ، بينما الحمل والتوصيل عبر المادة يحتاجان وسطًا.','radiation'),
('نابضان متماثلان يشدان كتلة بالتوازي. لماذا يصبح النظام أصلب من نابض واحد؟','لأن القوتين تضافان عند الإزاحة نفسها','لأن الإزاحة تتضاعف دون قوة|لأن ثابت كل نابض يختفي|لأن كتلة الجسم تصبح صفرًا|لأن النابضين لا يتشوهان|لأن الجاذبية تنقلب','قارن القوة الكلية عند مقدار تمدد محدد.','لكل نابض قوةkx؛ مجموعهما2kx، فالثابت المكافئ2k.','spring'),
('نابضان متماثلان موصولان على التوالي. لماذا يطول النظام أكثر من نابض واحد تحت قوة الشد نفسها؟','لأن تمددي النابضين يضافان','لأن القوة على الثاني تصبح صفرًا|لأن الأول يضغط الثاني بدل شده|لأن الثابت المكافئ يتضاعف|لأن الجاذبية وحدها تحدد التمدد|لأن النابضين لا يحملان القوة نفسها','اسأل أي كمية مشتركة بين العنصرين وأي كمية تُجمع.','تمر القوة نفسها في النابضين وكل منهما يتمددF/k؛ التمدد الكلي2F/k.','spring'),
('مكثفان متساويان على التوالي بين قطبي بطارية. لماذا تنخفض السعة المكافئة عن سعة أحدهما؟','لأن الجهد الكلي يتوزع على المكثفين عند شحنة متساوية','لأن الشحنة في كل مكثف تختفي|لأن الجهد على كل منهما يساوي الكلي|لأن السعتين تجمعان مباشرة|لأن أحدهما يبدل قطبية البطارية|لأن العازل يتحول إلى مصدر تيار','افصل الجهد الكلي عن الشحنة التي يمر بها طرف الدائرة.','في التوالي تتساوى مقادير الشحنة وينجمع الجهد؛1/Ceq=1/C1+1/C2، فالسعة لنصف قيمة الواحد عند تماثلهما.','capacitor'),
('لماذا تزيد سعة مجموعة مكثفات عند وصل مكثف إضافي على التوازي؟','لأن الشحنات المخزنة تجمع عند الجهد نفسه','لأن الجهد يقسم بالتساوي بين الجميع|لأن المكثف الجديد يمنع كل شحن|لأن سعة القديم تنخفض إلى الصفر|لأن شحنات الفروع تتلاشى|لأن فرق الجهد لا يمكن قياسه','في التوازي تكون كمية واحدة مشتركة بين جميع الفروع.','فرق الجهد مشترك والشحنة الكلية مجموع الشحنات؛ لذلكCeq مجموع السعات.','capacitor'),
('أنبوب يتفرع إلى مسارين ثم يلتقيان. في سريان مستقر بلا تسرب، لماذا يساوي تدفق المدخل مجموع تدفق الفرعين؟','لأن السائل لا يتراكم عند نقطة التفرع','لأن كل فرع يحمل تدفق المدخل كاملًا|لأن الكثافة يجب أن تصبح صفرًا|لأن الضغط يتساوى في كل نقطة حتمًا|لأن سرعة كل فرع تساوي سرعة المدخل حتمًا|لأن الأنبوب يولد سائلًا إضافيًا','وازن ما يدخل العقدة بما يخرج منها في الزمن نفسه.','حفظ الكتلة وثبات الكثافة وغياب التراكم يفرضانQin=Q1+Q2.','flow'),
('في جدار من طبقتين عازلتين متتاليتين، لماذا تمر كمية الحرارة نفسها عبرهما كل ثانية بعد الاستقرار؟','لأن الطاقة لا تتراكم بين الطبقتين في الحالة المستقرة','لأن درجتي الطبقتين متساويتان دائمًا|لأن كل طبقة تولد حرارة مساوية|لأن الجدار لا يوصل أي حرارة|لأن الحرارة تختفي عند الواجهة|لأن السماكتين متساويتان بالضرورة','لو اختلف التدفق الداخل والخارج لدرجة الواجهة، ماذا سيحدث؟','غياب التراكم في الواجهة يساوي معدلي انتقال الطاقة؛ درجات الحرارة تهبط بحسب مقاومة كل طبقة.','heat'),
('في موصلين حراريين متوازيين بين سطحين، كيف يؤثر قطع أحد المسارين مع ثبات حرارتي السطحين؟','ينخفض مجموع انتقال الحرارة وتبقى مساهمة المسار الآخر','يتضاعف مجموع انتقال الحرارة|تتغير حرارة السطحين المفروضة حتمًا|يتحول المسار الآخر إلى عازل|ينعدم انتقال الحرارة من المسارين دائمًا|تنعكس جهة التدفق في الآخر حتمًا','كل فرع يتصل مباشرة بالطرفين نفسيهما.','كل مسار يرى فرق الحرارة نفسه؛ قطع فرع يزيل مساهمته دون فرض تغيير على الآخر في النموذج المثالي.','heat'),
('كيف يثبت مكثف في دائرة تيار مستمر جهدًا بعد الشحن الكامل دون استمرار تيار مثالي عبر عازله؟','بفصل شحنتين متعاكستين على لوحيه','بحرق تيار مستمر داخل العازل|بصنع شحنة موجبة من العدم|بتغيير المقاومة إلى صفر|بنقل مادة اللوح الأول إلى الثاني|بإلغاء المجال بين اللوحين','التخزين يتعلق بالشحنة والمجال، لا بممر دائم عبر العازل.','المكثف المثالي يخزن طاقة في المجال بين شحنتي لوحيه؛ عند الاستقرار لا يمر تيار شحن عبر العازل.','rc'),
]

def solve_linear(A,b):
    rows=[[F(v) for v in r]+[F(bi)] for r,bi in zip(A,b)];n=len(b)
    for k in range(n):
        p=next(i for i in range(k,n) if rows[i][k]);rows[k],rows[p]=rows[p],rows[k]
        f=rows[k][k];rows[k]=[v/f for v in rows[k]]
        for i in range(n):
            if i!=k:
                f=rows[i][k];rows[i]=[v-f*w for v,w in zip(rows[i],rows[k])]
    return [r[-1] for r in rows]
def network_solve(n,edges,start=12):
    # Conductance and conservation at each internal node.
    A=[[F(0) for j in range(n-2)] for i in range(n-2)];b=[F(0)]*(n-2)
    for i in range(1,n-1):
        for x,y,g in edges:
            if i not in [x,y]:continue
            j=y if x==i else x;A[i-1][i-1]+=g
            if j==0:b[i-1]+=g*start
            elif j!=n-1:A[i-1][j-1]-=g
    return [F(start),*solve_linear(A,b),F(0)]

def science_network(level,k,kind):
    n={'medium':4,'hard':5,'legendary':6}[level];labels=list('ABCDEF')[:n]
    while True:
        ed=graph_data(n);ed=[(a,b,F(1,w) if kind in ['electric','fluid'] else F(w)) for a,b,w in ed]
        if len(ed)<n:continue
        fixed=12 if kind!='heat' else 80
        vals=network_solve(n,ed,fixed);target=RNG.randrange(1,n-1)
        mode=RNG.choice(['node','source','link','change'])
        if mode=='change':
            idx=RNG.randrange(len(ed));a,b,g=ed[idx];ed[idx]=(a,b,g*2);vals=network_solve(n,ed,fixed)
        elif mode=='link':
            idx=RNG.randrange(len(ed));a,b,g=ed[idx]
        elif mode=='source':a=0
        else:a=target
        if mode in ['node','change']:value=vals[target]
        elif mode=='source':value=sum(g*(vals[0]-vals[b if a==0 else a]) for a,b,g in ed if 0 in [a,b])
        else:value=abs(g*(vals[a]-vals[b]))
        if 0<value<200 and value.denominator<=200:break
    source=SCI_SOURCES[kind];intro='';unit='';subject=''
    if kind=='electric':
        intro=f'شبكة مقاومات مثالية تغذيها بطارية بينA({fixed}فولت) و{labels[-1]}(0فولت).';subject='مقاومة بالأوم';unit=' فولت' if mode in ['node','change'] else ' أمبير'
        ask=f'ما جهد العقدة{labels[target]}؟' if mode in ['node','change'] else ('ما التيار الكلي الخارج من القطبA؟' if mode=='source' else f'ما مقدار التيار في مقاومة{labels[a]}–{labels[b]}؟')
        explanation='قانون أوم مع حفظ التيار عند العقد الداخلية؛ مجموع g×(جهد العقدة−جهد الجار)=0.'
    elif kind=='fluid':
        intro=f'شبكة أنابيب أفقية بسريان صفحي لسائل غير قابل للانضغاط؛ ضغطA={fixed} كيلوباسكال وضغط{labels[-1]}=0.';subject='مقاومة هيدروليكية بكيلوباسكال لكل(مل/ثانية)';unit=' كيلوباسكال' if mode in ['node','change'] else ' مل/ثانية'
        ask=f'ما ضغط العقدة{labels[target]}؟' if mode in ['node','change'] else ('ما تدفق المصدرA الكلي؟' if mode=='source' else f'ما مقدار التدفق في أنبوب{labels[a]}–{labels[b]}؟')
        explanation='في النموذج الصفحي التدفق=فرق الضغط÷المقاومة. مجموع التدفقات عند العقدة صفر لعدم التراكم.'
    elif kind=='heat':
        intro=f'شبكة توصيل حراري مستقرة مع عزل كل العقد عن الجو ودون مصادر داخلية؛ درجةA={fixed}°م ودرجة{labels[-1]}=0°م.';subject='موصلية حرارية بالواط لكل درجة';unit=' درجة مئوية' if mode in ['node','change'] else ' واط'
        ask=f'ما درجة العقدة{labels[target]}؟' if mode in ['node','change'] else ('ما معدل خروج الحرارة منA؟' if mode=='source' else f'ما مقدار معدل الحرارة في الوصلة{labels[a]}–{labels[b]}؟')
        explanation='التدفق الحراري=الموصلية×فرق الحرارة؛ في العقد الداخلية المستقرة لا تتراكم طاقة، فيتوازن مجموع التدفقات.'
    elif kind=='capacitor':
        intro=f'شبكة مكثفات مثالية، عقدها الداخلية معزولة وشحنتها الصافية صفر. تُوصلA بجهد{fixed}فولت و{labels[-1]} بجهد0.';subject='سعة بالميكروفاراد';unit=' فولت' if mode in ['node','change'] else ' ميكروكولوم'
        ask=f'ما جهد العقدة{labels[target]} بعد الاستقرار؟' if mode in ['node','change'] else ('ما مقدار الشحنة على الألواح المتصلة بالطرفA؟' if mode=='source' else f'ما مقدار الشحنة على أحد لوحي مكثف{labels[a]}–{labels[b]}؟')
        explanation='شحنة اللوح=C×فرق الجهد. مجموع شحنات الألواح المتصلة بأي عقدة داخلية يساوي صفرًا لأنها معزولة وغير مشحونة صافيًا.'
    else:
        intro=f'شبكة نوابض أفقية خطية بعقد عديمة الكتلة؛ جميع الإزاحات في محور واحد ومقيسة من حالة لا شد فيها. إزاحةA={fixed}ملم و{labels[-1]}=0، والعقد الداخلية حرة في الاتزان.';subject='ثابت نابض بنيوتن/ملم';unit=' ملم' if mode in ['node','change'] else ' نيوتن'
        ask=f'ما إزاحة العقدة{labels[target]}؟' if mode in ['node','change'] else ('ما مقدار القوة اللازمة لتثبيتA؟' if mode=='source' else f'ما مقدار القوة في نابض{labels[a]}–{labels[b]}؟')
        explanation='قوة النابض=k×فرق الإزاحة. كل عقدة داخلية بلا قوة خارجية تستقر عندما يكون مجموع قوى النوابض عليها صفرًا.'
    # Print values before the design modification, with the required change explicit.
    original=ed[:]
    if mode=='change':a,b,g=original[idx];original[idx]=(a,b,g/2)
    network='؛ '.join(f'{labels[a]}↔{labels[b]}:{num(1/g if kind in ["electric","fluid"] else g)}' for a,b,g in original)
    change=''
    if mode=='change':
        a,b,g=original[idx]
        change=f' ثم غُيرت وصلة{labels[a]}–{labels[b]} وحدها إلى '+num(1/(2*g) if kind in ['electric','fluid'] else 2*g)+'.'
    text=intro+' جميع الروابط التالية فقط، وقيمها '+subject+': '+network+'.'+change+' '+ask
    ex=explanation+' الحل يعطي قيم العقد '+ '، '.join(f'{labels[i]}={num(v)}' for i,v in enumerate(vals))+f'. القيمة المطلوبة{num(value)}{unit}.'
    return numeric(text,value,'اكتب توازنًا مستقلًا لكل عقدة داخلية قبل حساب كمية الوصلة أو الطرف المطلوب.',ex,unit,[f'OpenStax؛ النموذج الأساسي: {source}','مسألة شبكة أصلية؛ القيم والروابط مستقلة، والتحقق بحل معادلات الاتزان.'],proof={'engine':'physical_network','kind':kind,'n':n,'conductances':[[a,b,num(g)] for a,b,g in ed],'fixed':fixed,'mode':mode,'node':target,'edge':[a,b] if mode=='link' else None,'solution':num(value)})

def build_science():
    pools={d:[] for d in LEVELS};seen=set()
    for t,a,w,h,e,s in SCI_EASY:pools['easy'].append(problem(t,a,w.split('|'),h,e,[SCI_SOURCES[s]]))
    kinds=['electric','heat','fluid','capacitor','spring']
    for level,count in [('medium',174),('hard',225),('legendary',224)]:
        i=0
        while len(pools[level])<count:
            q=science_network(level,i,kinds[i%len(kinds)]);i+=1
            signature=re.sub(r'\d+','#',q['text'])
            if signature in seen:continue
            seen.add(signature);pools[level].append(q)
    return pools

def write_category(cat,pools):
    path=ROOT/'assets/questions'/f'{cat}.json'; bank=json.loads(path.read_text(encoding='utf-8-sig'))
    old={q['id']:dict(q) for q in bank['questions']};counts=Counter();out=[]
    for level in LEVELS:
        original_ids=set(json.loads((ROOT/'tool/reasoning_original_ids.json').read_text(encoding='utf-8')))
        targets=[q for q in bank['questions'] if q['difficulty']==level and (q.get('qualityStatus')=='quarantined' or q['id'] in original_ids)]
        targets += [dict(id=f'{cat}-{level}-{i:04}',categoryId=cat,difficulty=level) for i in range(201,226)]
        assert len(pools[level])>=len(targets),(cat,level,len(targets),len(pools[level]))
        for target,q in zip(targets,pools[level]):
            proof=q.pop('_proof',None)
            q=dict(id=target['id'],categoryId=cat,difficulty=level,**q)
            old[q['id']]=q;counts['replaced' if int(q['id'].split('-')[-1])<=200 else 'added']+=1
            if proof:LEDGER.append(dict(id=q['id'],**proof))
    bank['questions']=sorted(old.values(),key=lambda q:(LEVELS.index(q['difficulty']),q['id']))
    bank['targetCount']=900;bank['targetPerDifficulty']=225;bank['status']='draft'
    path.write_text(json.dumps(bank,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(cat,dict(counts),len(bank['questions']),Counter(q['difficulty'] for q in bank['questions']))

if __name__=='__main__':
    import sys
    if 'riddles' in sys.argv:write_category('riddles',build_riddles())
    if 'maps' in sys.argv:write_category('maps',build_maps())
    if 'how_it_works' in sys.argv:
        raise SystemExit('The numerical science candidate set was rejected. Use stage_science_mechanisms.py for the approved qualitative draft; it stages safely outside live assets.')
    proofpath=ROOT/'tool/reasoning_proofs.json'
    proofold=json.loads(proofpath.read_text(encoding='utf-8')) if proofpath.exists() else []
    merged={p['id']:p for p in proofold+LEDGER}
    proofpath.write_text(json.dumps(list(merged.values()),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
