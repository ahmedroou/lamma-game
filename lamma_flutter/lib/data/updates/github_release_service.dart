import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/app_release.dart';

enum UpdateCheckFailure { rateLimited, server, invalidMetadata, network }

final class UpdateCheckException implements Exception {
  const UpdateCheckException(this.failure);
  final UpdateCheckFailure failure;
  String get message => switch (failure) {
    UpdateCheckFailure.rateLimited =>
      'مصدر التحديث يقيّد الطلبات مؤقتًا. حاول لاحقًا أو استخدم رابط التحميل المباشر.',
    UpdateCheckFailure.server =>
      'مصدر التحديث غير متاح مؤقتًا. حاول مجددًا بعد قليل.',
    UpdateCheckFailure.invalidMetadata =>
      'بيانات الإصدار المنشور غير مكتملة أو غير صالحة. أعد الفحص لاحقًا أو افتح رابط التحميل المباشر.',
    UpdateCheckFailure.network =>
      'تعذّر الاتصال بمصدر التحديث. تحقق من الاتصال وحاول مجددًا، أو افتح رابط التحميل المباشر.',
  };
}

final class GithubReleaseService {
  GithubReleaseService({http.Client Function()? clientFactory})
    : clientFactory = clientFactory ?? http.Client.new;
  final http.Client Function() clientFactory;

  Future<AppRelease?> latest() async {
    final client = clientFactory();
    try {
      UpdateCheckException? manifestFailure;
      // A tiny public release asset avoids the anonymous REST API rate limit.
      // Older releases have no manifest, so their API metadata remains supported.
      try {
        final release = await _fetch(client, AppRelease.manifestUri, 8);
        if (release != null) return release;
      } on UpdateCheckException catch (error) {
        manifestFailure = error;
      }
      final release = await _fetch(client, AppRelease.latestUri, 12);
      if (release == null && manifestFailure != null) throw manifestFailure;
      return release;
    } finally {
      client.close();
    }
  }

  Future<AppRelease?> _fetch(http.Client client, Uri uri, int seconds) async {
    try {
      final response = await client
          .get(
            uri,
            headers: {
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
            },
          )
          .timeout(Duration(seconds: seconds));
      if (response.statusCode == 404) return null;
      if (response.statusCode == 403 || response.statusCode == 429) {
        throw const UpdateCheckException(UpdateCheckFailure.rateLimited);
      }
      if (response.statusCode != 200) {
        throw const UpdateCheckException(UpdateCheckFailure.server);
      }
      if (response.bodyBytes.length > 1024 * 1024) {
        throw const FormatException('Oversized release metadata');
      }
      return AppRelease.fromGithub(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on UpdateCheckException {
      rethrow;
    } on FormatException {
      throw const UpdateCheckException(UpdateCheckFailure.invalidMetadata);
    } on TypeError {
      throw const UpdateCheckException(UpdateCheckFailure.invalidMetadata);
    } on TimeoutException {
      throw const UpdateCheckException(UpdateCheckFailure.network);
    } on http.ClientException {
      throw const UpdateCheckException(UpdateCheckFailure.network);
    }
  }
}
