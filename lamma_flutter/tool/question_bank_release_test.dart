import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/game_catalog.dart';
import 'package:lamma/domain/models/question_bank_config.dart';
import '../test/data/question_bank_test.dart' show verifyQuestionBank;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Release bank has 15600 reviewed questions and the configured category targets',
    () async {
      final questions = await verifyQuestionBank(complete: true);
      expect(
        questions.length,
        QuestionBankConfig.totalFor(gameCategories.map((c) => c.id)),
      );
    },
  );
}
