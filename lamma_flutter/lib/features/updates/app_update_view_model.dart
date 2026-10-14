import 'package:flutter/foundation.dart';
import '../../data/updates/apk_store.dart';
import '../../data/updates/github_release_service.dart';
import '../../data/updates/update_platform.dart';
import '../../domain/models/app_release.dart';

enum UpdateStatus {
  idle,
  checking,
  available,
  current,
  downloading,
  ready,
  permission,
  installerOpened,
  noRelease,
  error,
}

class AppUpdateViewModel extends ChangeNotifier {
  AppUpdateViewModel({
    UpdatePlatform? platform,
    ApkStore? store,
    Future<AppRelease?> Function()? fetchRelease,
    this.beforeInstall,
    DateTime Function()? now,
  }) : platform = platform ?? AndroidUpdatePlatform(),
       store = store ?? createApkStore(),
       fetchRelease = fetchRelease ?? GithubReleaseService().latest,
       _now = now ?? DateTime.now;
  final UpdatePlatform platform;
  final ApkStore store;
  final Future<AppRelease?> Function() fetchRelease;
  final Future<void> Function()? beforeInstall;
  final DateTime Function() _now;
  DateTime? _lastCheckAt;
  static const automaticCheckInterval = Duration(minutes: 15);
  UpdateStatus status = UpdateStatus.idle;
  InstalledApp? installed;
  AppRelease? release;
  String? error, downloadedPath;
  int received = 0;
  bool _disposed = false, _cancelled = false;
  bool get supported => platform.supported;
  bool get hasUpdate =>
      installed != null &&
      release != null &&
      release!.buildNumber > installed!.buildNumber;
  bool get busy =>
      status == UpdateStatus.checking || status == UpdateStatus.downloading;
  double get progress =>
      release == null ? 0 : (received / release!.size).clamp(0, 1);
  Future<void> initialize() async {
    try {
      installed = await platform.installedApp();
      if (!_disposed) notifyListeners();
    } on Object {
      if (!_disposed) {
        error = 'تعذّر قراءة إصدار التطبيق. أعد المحاولة.';
        _set(UpdateStatus.error);
      }
    }
  }

  void _set(UpdateStatus next) {
    if (!_disposed) {
      status = next;
      notifyListeners();
    }
  }

  Future<void> check({bool automatic = false}) async {
    if (busy || _disposed) return;
    if (automatic &&
        (!supported ||
            downloadedPath != null ||
            _lastCheckAt != null &&
                _now().difference(_lastCheckAt!) < automaticCheckInterval)) {
      return;
    }
    _lastCheckAt = _now();
    error = null;
    if (!automatic) release = null;
    downloadedPath = null;
    _set(UpdateStatus.checking);
    try {
      installed = await platform.installedApp();
      if (_disposed) return;
      final latest = await fetchRelease();
      if (_disposed) return;
      release = latest;
      _set(
        latest == null
            ? UpdateStatus.noRelease
            : latest.buildNumber > installed!.buildNumber
            ? UpdateStatus.available
            : UpdateStatus.current,
      );
    } on Object catch (exception) {
      if (!_disposed) {
        error = exception is UpdateCheckException
            ? exception.message
            : exception is FormatException
            ? const UpdateCheckException(
                UpdateCheckFailure.invalidMetadata,
              ).message
            : 'تعذّر فحص التحديث. أعد المحاولة أو افتح رابط التحميل المباشر.';
        _set(UpdateStatus.error);
      }
    }
  }

  Future<void> download() async {
    if (!supported ||
        busy ||
        release == null ||
        installed == null ||
        release!.buildNumber <= installed!.buildNumber ||
        _disposed) {
      return;
    }
    _cancelled = false;
    error = null;
    received = 0;
    downloadedPath = null;
    _set(UpdateStatus.downloading);
    try {
      final path = await store.download(release!, (n) {
        if (!_disposed) {
          received = n;
          notifyListeners();
        }
      });
      if (_disposed) return;
      if (_cancelled) {
        _set(UpdateStatus.available);
        return;
      }
      downloadedPath = path;
      _set(UpdateStatus.ready);
    } on Object {
      if (_disposed) return;
      if (_cancelled) {
        _set(UpdateStatus.available);
      } else {
        error =
            'لم يكتمل تنزيل التحديث أو فحص سلامته. لم يُفتح التثبيت؛ أعد التنزيل.';
        _set(UpdateStatus.error);
      }
    }
  }

  void cancelDownload() {
    if (status == UpdateStatus.downloading) {
      _cancelled = true;
      store.cancel();
    }
  }

  Future<void> install() async {
    if (!supported ||
        _disposed ||
        downloadedPath == null ||
        release == null ||
        busy) {
      return;
    }
    error = null;
    _set(UpdateStatus.checking);
    try {
      await store.verify(downloadedPath!, release!);
      if (_disposed) return;
      if (!await platform.canInstall()) {
        if (!_disposed) _set(UpdateStatus.permission);
        return;
      }
      await beforeInstall?.call();
      if (_disposed) return;
      await platform.install(downloadedPath!, release!.buildNumber);
      _set(UpdateStatus.installerOpened);
    } on Object {
      if (!_disposed) {
        error =
            'تعذّر فتح التثبيت. تأكد من السماح بالتثبيت، أو أعد التنزيل. المباراة المحفوظة لم تُحذف.';
        _set(UpdateStatus.error);
      }
    }
  }

  Future<void> openPermission() async {
    try {
      await platform.requestInstallPermission();
    } on Object {
      if (!_disposed) {
        error =
            'تعذّر فتح إذن التثبيت. يمكنك السماح به من إعدادات Android للتطبيق.';
        _set(UpdateStatus.error);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    store.cancel();
    super.dispose();
  }
}
