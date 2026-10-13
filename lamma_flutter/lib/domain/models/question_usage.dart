import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'question.dart';
import 'session_config.dart';

/// Stable content identity: moving a question or changing its ID cannot recycle it.
final _fingerprintCache = Expando<String>();
String questionFingerprint(Question question) {
  final cached = _fingerprintCache[question];
  if (cached != null) return cached;
  String normalize(String value) => value
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();
  final content = question.isIdentity
      ? question.clues.map(normalize).join('|')
      : normalize(question.text);
  final result = sha256.convert(utf8.encode(content)).toString();
  _fingerprintCache[question] = result;
  return result;
}

final class QuestionUsage {
  QuestionUsage({
    Set<String> ids = const {},
    Set<String> fingerprints = const {},
  }) : _ids = {...ids},
       _fingerprints = {...fingerprints};
  final Set<String> _ids, _fingerprints;
  bool contains(Question question) =>
      _ids.contains(question.id) ||
      _fingerprints.contains(questionFingerprint(question));
  void mark(Question question) {
    _ids.add(question.id);
    _fingerprints.add(questionFingerprint(question));
  }

  void clearQuestions(Iterable<Question> questions) {
    for (final question in questions) {
      _ids.remove(question.id);
      _fingerprints.remove(questionFingerprint(question));
    }
  }

  void replaceWith(QuestionUsage other) {
    if (identical(this, other)) return;
    _ids
      ..clear()
      ..addAll(other._ids);
    _fingerprints
      ..clear()
      ..addAll(other._fingerprints);
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
  final unused = questions.where((q) => !usage.contains(q)).toList();
  final fingerprints = <String>{};
  final unique = unused
      .where((q) => fingerprints.add(questionFingerprint(q)))
      .toList();
  final selected = <Question>[];
  final shortages = <String, int>{};
  for (final id in categoryIds) {
    final candidates = unique.where((q) => q.categoryId == id).toList()
      ..shuffle(random);
    if (candidates.length < GameRules.questionsPerCategory) {
      shortages[id] = candidates.length;
    }
    selected.addAll(candidates.take(GameRules.questionsPerCategory));
  }
  if (shortages.isNotEmpty) throw InsufficientQuestions(shortages);
  if (includeAbilities) {
    final selectedIds = selected.map((q) => q.id).toSet();
    final extra =
        unique
            .where(
              (q) =>
                  categoryIds.contains(q.categoryId) &&
                  !selectedIds.contains(q.id),
            )
            .toList()
          ..shuffle(random);
    if (extra.length < GameRules.questionsPerCategory) {
      throw InsufficientQuestions({
        GameRules.abilitiesCategoryId: extra.length,
      });
    }
    selected.addAll(extra.take(GameRules.questionsPerCategory));
  }
  return List.unmodifiable(selected);
}
