"""Stage an explicit 100-question proposal. Does not edit the live bank or approve audio."""
import collections,copy,json,pathlib,random,secrets
ROOT=pathlib.Path(__file__).resolve().parents[2]
OUT=ROOT/'design_sources/character_voice_repair/research-20261015'
baseline=OUT/'bank-before-temporary-approval.json'
original=json.loads((baseline if baseline.exists() else ROOT/'assets/questions/character_voice.json').read_text(encoding='utf-8'))
source_rows=json.loads((OUT/'selected-bbc-manifest.json').read_text(encoding='utf-8'))
staged=OUT/'proposed-character-voice.json'
prior={q['id']:q['usageId'] for q in json.loads(staged.read_text(encoding='utf-8'))['questions']} if staged.exists() else {}
registry=json.loads((ROOT/'tool/question_usage_ids.json').read_text(encoding='utf-8'))['ids']
used=set(registry.values())|set(prior.values())
def usage_id(qid):
    if qid in prior:return prior[qid]
    value=str(secrets.randbits(128))
    while value in used:value=str(secrets.randbits(128))
    used.add(value);return value
keep=[copy.deepcopy(q) for q in original['questions'] if q.get('audio') and not q['audio']['assetPath'].endswith('voice-076.mp3')]
retired={tier:[q for q in original['questions'] if q['difficulty']==tier and q['id'] not in {k['id'] for k in keep}] for tier in ['easy','medium','hard','legendary']}
questions=list(keep);replacements=[]
counter=collections.Counter(q['correctOptionId'] for q in keep)
quotas=dict(zip('ABCDEF',[17,17,17,17,16,16]))
transcripts={}
for name in ['machine-transcripts.jsonl','machine-transcripts-small.en.jsonl']:
    p=OUT/name
    if p.exists():
        for line in p.read_text(encoding='utf-8').splitlines():
            r=json.loads(line);transcripts[r['file']]=r
pools=json.loads((OUT/'distractor_pools.json').read_text(encoding='utf-8'))
group_order='''britishMale baritoneUS modernUS veteranUS britishMale britishWomen femaleFantasyWriter classicMaleMusician blackWomen veteranUS britishMale maleSciencePresenter modernUS britishMale classicMaleMusician baritoneUS britishWomen fantasyWriterMale maleSinger rockMale fantasyWriterMale directorUSMale britishMale veteranUS modernUS directorInternationalMale directorInternationalMale rockMale womenWriterWorld womenWriterIndian maleWriterAsia womenWriterAfrican malePlaywright maleCrimeWriter maleCrimeWriter psychologistMale maleSciencePresenter computerPioneers womenNaturalists psychologistMale economistAsianMale economistUSMale artistMale artistMale artistMale womenPolitician womenActivist womenPolitician womenScientists womenAthlete maleAthlete maleFootball maleAthlete womenAthlete AustralianMale britishWomenYoung britishWomen britishWomen maleComedianGB maleComedianGB britishWomen britishMale britishMale britishMale britishMale animationMale directorInternationalMale directorInternationalMale femaleDirector womenWriterAfricanUS womenWriterWorld womenWriterUS womenWriterWorld writerUS maleWriterAsia womenWriterAsian writerAUS womenHistorianWriter womenHistorianWriter femaleCrimeWriter maleCrimeWriter writerGB writerGB maleHistorian scientistMale scientistMale classicalMusicMale femaleSingerUS femaleSingerEurope'''.split()

counts=collections.Counter(q['difficulty'] for q in keep)
for row in source_rows:
    tier=next(t for t in ['easy','medium','hard','legendary'] if counts[t]<25)
    counts[tier]+=1
    number=sum(q['id'].startswith('character_voice-r2-'+tier+'-') for q in questions)+1
    qid=f'character_voice-r2-{tier}-{number:04}'
    rng=random.Random(qid)
    peers=[name for name in pools[group_order[row['candidate']-1]] if name!=row['speaker']]
    choices=rng.sample(peers,5)
    correct=min((k for k in 'ABCDEF' if counter[k]<quotas[k]),key=lambda k:(counter[k]/quotas[k],list('ABCDEF').index(k)))
    counter[correct]+=1
    choices.insert(ord(correct)-ord('A'),row['speaker'])
    proposed_path=f'assets/question_audio/voice-r2-{row["candidate"]:03}.mp3'
    prepared_path=f'design_sources/character_voice_repair/prepared-bbc-20261015/candidate-{row["candidate"]:03}.mp3'
    transcript=transcripts.get(prepared_path)
    audio={key:row[key] for key in ['speaker','recordingId','sourceUrl','license','licenseUrl','attribution','sourceStartMs','sourceEndMs']}
    audio.update(assetPath=proposed_path,durationMs=row['sourceEndMs']-row['sourceStartMs'],
        reviewStatus='sourceVerified',listeningStatus='pending',transcript=transcript['transcript'] if transcript else '')
    old=retired[tier].pop(0)
    questions.append(dict(id=qid,categoryId='character_voice',difficulty=tier,text='استمع إلى المقطع. من صاحب هذا الصوت؟',
        answer=row['speaker'],acceptedAnswers=[],hint=row['hint'],clues=[],
        explanation='المتحدث '+row['speaker']+'؛ مقتطف من تسجيل BBC المنشور في المصدر المرفق. المرشح ينتظر مراجعة المقتطف النهائي قبل اللعب.',
        sources=[row['sourceUrl'],row['licenseUrl']],options=[dict(id=k,text=v) for k,v in zip('ABCDEF',choices)],
        correctOptionId=correct,qualityStatus='quarantined',qualityReasons=['مرشح بديل بإذن المستخدم؛ لم يعتمد المقتطف النهائي للعب بعد.'],
        usageId=usage_id(qid),audio=audio))
    replacements.append(dict(previousQuestionId=old['id'],previousUsageId=old['usageId'],previousAnswer=old['answer'],
        replacementQuestionId=qid,replacementUsageId=questions[-1]['usageId'],replacementAnswer=row['speaker'],
        recordingId=row['recordingId'],sourceUrl=row['sourceUrl'],reason='User authorized replacing unavailable or unsuitable original recordings with authentic recordings of different people.'))

staged.write_text(json.dumps({**original,'status':'draft','questions':questions},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(OUT/'replacement-identities.json').write_text(json.dumps(replacements,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Staged',len(questions),'questions;',dict(counts),'; new identities:',len(replacements),'; no live bank or device history changed.')
