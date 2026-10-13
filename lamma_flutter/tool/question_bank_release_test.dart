import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/game_catalog.dart';
import 'package:lamma/domain/models/question_bank_config.dart';
import '../test/data/question_bank_test.dart' show verifyQuestionBank;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Release bank has exactly 12600 reviewed questions, 225 per difficulty',
    () async {
      final questions = await verifyQuestionBank(complete: true);
      expect(
        questions.length,
        gameCategories.length * QuestionBankConfig.questionsPerCategory,
      );
    },
  );
}
