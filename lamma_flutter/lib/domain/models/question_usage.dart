import 'dart:convert';
import 'dart:math';
import 'question.dart';
import 'session_config.dart';

/// Usage identity is independent of wording, clues, difficulty and media.
String questionUsageKey(Question question) =>
    question.usageId ?? 'legacy:${question.id}';
String questionClaimKey(String sessionId, Question question) =>
    jsonEncode([sessionId, questionUsageKey(question)]);

final class QuestionUsage {
  QuestionUsage({
    Set<String> ids = const {},
    Set<String> keys = const {},
    Set<String> claims = const {},
  }) : _ids = {...ids},
       _keys = {...keys},
       _claims = {...claims};
  final Set<String> _ids, _keys, _claims;
  bool contains(Question question) =>
      _keys.contains(questionUsageKey(question)) ||
      question.usageId == null && _ids.contains(question.id);
  bool claimedInSession(String sessionId, Question question) =>
      _claims.contains(questionClaimKey(sessionId, question));
  void claim(String sessionId, Question question) =>
      _claims.add(questionClaimKey(sessionId, question));
  void mark(Question question) {
    _ids.add(question.id);
    _keys.add(questionUsageKey(question));
  }

  void clearQuestions(Iterable<Question> questions) {
    for (final question in questions) {
      _ids.remove(question.id);
      _keys.remove(questionUsageKey(question));
    }
  }

  void replaceWith(QuestionUsage other) {
    if (identical(this, other)) return;
    _ids
      ..clear()
      ..addAll(other._ids);
    _keys
      ..clear()
      ..addAll(other._keys);
    _claims
      ..clear()
      ..addAll(other._claims);
  }
}

class InsufficientQuestions implements Exception {
  InsufficientQuestions(this.shortages);
  final Map<String, int> shortages;
}

/// Prepares disjoint quotas once; ability questions never consume a normal slot.
List<Question> planMatchQuestions({
  required Iterable<Question> questions,
  required Set<String> categoryIds,
  required QuestionUsage usage,
  bool includeAbilities = false,
  Random? random,
}) {
  final keys = <String>{};
  final unique = questions
      .where((q) => !q.isQuarantined && keys.add(questionUsageKey(q)))
      .toList();
  final selected = <Question>[];
  final reserved = <Question>[];
  if (includeAbilities) {
    final spare = <String, int>{
      for (final id in categoryIds)
        id: max(
          0,
          unique.where((q) => q.categoryId == id && !usage.contains(q)).length -
              GameRules.questionsPerCategory,
        ),
    };
    final hard =
        unique
            .where(
              (q) =>
                  categoryIds.contains(q.categoryId) &&
                  !usage.contains(q) &&
                  q.difficulty.points >= 300,
            )
            .toList()
          ..shuffle(random);
    for (final q in hard) {
      if ((spare[q.categoryId] ?? 0) <= 0) continue;
      reserved.add(q);
      spare[q.categoryId] = spare[q.categoryId]! - 1;
      if (reserved.length == GameRules.abilityQuestions) break;
    }
    if (reserved.length < GameRules.abilityQuestions) {
      throw InsufficientQuestions({
        GameRules.abilitiesCategoryId: reserved.length,
      });
    }
  }
  final reservedIds = reserved.map((q) => q.id).toSet();
  final shortages = <String, int>{};
  for (final id in categoryIds) {
    final all = unique
        .where((q) => q.categoryId == id && !reservedIds.contains(q.id))
        .toList();
    final candidates = all.where((q) => !usage.contains(q)).toList()
      ..shuffle(random);
    if (candidates.isEmpty || all.length < GameRules.questionsPerCategory) {
      shortages[id] = candidates.length;
    }
    selected.addAll(candidates.take(GameRules.questionsPerCategory));
    if (candidates.isNotEmpty &&
        candidates.length < GameRules.questionsPerCategory &&
        all.length >= GameRules.questionsPerCategory) {
      final repeats = all.where(usage.contains).toList()..shuffle(random);
      selected.addAll(
        repeats.take(GameRules.questionsPerCategory - candidates.length),
      );
    }
  }
  if (shortages.isNotEmpty) throw InsufficientQuestions(shortages);
  selected.addAll(reserved);
  return List.unmodifiable(selected);
}
