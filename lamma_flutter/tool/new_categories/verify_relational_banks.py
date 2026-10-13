"""Independent delivery checks, including unordered solutions.

This checks the authored assertions against their explicit factual catalog. It
cannot certify human difficulty or discover every semantic alternative link.
"""
from pathlib import Path
import collections, json, re, hashlib
OUT=Path(__file__).parent
errors=[]
def check(condition,message):
    if not condition:errors.append(message)

def partition(s):
    blocks=s.split('؛ ')
    return frozenset(frozenset(b.split(': ',1)[1].split('، ')) for b in blocks)

def partition_labeled(s):
    return {b.split(': ',1)[0]:frozenset(b.split(': ',1)[1].split('، ')) for b in s.split('؛ ')}

def pairs(s):
    return frozenset(tuple(b.split(' ← ',1)) for b in s.split('؛ '))

catalog=json.loads((OUT/'relational_fact_pools.json').read_text(encoding='utf-8'))
catalog_by_domain=collections.defaultdict(dict)
for g in catalog:catalog_by_domain[g['domain']][g['label']]=set(g['items'])
facts=json.loads((OUT/'relational_direct_facts.json').read_text(encoding='utf-8'))
allowed=set()
for group in facts.values():
    for fact in group:
        allowed.add((fact['left'],fact['right']))
        allowed.add((fact['right'],fact['left']))
for g in catalog:
    if g['domain'].startswith('تقسيمات M49'):
        for country in g['items']:
            allowed.add((country,g['label']))
            allowed.add((g['label'],country))

