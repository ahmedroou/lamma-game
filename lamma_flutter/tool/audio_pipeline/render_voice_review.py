"""Render the recorded editorial decisions for human listening; no checks or approvals."""
import html
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
bank = json.loads((root / 'assets/questions/character_voice.json').read_text(encoding='utf-8-sig'))
output = root / 'design_sources/character_voice_repair/LISTENING_REVIEW.html'
esc = lambda value: html.escape(str(value), quote=True)
parts = ['''<!doctype html><html lang="ar" dir="rtl"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>لَمّة · مراجعة تسجيلات صوت الشخصية</title>
<style>
:root{color-scheme:dark;font-family:Tahoma,Arial,sans-serif;background:#101215;color:#f4f4f0}
body{max-width:940px;margin:auto;padding:28px 18px;line-height:1.9}
h1{font-size:30px;margin-bottom:8px}h2{font-size:22px;margin:0;color:#d5f85a}
.intro,article{background:#1c1f24;border:1px solid #30343b;border-radius:20px;padding:22px;margin:18px 0}
.tag{color:#b5a0ff;font-size:13px}.pending{color:#ffb68f}a{color:#8fd6f5;overflow-wrap:anywhere}
p{margin:8px 0}audio{display:block;width:100%;margin:18px 0}.quote{direction:ltr;text-align:left;background:#101215;padding:14px;border-radius:12px}
details{margin-top:16px}summary{cursor:pointer;color:#b5a0ff}li{margin:8px 0}code{direction:ltr;unicode-bidi:embed;font-size:12px}
textarea{box-sizing:border-box;width:100%;min-height:80px;background:#101215;color:#fff;border:1px solid #30343b;border-radius:10px;padding:12px;font:inherit}
.muted{color:#9ca3af;font-size:13px}footer{margin:30px 0;color:#9ca3af}
</style><h1>صوت الشخصية · دفتر الاستماع</h1>
<div class="intro"><b>هدف القسم 100 سؤال. الحزمة لم تُعتمد للعب بعد.</b>
<p>تحتوي هذه الصفحة على المقتطفات التي جُهّزت من مصادر محددة، وعلى أسباب عزل بقية السجلات. تشغيل مقطع هنا للمراجعة لا يفعّله داخل اللعبة ولا يغيّر حالة أي سؤال.</p>
<p class="pending">لم تتم مراجعة سمعية نهائية في جلسة الإصلاح؛ بيئة الأجنت لا تدعم إدخال الصوت. توثيق المصدر والتفريغ لا يعادل الاستماع للمقتطف النهائي.</p>
<p>استمع إلى الأصل والمقتطف، وتأكد من المتحدث وغياب اسمه أو صوت مترجم أو مقدّم، ومن وضوح القص والنص، ثم راجع الخيارات والتلميح والصعوبة.</p>
<p class="muted">الملاحظات أدناه محلية مؤقتة في الصفحة؛ لا تُرسل ولا تُحفظ تلقائيًا. لا توجد أزرار اعتماد جماعي.</p></div>''']
pending = []
credits = ['# Sound asset credits — 15 October 2026\n',
           'These are prepared archival excerpts, not listening-approved gameplay questions. '
           'All clips remain blocked from gameplay. No newly generated, cloned or substitute voice is used. '
           'MP3 conversion, cropping, mono conversion and metadata removal are disclosed per source. '
           'CC BY-SA derivatives retain the indicated source media license; no endorsement is implied.\n']
for question in bank['questions']:
    audio = question.get('audio')
    if not audio:
        pending.append(question)
        continue
    label = 'المصدر والتوقيت موثقان؛ بانتظار الاستماع' if audio.get('reviewStatus') == 'sourceVerified' else 'الأصل محدد؛ التفريغ وحدود المقتطف يحتاجان مراجعة'
    parts.append(f'<article><div class="tag"><code>{esc(question["id"])}</code> · {esc(question["difficulty"])}</div><h2>{esc(question["answer"])}</h2><p class="pending">{label}</p>')
    parts.append(f'<audio controls preload="none" src="../../{esc(audio["assetPath"])}"></audio>')
    parts.append(f'<p class="muted">المدة المسجلة: {audio["durationMs"] / 1000:.3f} ثانية · القص من الأصل: {audio["sourceStartMs"] / 1000:.3f}–{audio["sourceEndMs"] / 1000:.3f} ثانية</p>')
    parts.append(f'<p class="quote">{esc(audio.get("transcript") or "No time-aligned transcript established yet.")}</p>')
    parts.append(f'<p>{esc(audio["attribution"])}</p><p>{esc(audio["license"])}</p><p><a href="{esc(audio["sourceUrl"])}" target="_blank" rel="noreferrer">المصدر الأصلي</a> · <a href="{esc(audio["licenseUrl"])}" target="_blank" rel="noreferrer">الترخيص</a></p>')
    parts.append(f'<details><summary>مراجعة السؤال والخيارات</summary><p>{esc(question["text"])}</p><p>التلميح: {esc(question["hint"])}</p><ul>')
    for option in question['options']:
        parts.append(f'<li>{esc(option["id"])} · {esc(option["text"])}</li>')
    parts.append(f'</ul><p>الإجابة المرجعية: {esc(question["answer"])}</p><p>{esc(question["explanation"])}</p></details><p>ملاحظات الاستماع:</p><textarea aria-label="ملاحظات الاستماع" placeholder="هوية المتحدث، وضوح المقطع، تسريب الاسم، حدود القص…"></textarea></article>')
    credits.extend([f'\n## {Path(audio["assetPath"]).name} — {question["answer"]}\n',
                    f'- Original recording: {audio["sourceUrl"]}\n',
                    f'- License: {audio["license"]}\n- License evidence: {audio["licenseUrl"]}\n',
                    f'- Attribution and changes: {audio["attribution"]}\n',
                    f'- Original cut: {audio["sourceStartMs"]}–{audio["sourceEndMs"]} ms; output duration {audio["durationMs"]} ms.\n',
                    f'- Review: {audio.get("reviewStatus", "unverified")}; final listening pending.\n'])
parts.append('<details class="intro"><summary>السجلات المعزولة التي لم يُثبت مقطعها</summary>')
for question in pending:
    reason = ' '.join(question.get('qualityReasons', []))
    parts.append(f'<p><b>{esc(question["answer"])}</b> · <code>{esc(question["id"])}</code><br>{esc(reason)}</p>')
parts.append('</details><footer>لا يغيّر هذا الدفتر ملفات اللعبة أو سجل الاستخدام. راجع CHARACTER_VOICE_DOCUMENTATION.md للحالة الفعلية.</footer><script>document.querySelectorAll("audio").forEach(a=>a.addEventListener("play",()=>document.querySelectorAll("audio").forEach(b=>{if(b!==a)b.pause()})));</script></html>')
output.write_text('\n'.join(parts), encoding='utf-8')
(root / 'assets/question_audio/LICENSES.md').write_text(''.join(credits), encoding='utf-8')
