import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../domain/models/app_release.dart';
import 'apk_store.dart';

ApkStore createStore() => LocalApkStore();

/// Downloads to app-private cache, streaming rather than holding an APK in RAM.
final class LocalApkStore implements ApkStore {
  LocalApkStore({
    this.cacheDirectory = getTemporaryDirectory,
    http.Client Function()? clientFactory,
  }) : clientFactory = clientFactory ?? http.Client.new;
  final Future<Directory> Function() cacheDirectory;
  final http.Client Function() clientFactory;
  Completer<void>? _abort;
  @override
  void cancel() {
    if (_abort?.isCompleted == false) _abort!.complete();
  }

  @override
  Future<String> download(
    AppRelease release,
    void Function(int) onProgress,
  ) async {
    if (_abort != null) throw StateError('Download already running');
    final abort = _abort = Completer<void>();
    final client = clientFactory();
    IOSink? sink;
    File? partial;
    try {
      final dir = Directory(
        p.join((await cacheDirectory()).path, 'app_updates'),
      );
      await dir.create(recursive: true);
      partial = File(p.join(dir.path, 'update.apk.part'));
      final response = await client
          .send(
            http.AbortableRequest(
              'GET',
              release.url,
              abortTrigger: abort.future,
            ),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200 ||
          response.contentLength != null &&
              response.contentLength != release.size) {
        throw const FormatException('Download response size mismatch');
      }
      sink = partial.openWrite();
      var received = 0;
      var reported = 0;
      await for (final chunk in response.stream.timeout(
        const Duration(seconds: 30),
      )) {
        if (abort.isCompleted) throw http.RequestAbortedException();
        received += chunk.length;
        if (received > release.size) {
          throw const FormatException('Oversized APK');
        }
        sink.add(chunk);
        await sink.flush();
        if (received - reported >= 256 * 1024 || received == release.size) {
          reported = received;
          onProgress(received);
        }
      }
      await sink.close();
      sink = null;
      if (abort.isCompleted) throw http.RequestAbortedException();
      if (received != release.size) {
        throw const FormatException('Incomplete APK');
      }
      await verify(partial.path, release);
      final ready = File(p.join(dir.path, 'update.apk'));
      if (await ready.exists()) await ready.delete();
      await partial.rename(ready.path);
      return ready.path;
    } finally {
      client.close();
      await sink?.close();
      if (partial != null && await partial.exists()) await partial.delete();
      _abort = null;
    }
  }

  @override
  Future<void> verify(String path, AppRelease release) async {
    final file = File(path);
    if (!await file.exists() ||
        await file.length() != release.size ||
        (await sha256.bind(file.openRead()).first).toString() !=
            release.sha256) {
      throw const FormatException('APK integrity check failed');
    }
  }
}