report=dict(categories={},errors=errors,limitations=[
 'The catalog is an authoring aid, not an independent historical authority.',
 'All records remain draft/unreviewed. No automatic check awards editorial review.',
 'The split frames name the allowed classification dimension; uniqueness is verified within that frame.',
 'Blank matching positions are explicitly fungible; the requested answer is the reconstructed set of pairs.',
 'Difficulty still needs a game/editorial review, especially obscure scientific laureates and Python modules.',
])
all_ids=set();identity=set()
for cat in ['split_groups','pair_up','relationship']:
    path=OUT/f'{cat}.json';data=json.loads(path.read_text(encoding='utf-8'));qs=data['questions']
    check(len(qs)==300,cat+': count')
    counts=collections.Counter(q['difficulty'] for q in qs)
    check(all(counts[d]==75 for d in ['easy','medium','hard','legendary']),cat+': difficulty counts')
    option_counts=collections.Counter();missing_counts=collections.Counter();missing_left_counts=collections.Counter();pair_sizes=collections.Counter();domain_counts=collections.Counter();group_links=set()
    semantic_seen=set()
    for q in qs:
        id=q['id'];check(id not in all_ids,id+': duplicate id');all_ids.add(id)
        check(re.fullmatch(re.escape(cat)+r'-(easy|medium|hard|legendary)-00[0-9]{2}',id) is not None,id+': format')
        for f in ['text','answer','hint','explanation','sources']:
            check(bool(q.get(f)),id+': empty '+f)
        check(q['qualityStatus']=='unreviewed',id+': unearned reviewed')
        options=q['options'];check([x['id'] for x in options]==list('ABCDEF'),id+': option identifiers')
        check(len({x['text'] for x in options})==6,id+': repeated options')
        check(sum(x['text']==q['answer'] for x in options)==1,id+': correct option multiplicity')
        check(next(x['text'] for x in options if x['id']==q['correctOptionId'])==q['answer'],id+': correct option')
        option_counts[q['correctOptionId']]+=1
        presentation=q.get('presentation')
        if presentation:
            items=[i for s in presentation['sections'] for i in s['items']]
            check(len({i['id'] for i in items})==len(items),id+': element identifiers')
            for i in items:
                check(bool(i['text']),id+': empty element')
                if i.get('missing'):check(i['text']=='؟',id+': blank leaks text')
        if cat=='split_groups':
            check(presentation['type']=='grouping',id+': grouping presentation')
            check(len(items) in [6,8],id+': item count')
            canon=[partition(o['text']) for o in options]
            check(len(set(canon))==6,id+': reordered partition distractor')
            actual=partition(q['answer'])
            check(actual not in semantic_seen,id+': repeated semantic partition');semantic_seen.add(actual)
            check(sum(c==actual for c in canon)==1,id+': equivalent correct partitions')
            itemset=set(i['text'] for i in items)
            for c in canon:
                check(len(c)==2 and all(len(g)==len(items)//2 for g in c),id+': unequal split')
                check(set.union(*(set(g) for g in c))==itemset,id+': incomplete solution')
                check(sum(map(len,c))==len(itemset),id+': duplicate item in solution')
            if 'السياق: ' in q['text']:
                frame=q['text'].split('السياق: ',1)[1].rstrip('.')
            else:
                marker_prefixes=[('M49','تقسيمات M49'),('التراث العالمي','مواقع التراث'),('الجدول الدوري','الكيمياء:'),('المنتجات','منتجات وخدمات'),('Python','مكتبة Python'),('الأقمار','أقمار طبيعية'),(' SI','النظام الدولي'),('HTML','HTML:'),('ألّف','الأعمال الأدبية')]
                frame=next(d for marker,prefix in marker_prefixes if marker in q['text'] for d in catalog_by_domain if d.startswith(prefix))
            check(frame in catalog_by_domain,id+': unknown frame')
            labeled=[partition_labeled(o['text']) for o in options]
            truth=[]
            for opt in labeled:
                truth.append(all(label in catalog_by_domain[frame] and subset<=catalog_by_domain[frame][label] for label,subset in opt.items()))
            check(sum(truth)==1,id+': factual distractor validity')
            group_links.update((frame,label) for label in labeled[options.index(next(o for o in options if o['id']==q['correctOptionId']))])
            domain_counts[frame]+=1
            # Two declared classes have to be disjoint, and every displayed
            # member must belong to precisely one of the two classes.
            correct=labeled[options.index(next(o for o in options if o['id']==q['correctOptionId']))]
            pools=[catalog_by_domain[frame][lab] for lab in correct]
            check(not(pools[0]&pools[1]),id+': overlapping classes')
            check(all(sum(t in p for p in pools)==1 for t in itemset),id+': ambiguous membership')
        elif cat=='pair_up':
            check(presentation['type']=='matching',id+': matching presentation')
            left=presentation['sections'][0]['items'];right=presentation['sections'][1]['items']
            pair_count=len(left)
            check(pair_count in (2,3) and len(right)==pair_count,id+': pair count')
            pair_sizes[pair_count]+=1
            missing_left=sum(bool(i.get('missing')) for i in left)
            missing_right=sum(bool(i.get('missing')) for i in right)
            missing_left_counts[missing_left]+=1
            missing_counts[sum(bool(i.get('missing')) for i in right)]+=1
            solution=pairs(q['answer']);check(len(solution)==pair_count,id+': complete pairs')
            check(all(p in allowed for p in solution),id+': unsupported pair')
            check(len({p[0] for p in solution})==len({p[1] for p in solution})==pair_count,id+': repeated endpoint')
            shown_left={i['text'] for i in left if not i.get('missing')}
            shown_right={i['text'] for i in right if not i.get('missing')}
            check(shown_left<={p[0] for p in solution},id+': shown left mismatch')
            check(shown_right<={p[1] for p in solution},id+': shown right mismatch')
            check(len({p[0] for p in solution}-shown_left)==missing_left,id+': missing left count')
            check(len({p[1] for p in solution}-shown_right)==missing_right,id+': missing right count')
            canon=[pairs(o['text']) for o in options];check(len(set(canon))==6,id+': duplicate pairing option')
            check(sum(c==solution for c in canon)==1,id+': two correct pairings')
            truth=[all(p in allowed for p in c) for c in canon]
            check(sum(truth)==1,id+': multiple supported matchings')
            for c in canon:
                check(len(c)==pair_count and len({p[0] for p in c})==len({p[1] for p in c})==pair_count,id+': incomplete/duplicated option endpoints')
                check(shown_left<={p[0] for p in c} and shown_right<={p[1] for p in c},id+': option omits displayed endpoint')
            if pair_count==3:
                # The original three-pair questions still require all six
                # complete permutations of the same two endpoint sets.
                check(missing_left==0,id+': unexpected three-pair blank left')
                for c in canon:
                    check({p[0] for p in c}=={p[0] for p in solution} and {p[1] for p in c}=={p[1] for p in solution},id+': three-pair option changes endpoint set')
            else:
                # Exactly one blank, one fixed known pair and six distinct
                # candidate fills; only one of them is supported by the catalog.
                check(missing_left+missing_right==1,id+': two-pair blank count')
                known={p for p in solution if p[0] in shown_left and p[1] in shown_right}
                check(len(known)==1,id+': expected one known fixed pair')
                variable=next(iter(solution-known))
                fill_values=set()
                for c in canon:
                    check(known<=c,id+': known pair changed in distractor')
                    rest=c-known
                    check(len(rest)==1,id+': expected one variable pair')
                    candidate=next(iter(rest))
                    if missing_left:
                        check(candidate[1]==variable[1],id+': known right anchor changed')
                        fill_values.add(candidate[0])
                    else:
                        check(candidate[0]==variable[0],id+': known left anchor changed')
                        fill_values.add(candidate[1])
                check(len(fill_values)==6,id+': repeated blank fill')
                if 'الأساسية' in q['text']:
                    basic_units={x['left'] for x in facts['units'][:7]}
                    check(fill_values<=basic_units,id+': non-basic SI candidate')
                else:
                    geo_labels={g['label'] for g in catalog if g['domain'].startswith('تقسيمات M49')}
                    check('M49' in q['text'] and fill_values<=geo_labels,id+': unknown constrained geographic frame')
            identity=frozenset(frozenset(p) for p in solution)
            check(identity not in semantic_seen,id+': reversed/reordered prior task');semantic_seen.add(identity)
        else:
            # The displayed two-entity identity is invariant under swapping
            # names; a reversal never counts as a new relationship record.
            tokens=re.findall('«([^»]+)»',q['text'])
            check(len(tokens)==2,id+': expected exactly two entities')
            key=frozenset(tokens)
            check(key not in semantic_seen,id+': duplicated/reversed entity pair');semantic_seen.add(key)
            if 'M49' in q['text']:
                geo=next(v for d,v in catalog_by_domain.items() if d.startswith('تقسيمات M49'))
                truth=[]
                for option in options:
                    label=option['text'].split(' في ',1)[1].split(' وفق ',1)[0]
                    truth.append(label in geo and all(t in geo[label] for t in tokens))
                check(sum(truth)==1,id+': multiple geographic relationships')
                check(truth[ord(q['correctOptionId'])-65],id+': wrong geographic relationship')
        if q['difficulty']=='easy':
            check('Python' not in q['text'] and not any('nobelprize.org' in s for s in q['sources']),id+': specialized source in easy')
    report['categories'][cat]=dict(count=len(qs),difficulties=dict(counts),correctOptions=dict(option_counts),missingRightCounts=dict(missing_counts),missingLeftCounts=dict(missing_left_counts),pairSizeCounts=dict(pair_sizes),groupingFrames=dict(domain_counts),uniqueGroupingLinks=len(group_links),sha256=hashlib.sha256(path.read_bytes()).hexdigest())
(OUT/'relational_validation.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,ensure_ascii=False,indent=2))
if errors:raise SystemExit(1)
