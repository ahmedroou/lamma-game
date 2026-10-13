import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/question_presentation.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/session_view_model.dart';
import 'package:lamma/features/session/structured_question_panel.dart';
import '../domain/question_presentation_test.dart' show matchingData;
import '../fixtures/questions.dart';
import '../app_test.dart' show snapshot;

QuestionPresentation grouping() => QuestionPresentation.fromJson({
  'type': 'grouping',
  'sections': [
    {
      'id': 'all',
      'title': '',
      'items': [
        for (var i = 0; i < 8; i++)
          {'id': 'i$i', 'text': 'عنصر عربي طويل نسبيًا للتقسيم ${i + 1}'},
      ],
    },
  ],
});
Widget harness(
  QuestionPresentation presentation,
  GlobalKey boundary, {
  double scale = 1,
  ValueChanged<Map<String, String>>? onChange,
  ComparisonInteraction interaction = ComparisonInteraction.order,
}) {
  var draft = <String, String>{};
  return MaterialApp(
    theme: AppTheme.dark,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: RepaintBoundary(
              key: boundary,
              child: StatefulBuilder(
                builder: (context, setState) => StructuredQuestionPanel(
                  presentation: presentation,
                  comparisonInteraction: interaction,
                  draft: draft,
                  enabled: true,
                  onChanged: (value) {
                    setState(() => draft = value);
                    onChange?.call(value);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  QuestionPresentation comparison() => QuestionPresentation.fromJson({
    'type': 'comparison',
    'sections': [
      {
        'id': 's',
        'title': '',
        'items': [
          {'id': 'a', 'text': '10'},
          {'id': 'b', 'text': '20'},
          {'id': 'c', 'text': '30'},
        ],
      },
    ],
  });
  testWidgets(
    'Nearest-number mode saves a single candidate rather than an ordering',
    (tester) async {
      Map<String, String>? draft;
      await tester.pumpWidget(
        harness(
          comparison(),
          GlobalKey(),
          interaction: ComparisonInteraction.nearest,
          onChange: (value) => draft = value,
        ),
      );
      await tester.tap(find.text('20'));
      await tester.pump();
      expect(draft, {'selected': 'b'});
      await tester.tap(find.text('30'));
      await tester.pump();
      expect(draft, {'selected': 'c'});
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('First/last mode prevents selecting the same endpoint twice', (
    tester,
  ) async {
    Map<String, String>? draft;
    await tester.pumpWidget(
      harness(
        comparison(),
        GlobalKey(),
        interaction: ComparisonInteraction.endpoints,
        onChange: (value) => draft = value,
      ),
    );
    await tester.tap(find.text('الأول').first);
    await tester.pump();
    await tester.tap(find.text('الأخير').first);
    await tester.pump();
    expect(draft, {'last': 'a'});
    await tester.tap(find.text('الأول').at(1));
    await tester.pump();
    expect(draft, {'last': 'a', 'first': 'b'});
    expect(tester.takeException(), isNull);
  });
  setUpAll(() async {
    await (FontLoader('Tajawal')
          ..addFont(rootBundle.load('assets/fonts/Tajawal-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Tajawal-Bold.ttf')))
        .load();
  });
  for (final size in [
    const Size(390, 844),
    const Size(844, 390),
    const Size(320, 568),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Group/matching premises fit $size at $scale text scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var boundary = GlobalKey();
        await tester.pumpWidget(harness(grouping(), boundary, scale: scale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (size == const Size(390, 844) && scale == 1) {
          await snapshot(tester, boundary, 'new-grouping-portrait');
        }
        boundary = GlobalKey();
        await tester.pumpWidget(
          harness(
            QuestionPresentation.fromJson(matchingData()),
            boundary,
            scale: scale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Missing premise can be entered and linked; reset clears both', (
    tester,
  ) async {
    var draft = <String, String>{};
    await tester.pumpWidget(
      harness(
        QuestionPresentation.fromJson(matchingData()),
        GlobalKey(),
        onChange: (value) => draft = value,
      ),
    );
    await tester.enterText(find.byType(TextField), 'استنتاج اللاعب');
    await tester.pump();
    expect(draft['missing:r2'], 'استنتاج اللاعب');
    await tester.ensureVisible(find.byKey(const ValueKey('link-l1')));
    await tester.tap(find.byKey(const ValueKey('link-l1')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('link-r2')));
    await tester.tap(find.byKey(const ValueKey('link-r2')));
    await tester.pump();
    expect(draft['pair:l1'], 'r2');
    await tester.ensureVisible(find.text('مسح ترتيبك'));
    await tester.tap(find.text('مسح ترتيبك'));
    await tester.pump();
    expect(draft, isEmpty);
    expect(
      (tester.widget(find.byType(TextField)) as TextField).controller!.text,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });
  test(
    'Draft is persisted per answering team, validated, and frozen during pause',
    () {
      final presentation = QuestionPresentation.fromJson(matchingData());
      final q = Question(
        id: 'myths-structure',
        categoryId: 'myths',
        text: 'سؤال متعددالأطراف',
        answer: 'الحل الكامل',
        hint: 'قرينة',
        difficulty: QuestionDifficulty.medium,
        presentation: presentation,
      );
      final pool = [q, ...seedQuestions.skip(1).take(5)];
      final model = SessionViewModel(
        config: SessionConfig(
          teams: [
            TeamState(id: 'a', name: 'أ'),
            TeamState(id: 'b', name: 'ب'),
          ],
          categoryIds: pool.map((q) => q.categoryId),
        ),
        questions: LocalQuestionRepository(questions: pool),
      );
      addTearDown(model.dispose);
      model.selectCategory('myths');
      for (var i = 0; i < 3; i++) {
        model.revealCard(i);
      }
      expect(
        model.updateQuestionDraft({'pair:l1': 'r2', 'missing:r2': 'اجتهاد'}),
        true,
      );
      expect(
        model.updateQuestionDraft({'pair:l1': 'r1', 'pair:l2': 'r1'}),
        false,
      );
      final decoded = SessionState.fromJson(
        jsonDecode(jsonEncode(model.state.toJson())) as Map<String, dynamic>,
      );
      expect(decoded.questionDraft, {'pair:l1': 'r2', 'missing:r2': 'اجتهاد'});
      model.pause();
      expect(model.updateQuestionDraft({}), false);
      model.resume();
      model.startOpponentOpportunity();
      expect(model.state.questionDraft, isEmpty);
      expect(model.updateQuestionDraft({'pair:l2': 'r1'}), true);
      final teamDrafts = model.state.roundData['questionDrafts'] as Map;
      expect((teamDrafts['a'] as Map)['missing:r2'], 'اجتهاد');
    },
  );
}
