import unittest
from verify_triage_evidence import completed_quote, normalized_excerpt


class EvidenceExcerptTests(unittest.TestCase):
    def test_bracketed_hole_does_not_fill_omitted_leading_context(self):
        question = dict(text="أكمل: «… فليستجيبوا لي وليؤمنوا بي […]»", answer="لعلهم يرشدون")
        self.assertEqual(completed_quote(question), "فليستجيبوا لي وليؤمنوا بي لعلهم يرشدون")

    def test_unbracketed_completion_and_diacritics(self):
        question = dict(text="أكمل: «قُلْ هُوَ اللَّهُ …»", answer="أَحَدٌ")
        self.assertEqual(completed_quote(question), "قل هو الله احد")

    def test_non_completion_question_is_not_certified(self):
        self.assertIsNone(completed_quote(dict(text="سؤال بلا اقتباس", answer="أي جواب")))

    def test_normalizes_cached_quran_initial_alef_and_punctuation(self):
        self.assertEqual(normalized_excerpt("ٱلْحَمْدُ،   لِلَّهِ"), "الحمد لله")


if __name__ == "__main__":
    unittest.main()
