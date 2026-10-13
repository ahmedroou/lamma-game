"""Independent checks of original reasoning questions, not editorial approval."""
import json,re,math
from pathlib import Path
from fractions import Fraction as F
from itertools import product,permutations
from collections import Counter
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
def index(s):return 'أبجدهو'.index(s)
def number(q):
    a=q['answer'].split()[0]
    return F(a)
def test_order(p,b):
    def pos(c):return b.index(c)
    for c in p['constraints']:
        if ' قبل ' in c:a,z=c.split(' قبل ');ok=pos(a)<pos(z)
        elif 'بين ' in c:a,z=re.search('بين (.) و(.)',c).groups();ok=abs(pos(a)-pos(z))==2
        elif 'غير متجاورين' in c:a,z=re.search('^(.) و(.)',c).groups();ok=abs(pos(a)-pos(z))!=1
        else:a,z=re.search('^(.) و(.)',c).groups();ok=abs(pos(a)-pos(z))==1
        if not ok:return False
    return True
def test_secret(p,b):
    for c in p['constraints']:
        if 'إما معًا' in c:a,z=re.search('^(.) و(.)',c).groups();ok=b[index(a)]==b[index(z)]
        elif 'واحد فقط' in c:a,z=re.search('من (.) و(.)',c).groups();ok=b[index(a)]!=b[index(z)]
        elif 'يستلزم' in c:a,z=re.search('حضور (.) يستلزم حضور (.)',c).groups();ok=not b[index(a)] or b[index(z)]
        else:
            group=c.split('بين ')[1].split(' هو')[0];total=int(c.split('هو')[-1]);ok=sum(b[index(a)] for a in group.split('، '))==total
        if not ok:return False
    return True
def test_knights(p,b):
    for i,s in enumerate(p['statements']):
        c=s.split('«')[1].split('»')[0]
        names=re.findall('[أبجدهو]',c)
        if 'من النوع نفسه' in c:a,z=re.search('^(.) و(.)',c).groups();v=b[index(a)]==b[index(z)]
        elif 'نوعين مختلفين' in c:a,z=re.search('^(.) و(.)',c).groups();v=b[index(a)]!=b[index(z)]
        elif 'كلاهما صادق' in c:a,z=re.search('^(.) و(.)',c).groups();v=bool(b[index(a)] and b[index(z)])
        elif 'على الأقل' in c:a,z=re.search('أحد (.) و(.)',c).groups();v=bool(b[index(a)] or b[index(z)])
        elif c.endswith('كاذب'):v=not b[index(c[0])]
        else:a,z=re.search('إذا كان (.) صادقًا فإن (.)',c).groups();v=not b[index(a)] or b[index(z)]
        if bool(b[i])!=v:return False
    return True
def test_lock(p,b):
    ns=['الأول','الثاني','الثالث','الرابع']
    for c in p['constraints']:
        names=[ns.index(a) for a in re.findall('الأول|الثاني|الثالث|الرابع',c)];a,z=names[:2]
        if 'أكبر' in c:ok=b[a]>b[z]
        elif 'أصغر' in c:ok=b[a]<b[z]
        elif c.startswith('مجموع'):ok=b[a]+b[z]==int(c.split('هو')[-1])
        elif c.startswith('الفارق'):ok=abs(b[a]-b[z])==int(c.split('هو')[-1])
        else:ok=(b[a]*b[z]+b[names[2]])%7==int(c.split('هو')[-1])
        if not ok:return False
    return True
