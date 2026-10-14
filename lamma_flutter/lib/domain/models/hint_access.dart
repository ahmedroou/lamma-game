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

enum SurpriseEffect {
  none,
  extraTime,
  bonusPoints,
  hint,
  doublePoints,
  failurePenalty,
  options,
  plank,
  selfWager,
  opponentWager,
  designatedPlayer,
  doubleOrLose,
  opponentBonus,
  noOpponent,
  silence,
  opponentDesignates,
  selfDesignates,
  halfTime,
  changeQuestion,
  chooseOpponentCategory,
  banPlayer,
  wheelOfFortune,
}

/// An opening card with persisted effect parameters and visible conditions.
final class SurpriseCard {
  SurpriseCard({
    required this.id,
    required this.text,
    this.grantsHint = false,
    this.effect = SurpriseEffect.none,
    this.note = '',
    this.amount = 0,
    this.price = 0,
    this.optionCount = 6,
    this.includeCorrect = true,
    this.pointsDivisor = 1,
    this.maximumQuestionPoints,
    this.selectionRule,
  }) {
    if (id.isEmpty ||
        text.trim().isEmpty ||
        amount < 0 ||
        price < 0 ||
        grantsHint && price > 0 ||
        !{4, 6}.contains(optionCount) ||
        !{1, 4}.contains(pointsDivisor)) {
      throw const FormatException('Incomplete surprise card.');
    }
  }
  final String id, text;
  final bool grantsHint;
  final SurpriseEffect effect;
  final String note;
  final int amount, price, optionCount, pointsDivisor;
  final bool includeCorrect;
  final int? maximumQuestionPoints;
  final String? selectionRule;
  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'grantsHint': grantsHint,
    'effect': effect.name,
    'note': note,
    'amount': amount,
    'price': price,
    'optionCount': optionCount,
    'includeCorrect': includeCorrect,
    'pointsDivisor': pointsDivisor,
    if (maximumQuestionPoints != null)
      'maximumQuestionPoints': maximumQuestionPoints,
    if (selectionRule != null) 'selectionRule': selectionRule,
  };
  factory SurpriseCard.fromJson(Map<String, Object?> json) => SurpriseCard(
    id: json['id'] as String,
    text: json['text'] as String,
    grantsHint: json['grantsHint'] as bool? ?? false,
    effect: SurpriseEffect.values.byName(json['effect'] as String? ?? 'none'),
    note: json['note'] as String? ?? '',
    amount: json['amount'] as int? ?? 0,
    price: json['price'] as int? ?? 0,
    optionCount: json['optionCount'] as int? ?? 6,
    includeCorrect: json['includeCorrect'] as bool? ?? true,
    pointsDivisor: json['pointsDivisor'] as int? ?? 1,
    maximumQuestionPoints: json['maximumQuestionPoints'] as int?,
    selectionRule: json['selectionRule'] as String?,
  );
}
