"""Offline editorial triage. Findings are NOT factual/source verification.

Run from the Flutter root: python tool/audit_question_quality.py --strict
Writes QUESTION_QUALITY_AUDIT.json and .md. The explicit --quarantine mode
tags confirmed placeholders in place; it never deletes or renumbers content.
Only explicit, known non-content placeholder answers are quarantined.

This legacy authoring audit distinguishes map figures mathematically. The
current product rule disallows repeating the same authored body within a
category even with different images; use triage_question_bank.py for that
policy and for fingerprint-bound corrupt-answer findings. Neither editorial
signature is the runtime device-use identity, which uses persisted usageId.
"""

import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PLACEHOLDER_ANSWERS = re.compile(
    r"^(?:المبدأ الفيزيائي/الحيوي السببي المعتمد|الآلية الدقيقة المفسرة للعملية التخصصية|"
    r"المبدأ الكمي/الترموديناميكي المعقد الحاكم للمنظومة|الجهة/المعلم التاريخي الموثق|"
    r"الموقع/المقياس الكارتوغرافي الدقيق|المفهوم الكارتوغرافي الجيوديسي المتقدم|"
    r"علم تاريخي معتمد رسمياً برمز موثق|الحل المنطقي الدقيق للغز|"
    r"الاستنتاج الاستدلالي الصارم للغز|الحل الخارق المحكم للمفارقة المنطقية|"
    r"المعنى المعجمي الدقيق المعتمد|العلم/العالم التاريخي الموثق|"
    r"الهوية التاريخية/العلمية المستقلة|الهوية التخصصية المتقدمة)\s+\d+$"
)
MARKS = re.compile(r"[\u064b-\u065f\u0670\u06d6-\u06ed\u0640]")


def is_placeholder(q):
    return bool(PLACEHOLDER_ANSWERS.fullmatch(q.get("answer", "").strip()) or
                re.fullmatch(r"ما السمة الرمزية الأبرز في راية تاريخية تخصصية \d+؟", q.get("text", "").strip()))


def normalize(text):
    text = MARKS.sub("", text).translate(str.maketrans("أإآى", "اااي"))
    return re.sub(r"[^\w]+", " ", text, flags=re.UNICODE).strip().lower()


def normalize_option(text):
    # Punctuation carries meaning in coordinates, signed values and fractions.
    # Do not conflate (-1, 1) with (-1, -1) or 1.5 with 15.
    text = MARKS.sub("", text).translate(str.maketrans("أإآ", "ااا"))
    return re.sub(r"\s+", " ", text).strip().lower()


def normalize_question(text):
    # Quantitative/diagram descriptions must retain signs and separators.
    return normalize_option(text) if re.search(r'[0-9٠-٩]', text) else normalize(text)


def question_signature(question):
    body = ' '.join(question.get('clues', [])) if question['categoryId']=='who_am_i' else question['text']
    signature = normalize_question(body)
    presentation = question.get('presentation')
    if presentation:
        parts = [presentation['type']]
        for section in presentation['sections']:
            items = [('missing:' if item.get('missing') else 'item:') + (item['text'].strip() if presentation['type']=='symbols' else normalize_option(item['text'])) for item in section['items']]
            if presentation['type'] in ('matching','grouping','comparison','statements'):
                items.sort()
            parts.append([normalize_option(section['title']), items])
        signature += '|presentation:' + json.dumps(parts,ensure_ascii=False)
    if question['categoryId']=='symbols_signals' and question.get('imageAsset'):
        signature += '|symbol_image:' + hashlib.sha256((ROOT/question['imageAsset']).read_bytes()).hexdigest()
    # Map figures contain the grid heights/edges required to solve the question.
    # Hash the bytes, not the filename, so renamed identical figures still collide.
    if question['categoryId']=='maps' and question.get('imageAsset'):
        signature += '|figure:' + hashlib.sha256((ROOT/question['imageAsset']).read_bytes()).hexdigest()
    return signature


