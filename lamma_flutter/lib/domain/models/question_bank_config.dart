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
  };
  static int countFor(String categoryId) =>
      newCategoryIds.contains(categoryId) ? 300 : questionsPerCategory;
  static int perDifficultyFor(String categoryId) => countFor(categoryId) ~/ 4;
  static int totalFor(Iterable<String> categoryIds) =>
      categoryIds.fold(0, (total, id) => total + countFor(id));
}
