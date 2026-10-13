final class OwnedAbility {
  OwnedAbility({
    required this.id,
    required this.definitionId,
    required this.ownerTeamId,
    required this.acquiredTurn,
    required this.remainingUses,
  }) {
    if (id.isEmpty ||
        definitionId.isEmpty ||
        ownerTeamId.isEmpty ||
        acquiredTurn < 0 ||
        remainingUses < 1) {
      throw ArgumentError('Invalid owned ability.');
    }
  }
  final String id, definitionId, ownerTeamId;
  final int acquiredTurn, remainingUses;
  OwnedAbility withRemainingUses(int uses) => OwnedAbility(
    id: id,
    definitionId: definitionId,
    ownerTeamId: ownerTeamId,
    acquiredTurn: acquiredTurn,
    remainingUses: uses,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'definitionId': definitionId,
    'ownerTeamId': ownerTeamId,
    'acquiredTurn': acquiredTurn,
    'remainingUses': remainingUses,
  };
  factory OwnedAbility.fromJson(Map<String, dynamic> json) => switch (json) {
    {
      'id': String id,
      'definitionId': String definitionId,
      'ownerTeamId': String ownerTeamId,
      'acquiredTurn': int turn,
      'remainingUses': int uses,
    } =>
      OwnedAbility(
        id: id,
        definitionId: definitionId,
        ownerTeamId: ownerTeamId,
        acquiredTurn: turn,
        remainingUses: uses,
      ),
    _ => throw const FormatException('Invalid ability inventory item.'),
  };
}

final class TeamState {
  TeamState({
    required this.id,
    required this.name,
    this.score = 0,
    Iterable<OwnedAbility> inventory = const [],
  }) : inventory = List.unmodifiable(inventory) {
    if (id.isEmpty || name.trim().isEmpty) {
      throw ArgumentError('Team identity is required.');
    }
    if (this.inventory.any((card) => card.ownerTeamId != id) ||
        this.inventory.map((card) => card.id).toSet().length !=
            this.inventory.length) {
      throw ArgumentError(
        'Inventory must contain unique cards belonging to this team.',
      );
    }
  }
  final String id, name;
  final int score;
  final List<OwnedAbility> inventory;
  TeamState copyWith({int? score, Iterable<OwnedAbility>? inventory}) =>
      TeamState(
        id: id,
        name: name,
        score: score ?? this.score,
        inventory: inventory ?? this.inventory,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'score': score,
    'inventory': inventory.map((card) => card.toJson()).toList(),
  };
  factory TeamState.fromJson(Map<String, dynamic> json) {
    if (json case {
      'id': String id,
      'name': String name,
      'score': int score,
      'inventory': List<dynamic> inventory,
    }) {
      return TeamState(
        id: id,
        name: name,
        score: score,
        inventory: inventory.map(
          (item) => OwnedAbility.fromJson(item as Map<String, dynamic>),
        ),
      );
    }
    throw const FormatException('Invalid team snapshot.');
  }
}
