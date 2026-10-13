enum HintSource { ability, surprise }

/// Permission belongs to one question and one team, with a card provenance.
final class HintAccess {
  HintAccess({
    required this.questionId,
    required this.teamId,
    required this.source,
    required this.cardId,
  }) {
    if (questionId.isEmpty || teamId.isEmpty || cardId.isEmpty) {
      throw const FormatException('Incomplete hint permission.');
    }
  }
  final String questionId, teamId, cardId;
  final HintSource source;
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'teamId': teamId,
    'source': source.name,
    'cardId': cardId,
  };
  factory HintAccess.fromJson(Map<String, Object?> json) => HintAccess(
    questionId: json['questionId'] as String,
    teamId: json['teamId'] as String,
    source: HintSource.values.byName(json['source'] as String),
    cardId: json['cardId'] as String,
  );
}

/// A configured opening card. No cards or draw probabilities are enabled by default.
final class SurpriseCard {
  SurpriseCard({
    required this.id,
    required this.text,
    this.grantsHint = false,
  }) {
    if (id.isEmpty || text.trim().isEmpty) {
      throw const FormatException('Incomplete surprise card.');
    }
  }
  final String id, text;
  final bool grantsHint;
  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'grantsHint': grantsHint,
  };
  factory SurpriseCard.fromJson(Map<String, Object?> json) => SurpriseCard(
    id: json['id'] as String,
    text: json['text'] as String,
    grantsHint: json['grantsHint'] as bool,
  );
}
