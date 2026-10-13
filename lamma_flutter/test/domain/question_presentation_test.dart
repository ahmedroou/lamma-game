import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/question_presentation.dart';

Map<String, dynamic> matchingData() => {
  'type': 'matching',
  'sections': [
    {
      'id': 'left',
      'title': 'طرف أول',
      'items': [
        {'id': 'l1', 'text': 'الأول'},
        {'id': 'l2', 'text': 'الثاني'},
      ],
    },
    {
      'id': 'right',
      'title': 'طرف مقابل',
      'items': [
        {'id': 'r1', 'text': 'المقابل'},
        {'id': 'r2', 'text': '؟', 'missing': true},
      ],
    },
  ],
};
void main() {
  test(
    'Unit symbols retain case when checking duplicated visible premises',
    () {
      QuestionPresentation symbol(String text) =>
          QuestionPresentation.fromJson({
            'type': 'symbols',
            'sections': [
              {
                'id': 's',
                'title': '',
                'items': [
                  {'id': 'a', 'text': text},
                ],
              },
            ],
          });
      expect(
        questionPresentationSignature(symbol('T')),
        isNot(questionPresentationSignature(symbol('t'))),
      );
    },
  );
  test('Visible and missing elements round-trip without exposed solutions', () {
    final presentation = QuestionPresentation.fromJson(matchingData());
    expect(presentation.elements.last.missing, true);
    expect(presentation.elements.last.text, '؟');
    expect(
      QuestionPresentation.fromJson(
        jsonDecode(jsonEncode(presentation.toJson())) as Map<String, dynamic>,
      ).toJson(),
      presentation.toJson(),
    );
  });
  test(
    'Rejects a solution field, disclosed missing text and duplicated element IDs',
    () {
      for (final mutate in <void Function(Map<String, dynamic>)>[
        (data) => data['solution'] = 'حل مخفي في موضع خاطئ',
        (data) =>
            ((data['sections'] as List).last['items'] as List).last['text'] =
                'الجواب الحقيقي',
        (data) =>
            ((data['sections'] as List).last['items'] as List).first['id'] =
                'l1',
        (data) =>
            ((data['sections'] as List).last['items'] as List).removeLast(),
      ]) {
        final data = matchingData();
        mutate(data);
        expect(
          () => QuestionPresentation.fromJson(data),
          throwsFormatException,
        );
      }
    },
  );
  test(
    'Renaming IDs and reordering matching candidates does not create a new question',
    () {
      final first = QuestionPresentation.fromJson(matchingData());
      final secondData = matchingData();
      for (final section in secondData['sections'] as List) {
        for (final item in section['items'] as List) {
          item['id'] = '${item['id']}-renamed';
        }
        section['items'] = (section['items'] as List).reversed.toList();
      }
      final second = QuestionPresentation.fromJson(secondData);
      expect(
        questionPresentationSignature(first),
        questionPresentationSignature(second),
      );
    },
  );
  test(
    'Grouping requires six/eight items and sequence retains meaningful order',
    () {
      final grouping = {
        'type': 'grouping',
        'sections': [
          {
            'id': 'all',
            'title': '',
            'items': [
              for (var i = 0; i < 6; i++) {'id': 'i$i', 'text': 'عنصر $i'},
            ],
          },
        ],
      };
      expect(QuestionPresentation.fromJson(grouping).elements, hasLength(6));
      (grouping['sections'] as List).first['items'].removeLast();
      expect(
        () => QuestionPresentation.fromJson(grouping),
        throwsFormatException,
      );
      final sequence = {
        'type': 'sequence',
        'sections': [
          {
            'id': 's',
            'title': '',
            'items': [
              {'id': 'a', 'text': 'أ'},
              {'id': 'b', 'text': 'ب'},
              {'id': 'missing', 'text': '؟', 'missing': true},
            ],
          },
        ],
      };
      final first = QuestionPresentation.fromJson(sequence);
      (sequence['sections'] as List).first['items'] =
          ((sequence['sections'] as List).first['items'] as List).reversed
              .toList();
      expect(
        questionPresentationSignature(first),
        isNot(
          questionPresentationSignature(
            QuestionPresentation.fromJson(sequence),
          ),
        ),
      );
    },
  );
}
