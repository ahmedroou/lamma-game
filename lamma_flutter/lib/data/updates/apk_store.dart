import 'apk_store_stub.dart'
    if (dart.library.io) 'apk_store_io.dart'
    as backend;
import '../../domain/models/app_release.dart';

abstract interface class ApkStore {
  Future<String> download(
    AppRelease release,
    void Function(int received) onProgress,
  );
  Future<void> verify(String path, AppRelease release);
  void cancel();
}

ApkStore createApkStore() => backend.createStore();
