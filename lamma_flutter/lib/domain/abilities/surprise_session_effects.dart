/// Persisted future effects; none depend on wall-clock time or a fresh draw.
abstract final class SurpriseSessionEffects {
  static List<Map<String, Object?>> entries(
    Map<String, Object?> data,
    String key,
  ) => (data[key] as List? ?? const [])
      .map((item) => Map<String, Object?>.from(item as Map))
      .toList();
  static Map<String, Object?> append(
    Map<String, Object?> data,
    String key,
    Map<String, Object?> entry,
  ) => {
    ...data,
    key: [...entries(data, key), entry],
  };
  static int reserved(Map<String, Object?> data, String owner) =>
      entries(data, 'wagers')
          .where((entry) => entry['owner'] == owner)
          .fold(0, (sum, entry) => sum + (entry['amount'] as int));
  static List<Map<String, Object?>> dueWagers(
    Map<String, Object?> data,
    int turn,
  ) => entries(
    data,
    'wagers',
  ).where((entry) => entry['dueTurn'] == turn).toList();
  static Map<String, int> wagerDeltas(
    Iterable<Map<String, Object?>> wagers,
    String? winner,
  ) {
    final result = <String, int>{};
    for (final wager in wagers) {
      final targetSucceeded = winner == wager['target'];
      final won = wager['onCorrect'] == true
          ? targetSucceeded
          : !targetSucceeded;
      final owner = wager['owner'] as String, amount = wager['amount'] as int;
      result[owner] = (result[owner] ?? 0) + (won ? amount : -amount);
    }
    return result;
  }

  static Map<String, Object?> completeTurn(
    Map<String, Object?> data,
    int turn,
  ) => {
    'wagers': entries(
      data,
      'wagers',
    ).where((entry) => (entry['dueTurn'] as int) > turn).toList(),
    'categories': entries(
      data,
      'categories',
    ).where((entry) => (entry['dueTurn'] as int) > turn).toList(),
    'bans': entries(
      data,
      'bans',
    ).where((entry) => (entry['expiresTurn'] as int) > turn).toList(),
  };
  static String playerKey(String name) => name
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
      .replaceAll(RegExp(r'[أإآ]'), 'ا')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();
  static bool banned(
    Map<String, Object?> data,
    String team,
    String name,
    int turn,
  ) => entries(data, 'bans').any(
    (entry) =>
        entry['target'] == team &&
        playerKey(entry['player'] as String) == playerKey(name) &&
        turn >= (entry['startsTurn'] as int) &&
        turn <= (entry['expiresTurn'] as int),
  );
  static List<Map<String, Object?>> activeBans(
    Map<String, Object?> data,
    int turn,
  ) => entries(data, 'bans')
      .where(
        (entry) =>
            turn >= (entry['startsTurn'] as int) &&
            turn <= (entry['expiresTurn'] as int),
      )
      .toList();

  static void validate(
    Map<String, Object?> data,
    Set<String> teams,
    Set<String> categories,
  ) {
    if (data.keys.any(
      (key) => !{'wagers', 'categories', 'bans'}.contains(key),
    )) {
      throw const FormatException('Unknown future surprise effect.');
    }
    final ids = <String>{};
    for (final kind in ['wagers', 'categories', 'bans']) {
      if (data[kind] != null && data[kind] is! List) {
        throw const FormatException('Invalid future effects list.');
      }
      for (final item in entries(data, kind)) {
        if (item['id'] is! String ||
            !ids.add(item['id'] as String) ||
            !teams.contains(item['owner']) ||
            !teams.contains(item['target'])) {
          throw const FormatException('Invalid future effect identity.');
        }
        if (kind != 'wagers' && item['owner'] == item['target']) {
          throw const FormatException('Opponent effect cannot target owner.');
        }
        if (kind == 'wagers' &&
            ((item['onCorrect'] == true && item['owner'] != item['target']) ||
                (item['onCorrect'] == false &&
                    item['owner'] == item['target']))) {
          throw const FormatException('Invalid wager target.');
        }
        if (kind == 'wagers' &&
            (item['amount'] is! int ||
                (item['amount'] as int) <= 0 ||
                item['dueTurn'] is! int ||
                (item['dueTurn'] as int) < 0 ||
                item['onCorrect'] is! bool)) {
          throw const FormatException('Invalid wager.');
        }
        if (kind == 'categories' &&
            (!categories.contains(item['category']) ||
                item['dueTurn'] is! int ||
                (item['dueTurn'] as int) < 0)) {
          throw const FormatException('Invalid forced category.');
        }
        if (kind == 'bans' &&
            (item['player'] is! String ||
                (item['player'] as String).trim().isEmpty ||
                (item['player'] as String).length > 80 ||
                item['startsTurn'] is! int ||
                item['expiresTurn'] is! int ||
                (item['startsTurn'] as int) < 0 ||
                (item['expiresTurn'] as int) < (item['startsTurn'] as int))) {
          throw const FormatException('Invalid player ban.');
        }
      }
    }
  }
}
