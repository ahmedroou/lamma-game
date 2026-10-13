import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import assign_question_usage_ids as usage

class UsageIdTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='lamma-number-tests-')
        self.root = Path(self.temp.name)
        self.path = self.root / 'assets/questions/demo.json'
        self.path.parent.mkdir(parents=True)
        self.questions = [{'id': f'q-{i}', 'text': 'نص', 'answer': 'جواب', 'qualityStatus': 'quarantined' if i == 1 else 'unreviewed', 'imageAsset': 'assets/question_media/demo.webp'} for i in range(3)]
        self.write(self.questions)
    def tearDown(self):
        self.temp.cleanup()
    def write(self, questions):
        self.path.write_text(json.dumps({'questions': questions}, ensure_ascii=False), encoding='utf-8')
    def read(self):
        return json.loads(self.path.read_text(encoding='utf-8'))['questions']
    def test_assigns_unique_decimal_strings_preserving_content(self):
        result = usage.assign(self.root)
        assigned = self.read()
        self.assertEqual(result['assigned'], 3)
        self.assertEqual(len({q['usageId'] for q in assigned}), 3)
        for original, q in zip(self.questions, assigned):
            self.assertTrue(usage.valid_number(q['usageId']))
            self.assertEqual({k: v for k, v in q.items() if k != 'usageId'}, original)
    def test_rerun_and_check_never_rewrite_existing_numbers(self):
        usage.assign(self.root)
        before = self.path.read_bytes()
        self.assertEqual(usage.assign(self.root)['assigned'], 0)
        self.assertEqual(usage.assign(self.root, check=True)['assigned'], 0)
        self.assertEqual(self.path.read_bytes(), before)
    def test_missing_field_recovers_registry_number_after_edit(self):
        usage.assign(self.root)
        qs = self.read(); old = qs[0].pop('usageId'); qs[0]['text'] = 'تحرير جديد'
        self.write(qs)
        usage.assign(self.root)
        self.assertEqual(self.read()[0]['usageId'], old)
        self.assertEqual(self.read()[0]['text'], 'تحرير جديد')
    def test_changed_existing_number_is_rejected(self):
        usage.assign(self.root)
        qs = self.read(); qs[0]['usageId'] = '1'; self.write(qs)
        with self.assertRaises(ValueError): usage.assign(self.root)
    def test_duplicates_and_json_numbers_are_rejected(self):
        for value in [123, '0', '001', str(2 ** 128)]:
            qs = [dict(q) for q in self.questions]; qs[0]['usageId'] = value; self.write(qs)
            with self.assertRaises(ValueError): usage.assign(self.root)
        qs = [dict(q, usageId='11') for q in self.questions]; self.write(qs)
        with self.assertRaises(ValueError): usage.assign(self.root)
    def test_collision_retries_and_only_new_questions_get_new_numbers(self):
        bits = iter([101, 101, 102, 103])
        usage.assign(self.root, random_bits=lambda _: next(bits))
        self.assertEqual([q['usageId'] for q in self.read()], ['101', '102', '103'])
        qs = self.read(); qs.append({'id': 'q-new', 'text': 'new'}); self.write(qs)
        usage.assign(self.root, random_bits=lambda _: 104)
        self.assertEqual([q['usageId'] for q in self.read()], ['101', '102', '103', '104'])
    def test_concurrent_edit_is_retained_and_reserved_numbers_are_recoverable(self):
        real_write = usage.atomic_write
        def interrupt(path, data):
            real_write(path, data)
            if path.name == 'question_usage_ids.json':
                qs = self.read(); qs[0]['answer'] = 'تعديل متزامن'; self.write(qs)
        with patch.object(usage, 'atomic_write', interrupt):
            with self.assertRaises(RuntimeError): usage.assign(self.root)
        registry = json.loads((self.root / 'tool/question_usage_ids.json').read_text())['ids']
        usage.assign(self.root)
        self.assertEqual(self.read()[0]['answer'], 'تعديل متزامن')
        self.assertEqual(self.read()[0]['usageId'], registry['q-0'])
    def test_check_is_read_only_and_requires_all_numbers(self):
        before = self.path.read_bytes()
        with self.assertRaises(ValueError): usage.assign(self.root, check=True)
        self.assertEqual(self.path.read_bytes(), before)
        self.assertFalse((self.root / 'tool/question_usage_ids.json').exists())

if __name__ == '__main__': unittest.main()
