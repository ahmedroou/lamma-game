final class AppSettings {
  const AppSettings({this.motion = true, this.haptics = true});
  final bool motion, haptics;
  AppSettings copyWith({bool? motion, bool? haptics}) => AppSettings(
    motion: motion ?? this.motion,
    haptics: haptics ?? this.haptics,
  );
  Map<String, Object?> toJson() => {
    'version': 1,
    'motion': motion,
    'haptics': haptics,
  };
  factory AppSettings.fromJson(Map<String, dynamic> json) => switch (json) {
    {'version': 1, 'motion': bool motion, 'haptics': bool haptics} =>
      AppSettings(motion: motion, haptics: haptics),
    _ => throw const FormatException('Invalid settings format.'),
  };
}
