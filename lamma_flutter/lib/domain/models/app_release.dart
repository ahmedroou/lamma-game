/// A stable Android release from the project's public GitHub repository.
final class AppRelease {
  const AppRelease({
    required this.version,
    required this.buildNumber,
    required this.url,
    required this.sha256,
    required this.size,
    required this.notes,
  });
  final String version, sha256, notes;
  final int buildNumber, size;
  final Uri url;
  static const repository = 'ahmedroou/lamma-game';
  static final latestUri = Uri.https(
    'api.github.com',
    '/repos/$repository/releases/latest',
  );
  static final downloadPage = Uri.https(
    'github.com',
    '/$repository/releases/latest',
  );
  static final manifestUri = Uri.https(
    'github.com',
    '/$repository/releases/latest/download/update.json',
  );
  static const maxSize = 500 * 1024 * 1024;
  factory AppRelease.fromGithub(Map<String, dynamic> json) {
    final tag = json['tag_name'];
    final match = tag is String
        ? RegExp(r'^v(\d+\.\d+\.\d+)\+([1-9]\d*)$').firstMatch(tag)
        : null;
    if (match == null ||
        json['draft'] != false ||
        json['prerelease'] != false) {
      throw const FormatException('Invalid stable release tag.');
    }
    final assets = json['assets'];
    if (assets is! List) throw const FormatException('Missing assets.');
    final apks = assets
        .whereType<Map<String, dynamic>>()
        .where(
          (a) => a['name'] == 'lamma-android.apk' && a['state'] == 'uploaded',
        )
        .toList();
    if (apks.length != 1) {
      throw const FormatException('Missing universal Android APK.');
    }
    final apk = apks.single;
    final url = Uri.tryParse(apk['browser_download_url'] as String? ?? '');
    final digest = apk['digest'] as String? ?? '';
    final size = apk['size'];
    if (url == null ||
        url.scheme != 'https' ||
        url.host != 'github.com' ||
        url.userInfo.isNotEmpty ||
        url.hasQuery ||
        url.hasFragment ||
        url.hasPort ||
        url.pathSegments.length != 6 ||
        url.pathSegments.join('/') !=
            '$repository/releases/download/$tag/lamma-android.apk' ||
        !RegExp(r'^sha256:[a-fA-F0-9]{64}$').hasMatch(digest) ||
        size is! int ||
        size <= 0 ||
        size > maxSize) {
      throw const FormatException('Untrusted or incomplete APK metadata.');
    }
    return AppRelease(
      version: match[1]!,
      buildNumber: int.parse(match[2]!),
      url: url,
      sha256: digest.substring(7).toLowerCase(),
      size: size,
      notes: json['body'] as String? ?? '',
    );
  }
}
