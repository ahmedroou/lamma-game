import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../core/game_catalog.dart';
import '../../domain/models/question.dart';
import '../../domain/models/question_bank_config.dart';

abstract interface class QuestionRepository {
  List<Question> forCategories(Set<String> categoryIds);
}

final class LocalQuestionRepository implements QuestionRepository {
  LocalQuestionRepository({required Iterable<Question> questions})
    : _questions = List.unmodifiable(questions) {
    if (_questions.map((question) => question.id).toSet().length !=
        _questions.length) {
      throw ArgumentError('Question IDs must be unique.');
    }
  }
  final List<Question> _questions;
  @override
  List<Question> forCategories(Set<String> categoryIds) => List.unmodifiable(
    _questions.where((question) => categoryIds.contains(question.categoryId)),
  );

  static Future<LocalQuestionRepository> load({AssetBundle? bundle}) async {
    final assets = bundle ?? rootBundle;
    final documents = <String, String>{};
    for (final category in gameCategories) {
      documents[category.id] = await assets.loadString(
        'assets/questions/${category.id}.json',
      );
    }
    final all = await compute(parseQuestionBank, documents);
    // Keep the raw bank intact for editorial repair and stable use-history IDs.
    // Only new matches use this filtered catalog. Saved matches retain snapshots.
    return LocalQuestionRepository(
      questions: all.where((question) => !question.isQuarantined),
    );
  }
}

List<Question> parseQuestionBank(Map<String, String> documents) {
  final questions = <Question>[];
  final ids = <String>{};
  final texts = <String>{};
  for (final entry in documents.entries) {
    final document = jsonDecode(entry.value) as Map<String, dynamic>;
    if (document['schemaVersion'] != 1 ||
        document['categoryId'] != entry.key ||
        document['targetCount'] != QuestionBankConfig.questionsPerCategory ||
        document['targetPerDifficulty'] !=
            QuestionBankConfig.questionsPerDifficulty) {
      throw FormatException('Invalid question bank header: ${entry.key}');
    }
    for (final raw in document['questions'] as List<dynamic>) {
      final question = Question.fromJson(raw as Map<String, dynamic>);
      validateQuestionOptions(question);
      if (question.qualityStatus == QuestionQualityStatus.quarantined &&
          (question.qualityReasons.isEmpty ||
              question.qualityReasons.any((reason) => reason.trim().isEmpty))) {
        throw FormatException('Quarantine requires a reason: ${question.id}');
      }
      if (question.qualityStatus == QuestionQualityStatus.reviewed &&
          question.hasKnownPlaceholderContent) {
        throw FormatException(
          'A placeholder cannot be reviewed: ${question.id}',
        );
      }
      if (question.categoryId != entry.key ||
          question.hint.trim().isEmpty ||
          question.hint.trim() == question.answer.trim() ||
          question.explanation.trim().isEmpty ||
          !ids.add(question.id) ||
          question.isIdentity &&
              (question.clues.length != 3 ||
                  question.clues.any((clue) => clue.trim().isEmpty) ||
                  question.clues.toSet().length != 3) ||
          !question.isIdentity && question.clues.isNotEmpty) {
        throw FormatException('Invalid question or hint: ${question.id}');
      }
      final body =
          (question.isIdentity ? question.clues.join(' ') : question.text)
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
      // A map's figure carries the elevations, edges or regions being solved.
      // Identical instructions with different figures are separate problems.
      // The offline bank audit additionally detects identical renamed images.
      final signature = question.categoryId == 'maps'
          ? jsonEncode([body, question.imageAsset])
          : body;
      if (!texts.add(signature)) {
        throw FormatException('Duplicate question: ${question.id}');
      }
      final image = question.imageAsset;
      if (image != null &&
          (!image.startsWith('assets/question_media/') ||
              image.contains('..') ||
              image.contains('\\') ||
              question.imageDescription == null ||
              question.imageDescription!.trim().isEmpty)) {
        throw FormatException(
          'Question media must be a described local asset: ${question.id}',
        );
      }
      questions.add(question);
    }
  }
  return List.unmodifiable(questions);
}

String normalizeAnswer(String text) => text
    .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
    .replaceAll(RegExp(r'[أإآ]'), 'ا')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim()
    .toLowerCase();

void validateQuestionOptions(Question question) {
  final options = question.options;
  final accepted = {
    normalizeAnswer(question.answer),
    ...question.acceptedAnswers.map(normalizeAnswer),
  };
  final matching = options
      .where((option) => accepted.contains(normalizeAnswer(option.text)))
      .toList();
  if (options.length != 6 ||
      options.map((option) => option.id).toSet().length != 6 ||
      options.map((option) => normalizeAnswer(option.text)).toSet().length !=
          6 ||
      options.any(
        (option) =>
            !RegExp(r'^[A-F]$').hasMatch(option.id) ||
            normalizeAnswer(option.text).isEmpty,
      ) ||
      matching.length != 1 ||
      matching.single.id != question.correctOptionId) {
    throw FormatException(
      'Six distinct options with exactly one reference answer are required: ${question.id}',
    );
  }
}
