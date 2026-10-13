import 'team.dart';

abstract final class GameRules {
  static const minimumTeams = 2;
  static const maximumTeams = 3;
  static const selectedCategoryCount = 6;
  static const abilitiesCategoryId = '__abilities__';
  static const questionsPerCategory = 5;
  static const primaryQuestionSeconds = 30;
  static const opponentAnswerSeconds = 7;
}

final class SessionConfig {
  SessionConfig({
    required Iterable<TeamState> teams,
    required Iterable<String> categoryIds,
  }) : teams = List.unmodifiable(teams),
       categoryIds = Set.unmodifiable(categoryIds) {
    if (this.teams.length < GameRules.minimumTeams ||
        this.teams.length > GameRules.maximumTeams) {
      throw ArgumentError('A session requires 2–3 teams.');
    }
    if (this.teams.map((team) => team.id).toSet().length != this.teams.length ||
        this.teams.map((team) => team.name.trim()).toSet().length !=
            this.teams.length) {
      throw ArgumentError('Team IDs and names must be unique.');
    }
    if (this.categoryIds.length != GameRules.selectedCategoryCount ||
        this.categoryIds.contains(GameRules.abilitiesCategoryId)) {
      throw ArgumentError('Select exactly six normal categories.');
    }
  }
  final List<TeamState> teams;
  final Set<String> categoryIds;
  List<String> get boardCategoryIds => [
    ...categoryIds,
    GameRules.abilitiesCategoryId,
  ];
  Map<String, dynamic> toJson() => {
    'teams': teams.map((team) => team.toJson()).toList(),
    'categoryIds': categoryIds.toList(),
  };
  factory SessionConfig.fromJson(Map<String, dynamic> json) {
    if (json case {
      'teams': List<dynamic> teams,
      'categoryIds': List<dynamic> categories,
    }) {
      return SessionConfig(
        teams: teams.map(
          (item) => TeamState.fromJson(item as Map<String, dynamic>),
        ),
        categoryIds: categories.cast<String>(),
      );
    }
    throw const FormatException('Invalid session configuration.');
  }
}