def adjacent(i,n):
    out=[]
    for d in [-n,n,-1,1]:
        j=i+d
        if 0<=j<n*n and (abs(d)==n or i//n==j//n):out.append(j)
    return out
def grid_components(data,n):
    parent=list(range(n*n))
    def root(i):
        while parent[i]!=i:i=parent[i]
        return i
    for i,v in enumerate(data):
        if not v:continue
        for j in adjacent(i,n):
            if data[j]:parent[root(i)]=root(j)
    return root,Counter(root(i) for i,v in enumerate(data) if v)
def graph_check(p):
    n=p['n'];edges=p['edges'];adj={i:[] for i in range(n)}
    for a,b,w in edges:adj[a].append((b,w));adj[b].append((a,w))
    routes=[]
    queue=[(0,[0],0)]
    while queue:
        i,path,cost=queue.pop()
        if i==n-1:routes.append((path,cost));continue
        for j,w in adj[i]:
            if j not in path:queue.append((j,path+[j],cost+w))
    extra=p['extra'];mode=p['mode']
    if mode in ['via','avoid']:
        m=ord(re.search('المحطة([A-G])',extra)[1])-65
        routes=[r for r in routes if (m in r[0])==(mode=='via')]
    elif mode=='few':
        limit=int(re.search(r'من(\d+)',extra)[1]);routes=[r for r in routes if len(r[0])-1<=limit]
    else:
        a,z=[ord(x)-65 for x in re.findall('[A-G]',extra)]
        routes=[r for r in routes if a in r[0] and z in r[0] and r[0].index(a)<r[0].index(z)]
    best=min(r[1] for r in routes);sol=[r[0] for r in routes if r[1]==best]
    assert sol==[p['solution']] and best==p['cost']
def check(p,q):
    e=p['engine']
    if e=='two_digit_lock':
        solutions=[10*a+b for a,b in product(range(1,10),repeat=2)
                   if a+b==p['digitSum'] and a*b==p['digitProduct'] and bool(a%2)==p['oddTens']]
        assert solutions==[p['solution']] and number(q)==p['solution']
    elif e=='order':
        labels=list('أبجدهو')[:p['n']];sol=[list(b) for b in permutations(labels) if test_order(p,b)];assert sol==[p['solution']]
    elif e in ['secret','truth']:
        f=test_secret if e=='secret' else test_knights;sol=[list(b) for b in product([0,1],repeat=p['n']) if f(p,b)];assert sol==[p['solution']]
    elif e=='lock':
        n=len(p['solution']);ds=range(1,8 if n==3 else 7);sol=[list(b) for b in permutations(ds,n) if test_lock(p,b)];assert sol==[p['solution']]
    elif e=='switch':
        n=len(p['columns']);sol=[]
        for b in product([0,1],repeat=n):
            counts=[sum(b[i] for i,c in enumerate(p['columns']) if c>>j&1)%2 for j in range(n)]
            if sum(v<<j for j,v in enumerate(counts))==p['target']:sol.append(list(b))
        assert sol==[p['solution']]
    elif e=='graph':graph_check(p)
    elif e=='map_walk':
        assert [sum(v[0] for v in p['steps']),sum(v[1] for v in p['steps'])]==p['solution']
    elif e=='drainage':
        i=p['start'];visited=set()
        while True:
            assert i not in visited;visited.add(i);ns=adjacent(i,p['n']);j=min(ns,key=lambda j:p['heights'][j])
            if p['heights'][j]>=p['heights'][i]:break
            i=j
        assert i==p['solution']
    elif e=='terrain_path':
        n=p['n'];d=[math.inf]*(n*n);d[p['start']]=0
        for _ in range(n*n):
            changed=False
            for i in range(n*n):
                if i in p['blocked']:continue
                for j in adjacent(i,n):
                    if j in p['blocked']:continue
                    v=d[i]+1+max(0,p['heights'][j]-p['heights'][i])
                    if v<d[j]:d[j]=v;changed=True
            if not changed:break
        assert d[p['end']]==p['solution']==number(q)
    elif e=='regions':
        grid=p['grid'];n=p['n'];root,sizes=grid_components(grid,n);m=p['mode']
        if m=='number':v=len(sizes)
        elif m=='largest':v=max(sizes.values())
        elif m=='coast':v=sum(1 for i,a in enumerate(grid) if a for face in [i-n,i+n,i-1,i+1] if face not in adjacent(i,n) or not grid[face])
        else:v=max(1+sum(sizes[r] for r in {root(j) for j in adjacent(i,n) if grid[j]}) for i,x in enumerate(grid) if not x)
        assert v==p['solution']==number(q)
    elif e=='physical_network':
        n=p['n'];links=[(a,b,float(F(g))) for a,b,g in p['conductances']]
        L=np.zeros((n,n))
        for a,b,g in links:L[a,a]+=g;L[b,b]+=g;L[a,b]-=g;L[b,a]-=g
        v=np.zeros(n);v[0]=p['fixed'];v[1:-1]=np.linalg.solve(L[1:-1,1:-1],-L[1:-1,0]*p['fixed'])
        assert np.max(np.abs((L@v)[1:-1]))<1e-8
        mode=p['mode']
        if mode in ['node','change']:ans=v[p['node']]
        elif mode=='source':ans=(L@v)[0]
        else:
            a,b=p['edge'];g=next(g for x,y,g in links if [x,y]==[a,b]);ans=abs(g*(v[a]-v[b]))
        assert abs(ans-float(F(p['solution'])))<1e-7 and abs(ans-float(number(q)))<1e-7
    else:raise AssertionError('Unsupported engine '+e)

def main():
    import sys
    directory=ROOT/('tool/staging' if '--staged' in sys.argv else 'assets/questions')
    banks={c:json.loads((directory/f'{c}.json').read_text(encoding='utf-8')) for c in ['riddles','maps','how_it_works']}
    questions={q['id']:q for b in banks.values() for q in b['questions']}
    ledger=json.loads((ROOT/'tool/reasoning_proofs.json').read_text(encoding='utf-8'))
    counts=Counter()
    for p in ledger:
        if p['id'] not in questions:continue
        q=questions[p['id']]
        if p['engine']=='physical_network' and 'شبكة' not in q['text']:continue
        try:check(p,q)
        except Exception as ex:raise AssertionError(p['id']+': '+str(ex)) from ex
        counts[p['engine']]+=1
    for c,b in banks.items():
        assert len(b['questions'])==900 and Counter(q['difficulty'] for q in b['questions'])==dict.fromkeys(['easy','medium','hard','legendary'],225)
        ids=set()
        for q in b['questions']:
            assert q['id'] not in ids;ids.add(q['id'])
            assert len(q['options'])==6 and {o['id'] for o in q['options']}==set('ABCDEF')
            assert len({o['text'] for o in q['options']})==6
            assert [o['id'] for o in q['options'] if o['text'] in [q['answer'],*q['acceptedAnswers']]]==[q['correctOptionId']]
            assert q['hint'] and q['explanation'] and q['sources']
            assert q.get('qualityStatus')!='quarantined'
            if q.get('imageAsset'):assert (ROOT/q['imageAsset']).exists()
    print('Independent original-problem checks:',sum(counts.values()),dict(counts))
    print('Three banks: 900 each;225/difficulty; stable IDs, six options, unique answer linkage, media and no quarantine passed.')

if __name__=='__main__':main()
