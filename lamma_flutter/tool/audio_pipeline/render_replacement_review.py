"""Render source and actual-clip evidence for individual review, never bulk approve."""
import json,os,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[2]
OUT=ROOT/'design_sources/character_voice_repair/research-20261015'
rows=json.loads((OUT/'selected-bbc-manifest.json').read_text(encoding='utf-8'))
for r in rows:
    r['key']=f'bbc-{r["candidate"]:03}'
    r['path']=f'design_sources/character_voice_repair/prepared-bbc-20261015/candidate-{r["candidate"]:03}.mp3'
bank=json.loads((ROOT/'assets/questions/character_voice.json').read_text(encoding='utf-8'))
for q in bank['questions']:
    a=q.get('audio')
    if a and (ROOT/a['assetPath']).is_file() and not a['assetPath'].endswith('voice-076.mp3'):
        rows.append(dict(key=q['id'],speaker=q['answer'],hint=q['hint'],sourceUrl=a['sourceUrl'],
            license=a['license'],licenseUrl=a['licenseUrl'],attribution=a['attribution'],path=a['assetPath'],
            recordingId=a['recordingId'],sourceStartMs=a['sourceStartMs'],sourceEndMs=a['sourceEndMs']))
transcripts={}
for filename in ['machine-transcripts.jsonl','machine-transcripts-small.en.jsonl']:
    p=OUT/filename
    if p.exists():
        for line in p.read_text(encoding='utf-8').splitlines():
            row=json.loads(line);transcripts[row['file']]=row
for r in rows:
    r['available']=(ROOT/r['path']).is_file()
    r['localUrl']=os.path.relpath(ROOT/r['path'],OUT).replace('\\','/')
    r['machineReview']=transcripts.get(r['path'])
page='''<!DOCTYPE html><html lang="ar" dir="rtl"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>مراجعة أصوات لمّة</title>
<style>body{font:17px system-ui;background:#101318;color:#f0f3ef;max-width:1050px;margin:auto;padding:24px}header{position:sticky;top:0;background:#101318;padding:12px;border-bottom:1px solid #445}button,input,select{font:inherit;padding:10px;border-radius:10px}button{background:#d5f85d;cursor:pointer}article{border:1px solid #445;background:#1a2028;margin:18px 0;padding:20px;border-radius:18px}a{color:#a1d5ff}label{display:block;margin:10px 0}audio{width:100%}.pending{color:#ffc299}.small{font-size:14px;color:#aeb6c4}pre{white-space:pre-wrap;direction:ltr;text-align:left}.links{display:flex;gap:16px;flex-wrap:wrap}</style>
<header><b>مراجعة المئة مقطع — لمّة</b><p class="small">المصدر والتفريغ الآلي أدلة منفصلة عن السماع البشري. لا يوجد اعتماد جماعي أو نشر تلقائي.</p><input id="reviewer" placeholder="اسم المراجع الفعلي"><button onclick="exportReview()">تصدير المراجعات</button><span id="count"></span></header>
<main id="clips"></main><script>
const clips=__ROWS__, saved=JSON.parse(localStorage.getItem('lamma-voice-candidate-review-v1')||'{}');
const E=(tag,text)=>{const x=document.createElement(tag);if(text)x.textContent=text;return x};
function update(){localStorage.setItem('lamma-voice-candidate-review-v1',JSON.stringify(saved));document.getElementById('count').textContent=' | '+Object.values(saved).filter(x=>x.approved).length+' مراجعة مسجلة'}
clips.forEach((c,index)=>{const a=E('article');a.append(E('h2',(index+1)+' · '+c.speaker));a.append(E('p',c.hint));const links=E('div');links.className='links';[['مصدر المتحدث',c.sourceUrl],['الترخيص',c.licenseUrl]].forEach(([label,url])=>{const link=E('a',label);link.href=url;link.target='_blank';link.rel='noopener';links.append(link)});a.append(links,E('p',c.license));if(c.available){const player=E('audio');player.controls=true;player.preload='none';player.src=c.localUrl;a.append(player)}else{const msg=E('p','لم يكتمل تنزيل هذا المرشح بعد؛ لا يمكن اعتماده.');msg.className='pending';a.append(msg)}
const m=c.machineReview;a.append(E('pre',m?'تفريغ آلي: '+m.transcript:'لا يوجد تفريغ آلي لهذا المقتطف بعد.'));a.append(E('p',c.attribution));const checks=[];for(const text of ['استمعت إلى المقتطف الفعلي كاملًا وتطابق المتحدث مع المصدر','الكلام واضح ولا يتداخل معه صوت مقدم أو مترجم','لا يذكر المقتطف اسم صاحب السؤال أو يكشف الإجابة مباشرة','راجعت الترخيص والنسبة والسؤال والخيارات قبل الاعتماد']){const label=E('label'),input=E('input');input.type='checkbox';label.append(input,document.createTextNode(text));checks.push(input);a.append(label)}
const note=E('input');note.placeholder='ملاحظة المراجعة أو سبب الرفض';note.style.width='90%';a.append(note);const button=E('button','تسجيل مراجعة هذا المقتطف');button.onclick=()=>{const reviewer=document.getElementById('reviewer').value.trim();if(!reviewer){alert('أدخل اسم المراجع الفعلي');return}const approved=c.available&&checks.every(x=>x.checked);saved[c.key]={speaker:c.speaker,recordingId:c.recordingId,sourceUrl:c.sourceUrl,sha256:m?.sha256||null,approved,listeningStatus:approved?'listened':'pending',reviewedBy:reviewer,reviewedAt:new Date().toISOString(),note:note.value};update();button.textContent=approved?'سُجل اعتماد هذا المقتطف':'سُجلت الملاحظات دون اعتماد'};a.append(button);document.getElementById('clips').append(a)});update();
function exportReview(){const blob=new Blob([JSON.stringify({schemaVersion:1,method:'individual-human-listening',reviews:saved},null,2)],{type:'application/json'});const link=E('a');link.href=URL.createObjectURL(blob);link.download='lamma-voice-listening-review.json';link.click();setTimeout(()=>URL.revokeObjectURL(link.href),1000)}
</script></html>'''
(OUT/'REVIEW_CANDIDATES.html').write_text(page.replace('__ROWS__',json.dumps(rows,ensure_ascii=False).replace('</','<\\/')),encoding='utf-8')
print('Review page prepared for',len(rows),'source-backed candidates;',sum(r['available'] for r in rows),'actual clips currently available. No approvals assigned.')
