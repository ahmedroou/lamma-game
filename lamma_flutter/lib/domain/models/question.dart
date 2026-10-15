import 'question_audio.dart';
import 'question_presentation.dart';

enum QuestionDifficulty {
  easy('سهل', 100),
  medium('متوسط', 200),
  hard('صعب', 300),
  legendary('خارق', 400);

  const QuestionDifficulty(this.label, this.points);
  final String label;
  final int points;

  static QuestionDifficulty parse(String value) => switch (value) {
    'easy' => easy,
    'medium' => medium,
    'hard' => hard,
    'legendary' => legendary,
    _ => throw FormatException('Unknown question difficulty: $value'),
  };
}

final class QuestionOption {
  const QuestionOption({required this.id, required this.text});
  final String id, text;
  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    if (json case {
      'id': String id,
      'text': String text,
    } when id.trim().isNotEmpty && text.trim().isNotEmpty) {
      return QuestionOption(id: id, text: text);
    }
    throw const FormatException('An option requires a non-empty id and text.');
  }
  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

enum QuestionQualityStatus { unreviewed, reviewed, quarantined }

final class Question {
  const Question({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.answer,
    required this.difficulty,
    this.usageId,
    this.hint = '',
    this.clues = const [],
    this.acceptedAnswers = const [],
    this.explanation = '',
    this.sources = const [],
    this.imageAsset,
    this.imageDescription,
    this.audio,
    this.options = const [],
    this.correctOptionId,
    this.qualityStatus = QuestionQualityStatus.unreviewed,
    this.qualityReasons = const [],
    this.presentation,
    this.subtype,
  });
  final String id, categoryId, text, answer;

  /// A stable random decimal identifier. Never regenerate it for an edit.
  final String? usageId;
  final String hint, explanation;
  final List<String> clues, acceptedAnswers, sources;
  final String? imageAsset, imageDescription;
  final QuestionAudio? audio;
  final List<QuestionOption> options;
  final String? correctOptionId;
  final QuestionDifficulty difficulty;
  final QuestionQualityStatus qualityStatus;
  final List<String> qualityReasons;
  final QuestionPresentation? presentation;
  final String? subtype;
  // Explicit patterns from the editorial audit, not a general guess that
  // numbered or advanced questions are invalid. Also identifies old snapshots.
  static final _placeholderAnswer = RegExp(
    r'^(?:المبدأ الفيزيائي/الحيوي السببي المعتمد|الآلية الدقيقة المفسرة للعملية التخصصية|'
    r'المبدأ الكمي/الترموديناميكي المعقد الحاكم للمنظومة|الجهة/المعلم التاريخي الموثق|'
    r'الموقع/المقياس الكارتوغرافي الدقيق|المفهوم الكارتوغرافي الجيوديسي المتقدم|'
    r'علم تاريخي معتمد رسمياً برمز موثق|الحل المنطقي الدقيق للغز|'
    r'الاستنتاج الاستدلالي الصارم للغز|الحل الخارق المحكم للمفارقة المنطقية|'
    r'المعنى المعجمي الدقيق المعتمد|العلم/العالم التاريخي الموثق|'
    r'الهوية التاريخية/العلمية المستقلة|الهوية التخصصية المتقدمة)\s+[0-9٠-٩]+$',
  );
  bool get hasKnownPlaceholderContent =>
      _placeholderAnswer.hasMatch(answer.trim()) ||
      RegExp(
        r'^ما السمة الرمزية الأبرز في راية تاريخية تخصصية [0-9٠-٩]+؟$',
      ).hasMatch(text.trim());
  bool get isQuarantined =>
      qualityStatus == QuestionQualityStatus.quarantined ||
      hasKnownPlaceholderContent ||
      categoryId == 'character_voice' && !hasApprovedVoice;
  bool get hasApprovedVoice =>
      audio?.isApproved == true &&
      qualityStatus == QuestionQualityStatus.reviewed &&
      [
        answer,
        ...acceptedAnswers,
      ].any((name) => name.trim() == audio!.speaker.trim());
  int get points => difficulty.points;
  bool get isIdentity => categoryId == 'who_am_i';
  int pointsForClues(int revealed) {
    if (revealed < 1 || revealed > 3) {
      throw RangeError.range(revealed, 1, 3, 'revealed');
    }
    return isIdentity ? points ~/ (1 << (revealed - 1)) : points;
  }

