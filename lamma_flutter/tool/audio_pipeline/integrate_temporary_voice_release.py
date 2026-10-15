"""Apply the explicitly reviewed current pack after human authorization of its method.

No bulk approval from file counts: every included filename must have an explicit
editorial decision and two actual final-file SHA-bound transcripts.
"""
import collections,copy,datetime,hashlib,json,pathlib,shutil
ROOT=pathlib.Path(__file__).resolve().parents[2]
OUT=ROOT/'design_sources/character_voice_repair/research-20261015'
bank_path=ROOT/'assets/questions/character_voice.json'
baseline=OUT/'bank-before-temporary-approval.json'
if not baseline.exists():shutil.copy2(bank_path,baseline)
bank=json.loads(baseline.read_text(encoding='utf-8'))
proposal=json.loads((OUT/'proposed-character-voice.json').read_text(encoding='utf-8'))
changes=json.loads((OUT/'replacement-identities.json').read_text(encoding='utf-8'))
decisions=json.loads((OUT/'temporary_editorial_decisions.json').read_text(encoding='utf-8'))
models={}
for model,name in [('tiny.en','machine-transcripts.jsonl'),('small.en','machine-transcripts-small.en.jsonl')]:
    models[model]={r['sha256']:r for r in map(json.loads,(OUT/name).read_text(encoding='utf-8').splitlines())}
proposed={q['id']:q for q in proposal['questions']}
replacement_by_id={r['previousQuestionId']:r for r in changes}
registry_path=ROOT/'tool/question_usage_ids.json'
registry=json.loads(registry_path.read_text(encoding='utf-8'))
approved=[];evidence=[];at=datetime.datetime.now(datetime.timezone.utc).isoformat()
credits=['# Sound asset credits — temporary source/transcript review, 15 October 2026',
    'The user authorized temporary documentary-source plus machine-transcript review. No human listening or biometric identification is claimed. Only the individually documented clips below are available for gameplay; the remaining 73 questions stay quarantined. Media licenses apply to their sound assets, not to the application as a whole. Cropping, mono/MP3 conversion, loudness normalization and metadata removal are disclosed. No endorsement is implied.\n']
for index,old in enumerate(bank['questions']):
    q=copy.deepcopy(old)
    if old['id'] in replacement_by_id:
        replacement=proposed[replacement_by_id[old['id']]['replacementQuestionId']]
        audio=replacement['audio']
        candidate=int(pathlib.Path(audio['assetPath']).stem.split('-')[-1])
        source=ROOT/f'design_sources/character_voice_repair/prepared-bbc-20261015/candidate-{candidate:03}.mp3'
        key=source.name
        if key not in decisions['decisions']:continue
        if not source.is_file():raise ValueError(f'Explicitly selected clip missing: {key}')
        q=copy.deepcopy(replacement)
        shutil.copy2(source,ROOT/q['audio']['assetPath'])
        registry['ids'][q['id']]=q['usageId']
    elif q.get('audio') and pathlib.Path(q['audio']['assetPath']).name in decisions['decisions']:
        source=ROOT/q['audio']['assetPath'];key=source.name
    else:continue
    digest=hashlib.sha256(source.read_bytes()).hexdigest()
    transcripts={model:rows.get(digest) for model,rows in models.items()}
    if any(r is None or not r['transcript'].strip() for r in transcripts.values()):
        raise ValueError(f'Two actual final-clip transcripts required: {key}')
    audio=q['audio'];evidence_id=q['id']+'-'+digest[:12]
    audio.update(reviewStatus='approved',listeningStatus='machineTranscribed',
        reviewMethod='sourceTranscript',contentSha256=digest,
        transcriptionModel='faster-whisper-tiny.en,faster-whisper-small.en',reviewEvidenceId=evidence_id,
        reviewedBy='Codex — documentary source and actual-clip machine transcript review',reviewedAt=at,
        durationMs=round(transcripts['small.en']['durationSeconds']*1000))
    if not audio.get('transcript'):audio['transcript']=transcripts['small.en']['transcript']
    q['qualityStatus']='reviewed';q.pop('qualityReasons',None)
    q['explanation']=q['explanation'].replace(' لم تتم المراجعة السمعية النهائية.','').replace(' التفريغ والاستماع النهائي لم يُنجزا.','').replace(' بداية المقتطف وتفريغه ينتظران الاستماع.','').replace(' المرشح ينتظر مراجعة المقتطف النهائي قبل اللعب.','')
    q['explanation']+=' مراجعة مؤقتة بالمصدر والتفريغ الآلي، دون ادعاء استماع بشري.'
    bank['questions'][index]=q;approved.append(q)
    evidence.append(dict(id=evidence_id,questionId=q['id'],speaker=q['answer'],assetPath=audio['assetPath'],sha256=digest,
        sourceUrl=audio['sourceUrl'],sourceStartMs=audio['sourceStartMs'],sourceEndMs=audio['sourceEndMs'],
        license=audio['license'],licenseUrl=audio['licenseUrl'],reviewMethod=audio['reviewMethod'],
        humanListeningPerformed=False,editorialDecision=decisions['decisions'][key],reviewedBy=audio['reviewedBy'],reviewedAt=at,
        machineTranscripts=transcripts))
    credits.extend([f'## {pathlib.Path(audio["assetPath"]).name} — {q["answer"]}',f'- Original source: {audio["sourceUrl"]}',
        f'- License: {audio["license"]}',f'- License evidence: {audio["licenseUrl"]}',f'- Attribution and changes: {audio["attribution"]}',
        f'- Original cut: {audio["sourceStartMs"]}–{audio["sourceEndMs"]} ms; decoded output {audio["durationMs"]} ms.',
        f'- SHA256: {digest}',f'- Review: sourceTranscript / machineTranscribed; evidence {evidence_id}; no human listening.\n'])
if len(approved)!=len(decisions['decisions']):raise ValueError('Not all explicit editorial decisions were applied')
bank_path.write_text(json.dumps(bank,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
registry_path.write_bytes((json.dumps(registry,ensure_ascii=False,indent=2)+'\n').encode('utf-8'))
(ROOT/'assets/question_audio/review_evidence.json').write_text(json.dumps(dict(schemaVersion=1,method='sourceTranscript',humanListeningPerformed=False,recordings=evidence),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(ROOT/'assets/question_audio/LICENSES.md').write_text('\n'.join(credits),encoding='utf-8')
print('Integrated',len(approved),'explicitly reviewed clips. Remaining',len(bank['questions'])-len(approved),'questions stay quarantined.')
print('Playable difficulty distribution:',dict(collections.Counter(q['difficulty'] for q in approved)))
