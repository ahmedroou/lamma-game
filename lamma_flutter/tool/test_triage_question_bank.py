"""Run: python -X utf8 -m unittest discover -s tool -p test_triage_question_bank.py"""
from copy import deepcopy
import json
from pathlib import Path
import tempfile
import unittest

from triage_question_bank import (
    content_digest, editorial_signature, quarantine_document, run,
    save_if_unchanged, scan_document,
)


def question(identifier="maps-easy-1", text="ما طول المسار 3.5 كم؟", category="maps"):
    return dict(id=identifier, usageId="123456789012345678901234567890",
                categoryId=category, text=text, answer="3.5 كم", clues=[],
                hint="تلميح", explanation="شرح", difficulty="easy",
                acceptedAnswers=[], sources=["مرجع"],
                options=[dict(id="A", text="3.5 كم")], correctOptionId="A")


class ContentTriageTests(unittest.TestCase):
    def test_same_question_different_image_keeps_one_copy(self):
        first, second = question(), question("maps-easy-2")
        first["imageAsset"] = "assets/question_media/first.png"
        second["imageAsset"] = "assets/question_media/second.png"
        second["answer"] = "9.5 كم"
        findings, stale = scan_document(dict(categoryId="maps", questions=[first, second]))
        self.assertEqual(stale, [])
        self.assertEqual(len(findings), 1)
        self.assertEqual(findings[0]["id"], second["id"])
        self.assertEqual(findings[0]["canonicalId"], first["id"])

    def test_arabic_marks_and_whitespace_do_not_disguise_duplicate(self):
        first = question(text="مَا طولُ   المسار؟")
        second = question("maps-easy-2", text="ما طول المسار؟")
        self.assertEqual(editorial_signature(first), editorial_signature(second))

    def test_preserves_signs_decimal_points_and_values(self):
        forms = ["الإحداثي (-1, 1)", "الإحداثي (-1, -1)",
                 "الإحداثي (1, 1)", "الطول 1.5", "الطول 15"]
        self.assertEqual(len({editorial_signature(question(text=text)) for text in forms}), 5)

    def test_identity_title_is_not_question_body(self):
        first = question(category="who_am_i", text="من أنا؟")
        second = question("who_am_i-easy-2", category="who_am_i", text="من أنا؟")
        first["clues"] = ["ولدت في لندن", "درست الفلك", "عملت في مرصد"]
        second["clues"] = ["ولدت في باريس", "درست الكيمياء", "عملت في مختبر"]
        self.assertNotEqual(editorial_signature(first), editorial_signature(second))
        second["clues"] = list(first["clues"])
        self.assertEqual(len(scan_document(dict(questions=[first, second]))[0]), 1)

    def test_reviewed_copy_is_preferred_over_file_order(self):
        first, second = question(), question("maps-easy-2")
        second["qualityStatus"] = "reviewed"
        finding = scan_document(dict(questions=[first, second]))[0][0]
        self.assertEqual(finding["canonicalId"], second["id"])
        self.assertEqual(finding["id"], first["id"])

    def test_never_rehabilitates_existing_quarantine(self):
        first, second = question(), question("maps-easy-2")
        first["qualityStatus"] = "quarantined"
        first["qualityReasons"] = ["manual_fact_error: دليل مستقل"]
        finding = scan_document(dict(questions=[first, second]))[0][0]
        self.assertEqual(finding["canonicalId"], second["id"])

    def test_preserves_all_rows_ids_random_ids_and_other_fields(self):
        first, second = question(), question("maps-easy-2")
        second["usageId"] = "987654321098765432109876543210"
        second["futureField"] = {"nested": [1, 2, 3]}
        document = dict(categoryId="maps", status="draft", questions=[first, second])
        before = deepcopy(document)
        findings, _ = scan_document(document)
        changed, new = quarantine_document(document, findings)
        self.assertEqual(document, before)
        self.assertEqual(len(changed["questions"]), 2)
        self.assertEqual(new, [second["id"]])
        for key, value in second.items():
            self.assertEqual(changed["questions"][1][key], value)

    def test_repeat_run_is_idempotent_and_preserves_manual_reasons(self):
        first, second = question(), question("maps-easy-2")
        second["qualityReasons"] = ["existing_manual_reason"]
        original = dict(status="draft", questions=[first, second])
        changes, _ = quarantine_document(original, scan_document(original)[0])
        again, newly = quarantine_document(changes, scan_document(changes)[0])
        self.assertEqual(again, changes)
        self.assertEqual(newly, [])
        self.assertIn("existing_manual_reason", again["questions"][1]["qualityReasons"])

    def test_manual_finding_is_bound_to_content_not_only_id(self):
        original = question()
        finding = dict(id=original["id"], code="confirmed_answer_topic_mismatch",
                       contentSha256=content_digest(original), reason="دليل محدد")
        self.assertEqual(len(scan_document(dict(questions=[original]), [finding])[0]), 1)
        repaired = deepcopy(original)
        repaired["answer"] = "جواب مصحح"
        findings, stale = scan_document(dict(questions=[repaired]), [finding])
        self.assertEqual(findings, [])
        self.assertEqual(stale, [original["id"]])

    def test_random_ids_and_quality_metadata_do_not_invalidate_evidence(self):
        original, changed = question(), question()
        changed["usageId"] = "765432109876543210987654321098"
        changed["qualityStatus"] = "quarantined"
        changed["qualityReasons"] = ["سبب"]
        self.assertEqual(content_digest(original), content_digest(changed))

    def test_rejects_edits_between_scan_and_tag(self):
        document = dict(questions=[question(), question("maps-easy-2")])
        findings, _ = scan_document(document)
        document["questions"][1]["text"] = "مسألة جديدة"
        with self.assertRaisesRegex(RuntimeError, "Content changed"):
            quarantine_document(document, findings)

    def test_detects_concurrent_file_edit_and_skips_unchanged_writes(self):
        with tempfile.TemporaryDirectory(prefix="lamma-triage-test-") as directory:
            path = Path(directory) / "questions.json"
            document = dict(questions=[question()])
            path.write_text(json.dumps(document), encoding="utf-8")
            original = path.read_bytes()
            self.assertFalse(save_if_unchanged(path, original, document))
            path.write_text(json.dumps(dict(questions=[])), encoding="utf-8")
            with self.assertRaisesRegex(RuntimeError, "Concurrent edit"):
                save_if_unchanged(path, original, document)
            self.assertEqual(json.loads(path.read_text())["questions"], [])

    def test_duplicate_policy_is_local_to_category(self):
        with tempfile.TemporaryDirectory(prefix="lamma-triage-test-") as directory:
            root = Path(directory)
            (root / "assets/questions").mkdir(parents=True)
            for category in ["maps", "riddles"]:
                document = dict(categoryId=category, questions=[question(category + "-1", category=category)])
                (root / f"assets/questions/{category}.json").write_text(json.dumps(document), encoding="utf-8")
            result = run(root, manifest={"findings": []})
            self.assertEqual(result["activeQuestions"], 2)
            self.assertEqual(result["findings"], [])


if __name__ == "__main__":
    unittest.main()
