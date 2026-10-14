import '../../domain/models/app_release.dart';
import 'apk_store.dart';

ApkStore createStore() => _Unavailable();

final class _Unavailable implements ApkStore {
  @override
  Future<String> download(AppRelease release, void Function(int) onProgress) =>
      Future.error(UnsupportedError('Android only'));
  @override
  Future<void> verify(String path, AppRelease release) =>
      Future.error(UnsupportedError('Android only'));
  @override
  void cancel() {}
}
