import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/app_release.dart';

final class GithubReleaseService {
  GithubReleaseService({http.Client Function()? clientFactory})
    : clientFactory = clientFactory ?? http.Client.new;
  final http.Client Function() clientFactory;
  Future<AppRelease?> latest() async {
    final client = clientFactory();
    try {
      final response = await client
          .get(
            AppRelease.latestUri,
            headers: {
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
            },
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) {
        throw StateError('GitHub status ${response.statusCode}');
      }
      if (response.bodyBytes.length > 1024 * 1024) {
        throw const FormatException('Oversized release metadata');
      }
      return AppRelease.fromGithub(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } finally {
      client.close();
    }
  }
}
