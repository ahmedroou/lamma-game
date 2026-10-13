import '../models/question.dart';
import '../models/team.dart';
import '../models/hint_access.dart';

enum AbilityWindow {
  anyTime,
  categorySelection,
  beforeQuestion,
  duringQuestion,
  beforeScoring,
  betweenTurns,
}

enum AbilityTarget { self, opponent, anyTeam }

final class AbilityDefinition {
  AbilityDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.effectKey,
    required Iterable<AbilityWindow> windows,
    required this.target,
    required this.usesPerCard,
  }) : windows = Set.unmodifiable(windows) {
    if (id.isEmpty ||
        title.isEmpty ||
        effectKey.isEmpty ||
        this.windows.isEmpty ||
        usesPerCard < 1) {
      throw ArgumentError('Ability definition is incomplete.');
    }
  }
  final String id, title, description, effectKey;
  final Set<AbilityWindow> windows;
  final AbilityTarget target;
  final int usesPerCard;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'effectKey': effectKey,
    'windows': windows.map((window) => window.name).toList(),
    'target': target.name,
    'usesPerCard': usesPerCard,
  };
  factory AbilityDefinition.fromJson(Map<String, dynamic> json) {
    if (json case {
      'id': String id,
      'title': String title,
      'description': String description,
      'effectKey': String key,
      'windows': List<dynamic> windows,
      'target': String target,
      'usesPerCard': int uses,
    }) {
      return AbilityDefinition(
        id: id,
        title: title,
        description: description,
        effectKey: key,
        windows: windows.map(
          (value) => AbilityWindow.values.byName(value as String),
        ),
        target: AbilityTarget.values.byName(target),
        usesPerCard: uses,
      );
    }
    throw const FormatException('Invalid ability definition.');
  }
}

final class AbilityContext {
  AbilityContext({
    required Iterable<TeamState> teams,
    required this.ownerTeamId,
    required this.targetTeamId,
    required this.window,
    this.question,
    Map<String, Object?> roundData = const {},
  }) : teams = List.unmodifiable(teams),
       roundData = Map.unmodifiable(roundData);
  final List<TeamState> teams;
  final String ownerTeamId, targetTeamId;
  final AbilityWindow window;
  final Question? question;
  final Map<String, Object?> roundData;
}

final class AbilityImpact {
  AbilityImpact({
    this.grantsHint = false,
    Map<String, int> scoreDeltas = const {},
    Map<String, Object?> roundChanges = const {},
  }) : scoreDeltas = Map.unmodifiable(scoreDeltas),
       roundChanges = Map.unmodifiable(roundChanges);
  final Map<String, int> scoreDeltas;
  final bool grantsHint;
  final Map<String, Object?> roundChanges;
}

abstract interface class AbilityEffect {
  String? validate(AbilityContext context);
  AbilityImpact apply(AbilityContext context);
}

final class AbilityRegistry {
  AbilityRegistry({
    Iterable<AbilityDefinition> definitions = const [],
    Map<String, AbilityEffect> effects = const {},
  }) : definitions = Map.unmodifiable({
         for (final definition in definitions) definition.id: definition,
       }),
       effects = Map.unmodifiable(effects) {
    if (this.definitions.length != definitions.length) {
      throw ArgumentError('Duplicate ability IDs.');
    }
  }
  final Map<String, AbilityDefinition> definitions;
  final Map<String, AbilityEffect> effects;
  bool isReady(String id) {
    final definition = definitions[id];
    return definition != null && effects.containsKey(definition.effectKey);
  }
}

final class AbilityUseResult {
  AbilityUseResult(Iterable<TeamState> teams, Map<String, Object?> roundData)
    : teams = List.unmodifiable(teams),
      roundData = Map.unmodifiable(roundData);
  final List<TeamState> teams;
  final Map<String, Object?> roundData;
}

final class AbilityService {
  AbilityService(this.registry);
  final AbilityRegistry registry;

  AbilityUseResult use({
    required Iterable<TeamState> teams,
    required String ownerTeamId,
    required String cardId,
    required AbilityWindow window,
    String? targetTeamId,
    Question? question,
    Map<String, Object?> roundData = const {},
  }) {
    final snapshot = List<TeamState>.of(teams);
    final owner = snapshot.firstWhere(
      (team) => team.id == ownerTeamId,
      orElse: () => throw StateError('Unknown owner.'),
    );
    final card = owner.inventory.firstWhere(
      (card) => card.id == cardId,
      orElse: () => throw StateError('This team does not own the card.'),
    );
    final definition = registry.definitions[card.definitionId];
    if (definition == null || !registry.isReady(card.definitionId)) {
      throw StateError('Ability is not configured.');
    }
    if (card.remainingUses > definition.usesPerCard) {
      throw StateError('Ability inventory exceeds its configured uses.');
    }
    if (!definition.windows.contains(AbilityWindow.anyTime) &&
        !definition.windows.contains(window)) {
      throw StateError('Ability cannot be used in this phase.');
    }
    final target = targetTeamId ?? ownerTeamId;
    if (!snapshot.any((team) => team.id == target)) {
      throw StateError('Unknown target.');
    }
    if (definition.target == AbilityTarget.self && target != ownerTeamId ||
        definition.target == AbilityTarget.opponent && target == ownerTeamId) {
      throw StateError('Invalid ability target.');
    }
    final context = AbilityContext(
      teams: snapshot,
      ownerTeamId: ownerTeamId,
      targetTeamId: target,
      window: window,
      question: question,
      roundData: roundData,
    );
    final effect = registry.effects[definition.effectKey]!;
    final validation = effect.validate(context);
    if (validation != null) throw StateError(validation);
    final impact = effect.apply(context);
    if (impact.roundChanges.containsKey('hintAccess') ||
        impact.roundChanges.containsKey('hintRevealed')) {
      throw StateError('Hint effects must use the grantsHint contract.');
    }
    if (impact.grantsHint &&
        (question == null || question.isIdentity || question.hint.isEmpty)) {
      throw StateError('This question cannot receive an auxiliary hint.');
    }
    if (impact.scoreDeltas.keys.any(
      (id) => !snapshot.any((team) => team.id == id),
    )) {
      throw StateError('Effect references an unknown team.');
    }
    final updated = snapshot.map((team) {
      final inventory = team.id != ownerTeamId
          ? team.inventory
          : team.inventory.where((owned) => owned.id != cardId).toList();
      if (team.id == ownerTeamId && card.remainingUses > 1) {
        inventory.add(card.withRemainingUses(card.remainingUses - 1));
      }
      return team.copyWith(
        score: team.score + (impact.scoreDeltas[team.id] ?? 0),
        inventory: inventory,
      );
    });
    return AbilityUseResult(updated, {
      ...roundData,
      ...impact.roundChanges,
      if (impact.grantsHint)
        'hintAccess': HintAccess(
          questionId: question!.id,
          teamId: target,
          source: HintSource.ability,
          cardId: card.id,
        ).toJson(),
    });
  }
}