  factory Question.fromJson(Map<String, dynamic> json) => switch (json) {
    {
      'id': String id,
      'categoryId': String categoryId,
      'text': String text,
      'answer': String answer,
      'difficulty': String difficulty,
    }
        when id.trim().isNotEmpty &&
            categoryId.trim().isNotEmpty &&
            text.trim().isNotEmpty &&
            answer.trim().isNotEmpty =>
      Question(
        id: id,
        categoryId: categoryId,
        text: text,
        answer: answer,
        difficulty: QuestionDifficulty.parse(difficulty),
        usageId: _usageId(json['usageId']),
        hint: json['hint'] as String? ?? '',
        clues: _strings(json['clues']),
        acceptedAnswers: _strings(json['acceptedAnswers']),
        explanation: json['explanation'] as String? ?? '',
        sources: _strings(json['sources']),
        imageAsset: json['imageAsset'] as String?,
        imageDescription: json['imageDescription'] as String?,
        audio: json['audio'] == null
            ? null
            : QuestionAudio.fromJson(
                Map<String, dynamic>.from(json['audio'] as Map),
              ),
        options: List<QuestionOption>.unmodifiable(
          (json['options'] as List<dynamic>? ?? const []).map(
            (raw) => QuestionOption.fromJson(raw as Map<String, dynamic>),
          ),
        ),
        correctOptionId: json['correctOptionId'] as String?,
        qualityStatus: _qualityStatus(json['qualityStatus']),
        qualityReasons: _strings(json['qualityReasons']),
        presentation: json['presentation'] == null
            ? null
            : QuestionPresentation.fromJson(
                Map<String, dynamic>.from(json['presentation'] as Map),
              ),
        subtype: json['subtype'] as String?,
      ),
    _ => throw const FormatException(
      'Question requires id, categoryId, text, answer and difficulty.',
    ),
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    if (usageId != null) 'usageId': usageId,
    'categoryId': categoryId,
    'text': text,
    'answer': answer,
    'difficulty': difficulty.name,
    'hint': hint,
    'clues': clues,
    'acceptedAnswers': acceptedAnswers,
    'explanation': explanation,
    'sources': sources,
    if (imageAsset != null) 'imageAsset': imageAsset,
    if (imageDescription != null) 'imageDescription': imageDescription,
    if (audio != null) 'audio': audio!.toJson(),
    'options': options.map((option) => option.toJson()).toList(),
    if (correctOptionId != null) 'correctOptionId': correctOptionId,
    if (qualityStatus != QuestionQualityStatus.unreviewed)
      'qualityStatus': qualityStatus.name,
    if (qualityReasons.isNotEmpty) 'qualityReasons': qualityReasons,
    if (presentation != null) 'presentation': presentation!.toJson(),
    if (subtype != null) 'subtype': subtype,
  };

  static QuestionQualityStatus _qualityStatus(Object? raw) => switch (raw) {
    null || 'unreviewed' => QuestionQualityStatus.unreviewed,
    'reviewed' => QuestionQualityStatus.reviewed,
    'quarantined' => QuestionQualityStatus.quarantined,
    _ => throw FormatException('Unknown question quality status: $raw'),
  };
  static String? _usageId(Object? raw) {
    if (raw == null) {
      return null; // Read legacy snapshots and isolated fixtures.
    }
    if (raw is! String ||
        !RegExp(r'^[1-9][0-9]{0,38}$').hasMatch(raw) ||
        BigInt.parse(raw) >= (BigInt.one << 128)) {
      throw const FormatException(
        'Question usageId must be a positive decimal string.',
      );
    }
    return raw;
  }

  static List<String> _strings(Object? value) => value == null
      ? const []
      : List<String>.unmodifiable((value as List<dynamic>).cast<String>());
}
