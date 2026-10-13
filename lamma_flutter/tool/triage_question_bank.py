"""Reproducible conservative content triage, separate from device use identity.

Run with --quarantine to tag confirmed findings. No deletion, renumbering,
question rewriting, random ID generation or automatic factual approval occurs.
Within a category the same authored body keeps only one playable copy, even
when the images differ, per the product decision of 13 October 2026.
"""

import argparse
from collections import Counter, defaultdict
from copy import deepcopy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

from audit_question_quality import is_placeholder, normalize_option

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "tool/question_triage_findings.json"
CONTENT_FIELDS = (
    "categoryId", "text", "answer", "acceptedAnswers", "hint", "clues",
    "explanation", "sources", "imageAsset", "imageDescription", "options",
    "correctOptionId", "presentation", "subtype",
)


def content_digest(question):
    """Bind manual evidence to substantive fields, never ID/use metadata."""
    body = {key: question[key] for key in CONTENT_FIELDS if key in question}
    payload = json.dumps(body, ensure_ascii=False, sort_keys=True,
                         separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def editorial_signature(question):
    # Preserve numerical signs, decimal points and punctuation that changes
    # a mathematical problem. Only whitespace/Arabic vocalization is folded.
    # A generic "من أنا؟" title is not the identity question; its clues are.
    body = question.get("clues", []) if question["categoryId"] == "who_am_i" else [question["text"]]
    parts = [normalize_option(part) for part in body]
    presentation = question.get('presentation')
    if presentation:
        parts.append('presentation:' + presentation['type'])
        for section in presentation['sections']:
            parts.append('section:' + normalize_option(section['title']))
            # Unit/operator symbols are case-sensitive: T (tesla) != t (tonne).
            items = [('missing:' if item.get('missing') else 'item:') + (item['text'].strip() if presentation['type']=='symbols' else normalize_option(item['text'])) for item in section['items']]
            if presentation['type'] in ('matching','grouping','comparison','statements'):
                items.sort()
            parts.extend(items)
    if question['categoryId']=='symbols_signals' and question.get('imageAsset'):
        image = ROOT/question['imageAsset']
        parts.append('symbol_image:'+(hashlib.sha256(image.read_bytes()).hexdigest() if image.exists() else question['imageAsset']))
    return tuple(parts)


def scan_document(document, manual_findings=()):
    findings, groups = [], defaultdict(list)
    by_id = {question["id"]: question for question in document["questions"]}
    for question in document["questions"]:
        groups[editorial_signature(question)].append(question)
        if is_placeholder(question):
            findings.append(dict(id=question["id"], code="confirmed_placeholder",
                reason="confirmed_placeholder: جواب قالب مرقم بلا حقيقة أو حل محدد؛ يحتاج إعادة تأليف.",
                contentSha256=content_digest(question)))
    for group in groups.values():
        if len(group) < 2:
            continue
        # Keep reviewed/non-quarantined content first, then file order. Do not
        # silently rehabilitate manually quarantined content as the canonical.
        ordered = sorted(enumerate(group), key=lambda pair: (
            pair[1].get("qualityStatus") == "quarantined",
            is_placeholder(pair[1]),
            pair[1].get("qualityStatus") != "reviewed", pair[0]))
        canonical = ordered[0][1]
        for _, question in ordered[1:]:
            findings.append(dict(id=question["id"], code="duplicate_question_in_category",
                canonicalId=canonical["id"],
                reason=f"duplicate_question_in_category: نفس نص المسألة أو تلميحات الهوية داخل القسم؛ النسخة المعتمدة للسحب {canonical['id']}. اختلاف الصورة لا ينشئ سؤالاً مستقلاً وفق قرار المنتج.",
                contentSha256=content_digest(question)))
    stale = []
    for finding in manual_findings:
        question = by_id.get(finding["id"])
        if question is None or content_digest(question) != finding["contentSha256"]:
            stale.append(finding["id"])
        else:
            findings.append(deepcopy(finding))
    return findings, stale


def quarantine_document(document, findings):
    """Tag only findings matching current content; preserve every other field."""
    changed = deepcopy(document)
    by_id = {question["id"]: question for question in changed["questions"]}
    newly_quarantined = []
    for finding in findings:
        question = by_id[finding["id"]]
        if content_digest(question) != finding["contentSha256"]:
            raise RuntimeError(f"Content changed after scan: {finding['id']}")
        if question.get("qualityStatus") != "quarantined":
            newly_quarantined.append(question["id"])
        question["qualityStatus"] = "quarantined"
        reasons = list(question.get("qualityReasons", []))
        if finding["reason"] not in reasons:
            reasons.append(finding["reason"])
        question["qualityReasons"] = reasons
    if findings:
        changed["status"] = "draft"
    return changed, sorted(set(newly_quarantined))


def save_if_unchanged(path, original, document):
    encoded = (json.dumps(document, ensure_ascii=False, indent=2) + "\n").encode("utf-8")
    if path.read_bytes() != original:
        raise RuntimeError(f"Concurrent edit detected; rerun on latest bank: {path}")
    if json.loads(original.decode("utf-8-sig")) == document:
        return False
    # The calling agent coordinates writers as well as checking the original.
    # It never overwrites a detected concurrent change or an unrelated field.
    path.write_bytes(encoded)
    return True


def run(root=ROOT, quarantine=False, manifest=None):
    if manifest is None:
        manifest = json.loads((root / "tool/question_triage_findings.json").read_text(encoding="utf-8"))
    manual = defaultdict(list)
    for finding in manifest.get("findings", []):
        manual[finding["categoryId"]].append(finding)
    categories, all_findings, stale_findings, newly_quarantined = [], [], [], []
    for path in sorted((root / "assets/questions").glob("*.json")):
        original = path.read_bytes()
        document = json.loads(original.decode("utf-8-sig"))
        category = document["categoryId"]
        findings, stale = scan_document(document, manual[category])
        if quarantine:
            document, added = quarantine_document(document, findings)
            save_if_unchanged(path, original, document)
            newly_quarantined.extend(added)
        questions = document["questions"]
        active = [question for question in questions if question.get("qualityStatus") != "quarantined" and not is_placeholder(question)]
        active_signatures = [editorial_signature(question) for question in active]
        missing_media = [question["id"] for question in questions
                         if question.get("imageAsset") and not (root / question["imageAsset"]).is_file()]
        categories.append(dict(categoryId=category, rows=len(questions),
            active=len(active), quarantined=len(questions) - len(active),
            findingsByCode=dict(Counter(finding["code"] for finding in findings)),
            activeDuplicateCount=len(active_signatures) - len(set(active_signatures)),
            missingMediaIds=missing_media,
            fileSha256=hashlib.sha256(path.read_bytes()).hexdigest()))
        for finding in findings:
            finding["categoryId"] = category
        all_findings.extend(findings)
        stale_findings.extend(stale)
    return dict(schemaVersion=1, generatedAt=datetime.now(timezone.utc).isoformat(),
        mode="quarantine" if quarantine else "read_only", totalRows=sum(c["rows"] for c in categories),
        activeQuestions=sum(c["active"] for c in categories),
        quarantinedQuestions=sum(c["quarantined"] for c in categories),
        newlyQuarantinedIds=sorted(set(newly_quarantined)),
        findingsByCode=dict(Counter(finding["code"] for finding in all_findings)),
        categories=categories, findings=all_findings, staleManualFindingIds=stale_findings,
        scope="All bundled rows, within-category duplicate policy and exact known non-content/corrupt-answer evidence. Not blanket factual or semantic certification.")


def write_report(report, root=ROOT):
    (root / "QUESTION_TRIAGE_REPORT.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    lines = ["# فرز التكرارات والأجوبة التالفة — 13 أكتوبر 2026", "",
        "مراجعة قابلة لإعادة التشغيل لجميع صفوف البنك. لا تعني اعتماد جميع الحقائق والمصادر والخيارات تحريرياً.", "",
        f"الخام **{report['totalRows']}**؛ المتاح **{report['activeQuestions']}**؛ المعزول **{report['quarantinedQuestions']}**.", "",
        "| القسم | الخام | المتاح | المعزول |", "|---|---:|---:|---:|"]
    for category in report["categories"]:
        lines.append(f"| {category['categoryId']} | {category['rows']} | {category['active']} | {category['quarantined']} |")
    lines += ["", "## السياسة والأدلة", "",
        "- التكرار التحريري داخل القسم: نفس نص المسألة بعد تطبيع المسافات والتشكيل، حتى مع اختلاف الصورة. لقسم من أنا؟ تُقارن التلميحات الثلاثة، فلا تعزل جميع الأسئلة بسبب عنوانها العام. تبقى الأرقام والإشارات والفواصل العشرية محفوظة.",
        "- عزل تكرارات الخرائط هو تنفيذ لقرار المنتج؛ بعضها مسائل رياضية مختلفة بسبب اختلاف بيانات الرسم، ولا يُوصف ذلك بأنه تزوير رياضي. يبقى سؤال واحد من كل مجموعة للسحب.",
        "- الأجوبة التالفة المثبتة توثق في tool/question_triage_findings.json مع بصمة الحقول ومقتطفات الدليل، وتطبق فقط إذا تطابقت النسخة؛ إصلاح السؤال لا يُعاد عزله اعتماداً على المعرف وحده.",
        "- لا تُحذف صفوف أو صور، ولا تتغير id أو usageId أو النصوص أو الإجابات أو نقاط أو سجل الجهاز. يبقى status=draft، وتبقى الأعداد الخام900/225 لكل قسم لأغراض متابعة التأليف.",
        "- غياب رابط، وتشابه معنى محتمل، وتكرار الجواب وحده أو اختلاف أرقام مسألة حقيقية ليست أدلة كافية للاستبعاد الآلي.",
        "- JSON المرافق يحتوي جميع المعرفات والأسباب والنسخة الأصلية المختارة لكل تكرار وبصمات الملفات؛ الأدلة والتحقق المستقل وحدود المراجعة في QUESTION_TRIAGE_REVIEW.md.", "",
        "## إعادة الإنتاج", "", "`python -X utf8 tool/triage_question_bank.py --quarantine --strict`", "",
        "بدون --quarantine يكون الفحص للقراءة فقط. --strict يفشل إذا بقي عيب مؤكد نشط أو ملف صورة مفقود أو دليل يدوي لم يعد يطابق المحتوى، ولا يفشل لمجرد وجود حجر مقصود. تشغيل ثانٍ لا يعيد كتابة البنك إذا لم يتغير.", ""]
    (root / "QUESTION_TRIAGE_REPORT.md").write_text("\n".join(lines), encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--quarantine", action="store_true")
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    report = run(quarantine=args.quarantine)
    write_report(report)
    print(json.dumps({key: report[key] for key in ("totalRows", "activeQuestions", "quarantinedQuestions", "findingsByCode", "staleManualFindingIds")}, ensure_ascii=False))
    bad_active = {question["id"] for path in (ROOT / "assets/questions").glob("*.json")
                  for question in json.loads(path.read_text(encoding="utf-8-sig"))["questions"]
                  if question.get("qualityStatus") != "quarantined"}
    if args.strict and (any(finding["id"] in bad_active for finding in report["findings"])
                        or report["staleManualFindingIds"]
                        or any(c["missingMediaIds"] or c["activeDuplicateCount"] for c in report["categories"])):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
