/// A host's explicit score change, independent of question judgments.
final class HostScoreAdjustment {
  HostScoreAdjustment({
    required this.id,
    required this.teamId,
    required this.before,
    required this.after,
    required this.at,
    this.reason = '',
  }) {
    if (id.isEmpty ||
        teamId.isEmpty ||
        before == after ||
        reason.length > 120) {
      throw const FormatException('Invalid host score adjustment.');
    }
  }
  final String id, teamId, reason;
  final int before, after;
  final DateTime at;
  int get delta => after - before;
  Map<String, Object?> toJson() => {
    'id': id,
    'teamId': teamId,
    'before': before,
    'after': after,
    'at': at.toUtc().toIso8601String(),
    'reason': reason,
  };
  factory HostScoreAdjustment.fromJson(Map<String, dynamic> json) =>
      HostScoreAdjustment(
        id: json['id'] as String,
        teamId: json['teamId'] as String,
        before: json['before'] as int,
        after: json['after'] as int,
        at: DateTime.parse(json['at'] as String),
        reason: json['reason'] as String? ?? '',
      );
}