def audit():
    issues = []
    categories = []
    quarantine = []
    all_ids = set()
    global_questions = defaultdict(list)
    for path in sorted((ROOT / "assets/questions").glob("*.json")):
        raw = path.read_bytes()
        document = json.loads(raw.decode("utf-8-sig"))
        category = document["categoryId"]
        questions = document["questions"]
        before = len(issues)
        hint_groups = defaultdict(list)
        template_groups = defaultdict(list)
        for q in questions:
            qid = q["id"]

            def flag(code, severity, detail):
                issues.append(dict(id=qid, categoryId=category, code=code,
                                   severity=severity, detail=detail))

            if qid in all_ids:
                flag("duplicate_id", "blocker", "Repeated stable question ID")
            all_ids.add(qid)
            if is_placeholder(q):
                flag("confirmed_placeholder", "blocker", "Known numbered non-answer, not an actual fact or solution")
                quarantine.append(dict(id=qid, categoryId=category,
                                       reason="confirmed_placeholder", text=q["text"],
                                       answer=q["answer"], clues=q.get("clues", [])))
            options = q.get("options", [])
            if len(options) != 6 or {o.get("id") for o in options} != set("ABCDEF"):
                flag("option_shape", "blocker", "Requires exactly six options A–F")
            option_text = [normalize_option(o.get("text", "")) for o in options]
            if len(set(option_text)) != len(option_text):
                flag("equivalent_option_text", "blocker", "Options repeat after Arabic letter/diacritic/whitespace normalization; numeric signs are preserved")
            accepted = {normalize_option(a) for a in [q.get("answer", ""), *q.get("acceptedAnswers", [])]}
            matching = [o for o in options if normalize_option(o.get("text", "")) in accepted]
            if len(matching) != 1 or matching[0].get("id") != q.get("correctOptionId"):
                flag("option_answer_match", "blocker", "Correct answer must match only one option")
            answer = normalize(q.get("answer", ""))
            # Short answers, proper-name overlap, and explicit completion prompts need human review.
            if len(answer.split()) >= 3 and answer in normalize(q.get("hint", "")):
                flag("answer_in_hint", "review", "Full multiword answer appears verbatim in hint")
            if category != "who_am_i" and len(answer.split()) >= 3 and answer in normalize(q.get("text", "")):
                flag("answer_in_question", "review", "Full multiword answer appears in question; check context")
            sources = q.get("sources", [])
            if not any(re.search(r"https?://\S+", s) for s in sources):
                original_proof = category in {"riddles", "maps"} and any("أصلي" in s or "حساب" in s for s in sources)
                if not original_proof:
                    flag("no_source_url", "review", "No direct URL; verify book/reference precision manually")
            hint_groups[normalize(q.get("hint", ""))].append(qid)
            if category == "who_am_i":
                body = " ".join(q.get("clues", []))
            else:
                body = q.get("text", "")
            global_questions[question_signature(q)].append(qid)
            template_groups[re.sub(r"\d+", "#", normalize(body))].append(qid)
        for code, groups, threshold in [("repeated_hint", hint_groups, 5),
                                         ("number_variant_template", template_groups, 5)]:
            for body, ids in groups.items():
                if body and len(ids) >= threshold:
                    for qid in ids:
                        issues.append(dict(id=qid, categoryId=category, code=code,
                                           severity="review", detail=f"Shared by {len(ids)} questions; not proof of invalidity"))
        local = issues[before:]
        categories.append(dict(categoryId=category, count=len(questions), status=document.get("status"),
                               difficulties=dict(Counter(q["difficulty"] for q in questions)),
                               sha256=hashlib.sha256(raw).hexdigest(),
                               confirmedPlaceholders=sum(i["code"] == "confirmed_placeholder" for i in local),
                               countsByCode=dict(Counter(i["code"] for i in local))))
    for ids in global_questions.values():
        if len(ids) > 1:
            for qid in ids:
                issues.append(dict(id=qid, categoryId=qid.rsplit("-", 2)[0],
                                   code="duplicate_question_or_clues", severity="review",
                                   detail="Same normalized question/clues: " + ", ".join(ids)))
    return dict(schemaVersion=1, generatedAt=datetime.now(timezone.utc).isoformat(),
                scope="All local question files. Automated triage only; absence of findings does not certify quality.",
                totalQuestions=sum(c["count"] for c in categories),
                confirmedPlaceholderCount=len(quarantine), categories=categories,
                countsByCode=dict(Counter(i["code"] for i in issues)),
                confirmedPlaceholderIds=[q["id"] for q in quarantine],
                quarantine=quarantine, issues=issues)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--strict", action="store_true", help="Exit 1 if any definite blocker remains")
    parser.add_argument("--quarantine", action="store_true", help="Tag known placeholders only, preserving all rows and IDs")
    args = parser.parse_args()
    if args.quarantine:
        for path in sorted((ROOT / "assets/questions").glob("*.json")):
            original = path.read_bytes()
            document = json.loads(original.decode("utf-8-sig"))
            changed = False
            for q in document["questions"]:
                if is_placeholder(q):
                    q["qualityStatus"] = "quarantined"
                    q["qualityReasons"] = ["confirmed_placeholder: نص وجواب وخيارات قالبية مرقمة بلا معلومة قابلة للحل؛ يحتاج إعادة تأليف كاملة."]
                    changed = True
            if changed:
                document["status"] = "draft"
                # Detect writers since our read rather than silently overwriting their work.
                if path.read_bytes() != original:
                    raise RuntimeError(f"Concurrent edit detected: {path}")
                path.write_text(json.dumps(document, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    report = audit()
    (ROOT / "QUESTION_QUALITY_AUDIT.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    lines = ["# تقرير فرز جودة الأسئلة", "", "فحص آلي شامل للملفات، وليس مراجعة مصدرية أو تحريرية لكل سؤال.", "",
             f"العدد: {report['totalQuestions']}؛ الحشو المؤكد المتبقي: **{report['confirmedPlaceholderCount']}**.", "",
             "| القسم | العدد | حشو مؤكد | الحالة |", "|---|---:|---:|---|"]
    for c in report["categories"]:
        lines.append(f"| {c['categoryId']} | {c['count']} | {c['confirmedPlaceholders']} | {c['status']} |")
    lines += ["", "## تفسير النتائج", "", "- confirmed_placeholder: جواب مرقم عام بلا حقيقة أو حل؛ يجب إعادة تأليفه بالكامل.",
              "- تكرار قالب أو تلميح، غياب رابط، وتسريب محتمل: علامات مراجعة بشرية وليست حكماً آلياً ببطلان السؤال.",
              "- الملف JSON المرافق يحوي المعرفات والأسباب وبصمات ملفات المصدر. قائمة quarantine تحمل النص والجواب والتلميحات للمطابقة قبل الاستبعاد؛ لا يكفي المعرف بعد إصلاح المحتوى.",
              "- لا يعد status=complete أو بلوغ العدد المستهدف دليلاً على الدقة. الفحص لا يثبت صحة المصادر أو كفاية الصعوبة أو خطأ المشتتات دلالياً.",
              "- التشغيل العادي لا يغير البنك. خيار --quarantine يوسم الحشو المؤكد فقط؛ المستودع يستبعده من المباريات الجديدة. لا تُحذف هويات أو صفوف.",
              "", "## أمر إعادة الفحص", "", "`python tool/audit_question_quality.py --strict`", "",
              "يعيد رمز1 ما دامت عيوب مؤكدة باقية؛ لا تخفف القواعد لإعلان الاكتمال.", ""]
    (ROOT / "QUESTION_QUALITY_AUDIT.md").write_text("\n".join(lines), encoding="utf-8")
    print(json.dumps({k: report[k] for k in ["totalQuestions", "confirmedPlaceholderCount", "countsByCode"]}, ensure_ascii=False))
    if args.strict and any(i["severity"] == "blocker" for i in report["issues"]):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
