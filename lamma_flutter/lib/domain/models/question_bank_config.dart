import 'question.dart';

/// Authoring targets, independent of match sizes and difficulty point values.
abstract final class QuestionBankConfig {
  static const questionsPerCategory = 900;
  static const questionsPerDifficulty = 225;
  static const originalQuestionsPerDifficulty = 200;
  static const newCategoryIds = {
    'symbols_signals',
    'abbreviations',
    'first_last',
    'split_groups',
    'pair_up',
    'currency_stories',
    'one_wrong',
    'complete_sequence',
    'relationship',
    'numbers',
    'reverse_question',
    'general_aptitude',
    'animal_world',
    'guess_food',
    'character_voice',
  };
  static const categories700 = {
    'reverse_question',
  };
  static const categories500 = {
    'animal_world',
  };
  static const categories400 = {
    'abbreviations',
    'complete_sequence',
    'currency_stories',
    'first_last',
    'general_aptitude',
    'numbers',
    'one_wrong',
    'pair_up',
    'relationship',
    'split_groups',
    'symbols_signals',
  };
  static const categories100 = {
    'character_voice',
  };
  static const categories80 = {
    'guess_food',
  };
  static int countFor(String categoryId) {
    if (categories700.contains(categoryId)) return 700;
    if (categories500.contains(categoryId)) return 500;
    if (categories400.contains(categoryId)) return 400;
    if (categories100.contains(categoryId)) return 100;
    if (categories80.contains(categoryId)) return 80;
    return newCategoryIds.contains(categoryId) ? 300 : questionsPerCategory;
  }
  static int perDifficultyFor(String categoryId, [QuestionDifficulty? difficulty]) {
    if (categoryId == 'reverse_question') {
      if (difficulty != null) {
        return switch (difficulty) {
          QuestionDifficulty.easy => 195,
          QuestionDifficulty.medium => 215,
          QuestionDifficulty.hard => 170,
          QuestionDifficulty.legendary => 120,
        };
      }
      return 175;
    }
    return countFor(categoryId) ~/ 4;
  }
  static int totalFor(Iterable<String> categoryIds) =>
      categoryIds.fold(0, (total, id) => total + countFor(id));
}
