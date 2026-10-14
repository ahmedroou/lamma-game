import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lamma/data/updates/apk_store.dart';
import 'package:lamma/data/updates/apk_store_io.dart';
import 'package:lamma/data/updates/github_release_service.dart';
import 'package:lamma/data/updates/update_platform.dart';
import 'package:lamma/domain/models/app_release.dart';
import 'package:lamma/features/updates/app_update_view_model.dart';

final bytes = List<int>.generate(300000, (i) => i % 256);
AppRelease release({int build = 3, String? digest}) => AppRelease(
  version: '0.3.0',
  buildNumber: build,
  url: Uri.parse(
    'https://github.com/ahmedroou/lamma-game/releases/download/v0.3.0+3/lamma-android.apk',
  ),
  sha256: digest ?? sha256.convert(bytes).toString(),
  size: bytes.length,
  notes: 'تحسينات',
);
Map<String, dynamic> metadata() => {
  'tag_name': 'v0.3.0+3',
  'draft': false,
  'prerelease': false,
  'body': 'تحسينات',
  'assets': [
    {
      'name': 'lamma-android.apk',
      'state': 'uploaded',
      'browser_download_url': release().url.toString(),
      'digest': 'sha256:${release().sha256}',
      'size': bytes.length,
    },
  ],
};

class FakePlatform implements UpdatePlatform {
  bool permission = true;
  int installations = 0, permissionRequests = 0;
  @override
  bool supported = true;
  @override
  Future<InstalledApp> installedApp() async => const InstalledApp('0.2.0', 2);
  @override
  Future<bool> canInstall() async => permission;
  @override
  Future<void> requestInstallPermission() async {
    permissionRequests++;
  }

  @override
  Future<void> install(String path, int expectedBuild) async {
    expect(expectedBuild, 3);
    installations++;
  }
}

class FakeStore implements ApkStore {
  bool failVerify = false, cancelled = false;
  Completer<String>? pending;
  @override
  Future<String> download(
    AppRelease release,
    void Function(int) progress,
  ) async {
    progress(release.size);
    return pending?.future ?? '/cache/app_updates/update.apk';
  }

  @override
  Future<void> verify(String path, AppRelease release) async {
    if (failVerify) throw StateError('tampered');
  }

  @override
  void cancel() {
    cancelled = true;
    if (pending?.isCompleted == false) {
      pending!.completeError(StateError('cancelled'));
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Stable release metadata requires trusted URL, numeric build, size and SHA256',
    () {
      final valid = AppRelease.fromGithub(metadata());
      expect(valid.buildNumber, 3);
      expect(valid.sha256, release().sha256);
      for (final tag in ['v0.3.0', 'v0.3.0+0', 'v0.3.0-beta+3']) {
        expect(
          () => AppRelease.fromGithub(metadata()..['tag_name'] = tag),
          throwsFormatException,
        );
      }
      for (final field in ['draft', 'prerelease']) {
        expect(
          () => AppRelease.fromGithub(metadata()..[field] = true),
          throwsFormatException,
        );
      }
      for (final url in [
        'http://github.com/ahmedroou/lamma-game/releases/download/v0.3.0+3/lamma-android.apk',
        'https://evil.example/app.apk',
        'https://github.com/another/repo/releases/download/v0.3.0+3/lamma-android.apk',
      ]) {
        final data = metadata();
        (data['assets'] as List).single['browser_download_url'] = url;
        expect(() => AppRelease.fromGithub(data), throwsFormatException);
      }
      final missing = metadata();
      (missing['assets'] as List).single.remove('digest');
      expect(() => AppRelease.fromGithub(missing), throwsFormatException);
    },
  );
  test(
    'Network failures are not reported as current and 404 means no release',
    () async {
      final service = GithubReleaseService(
        clientFactory: () =>
            MockClient((_) async => http.Response('rate limit', 403)),
      );
      final vm = AppUpdateViewModel(
        platform: FakePlatform(),
        store: FakeStore(),
        fetchRelease: service.latest,
      );
      addTearDown(vm.dispose);
      await vm.check();
      expect(vm.status, UpdateStatus.error);
      expect(vm.release, isNull);
      final empty = GithubReleaseService(
        clientFactory: () => MockClient((_) async => http.Response('', 404)),
      );
      expect(await empty.latest(), isNull);
    },
  );
  test(
    'Numeric build comparison handles same app version and downgrade',
    () async {
      for (final build in [1, 2, 3]) {
        final vm = AppUpdateViewModel(
          platform: FakePlatform(),
          store: FakeStore(),
          fetchRelease: () async => release(build: build),
        );
        addTearDown(vm.dispose);
        await vm.check();
        expect(
          vm.status,
          build > 2 ? UpdateStatus.available : UpdateStatus.current,
        );
      }
    },
  );
  test(
    'Permission round trip retains download and saves before installer without claiming success',
    () async {
      final platform = FakePlatform()..permission = false;
      var saved = 0;
      final vm = AppUpdateViewModel(
        platform: platform,
        store: FakeStore(),
        fetchRelease: () async => release(),
        beforeInstall: () async {
          saved++;
        },
      );
      addTearDown(vm.dispose);
      await vm.check();
      await vm.download();
      expect(vm.status, UpdateStatus.ready);
      await vm.install();
      expect(vm.status, UpdateStatus.permission);
      expect(platform.installations, 0);
      expect(saved, 0);
      await vm.openPermission();
      expect(platform.permissionRequests, 1);
      platform.permission = true;
      await vm.install();
      expect(platform.installations, 1);
      expect(saved, 1);
      expect(vm.status, UpdateStatus.installerOpened);
    },
  );
  test('Corrupt file or save failure cannot launch installation', () async {
    final platform = FakePlatform(), store = FakeStore();
    final vm = AppUpdateViewModel(
      platform: platform,
      store: store,
      fetchRelease: () async => release(),
      beforeInstall: () async => throw StateError('disk'),
    );
    addTearDown(vm.dispose);
    await vm.check();
    await vm.download();
    store.failVerify = true;
    await vm.install();
    expect(platform.installations, 0);
    expect(vm.status, UpdateStatus.error);
    store.failVerify = false;
    await vm.install();
    expect(platform.installations, 0);
  });
  test(
    'Cancellation returns available, prevents installer and permits retry',
    () async {
      final store = FakeStore()..pending = Completer<String>();
      final vm = AppUpdateViewModel(
        platform: FakePlatform(),
        store: store,
        fetchRelease: () async => release(),
      );
      addTearDown(vm.dispose);
      await vm.check();
      final download = vm.download();
      vm.cancelDownload();
      await download;
      expect(store.cancelled, isTrue);
      expect(vm.status, UpdateStatus.available);
      expect(vm.downloadedPath, isNull);
      store.pending = null;
      await vm.download();
      expect(vm.status, UpdateStatus.ready);
    },
  );
  test('Non-Android cannot download or launch installer', () async {
    final platform = FakePlatform()..supported = false;
    final vm = AppUpdateViewModel(
      platform: platform,
      store: FakeStore(),
      fetchRelease: () async => release(),
    );
    addTearDown(vm.dispose);
    await vm.check();
    await vm.download();
    await vm.install();
    expect(vm.downloadedPath, isNull);
    expect(platform.installations, 0);
  });
  test(
    'APK is streamed to private cache and tampering fails subsequent validation',
    () async {
      final dir = await Directory.systemTemp.createTemp('lamma-update-test-');
      addTearDown(() => dir.delete(recursive: true));
      final store = LocalApkStore(
        cacheDirectory: () async => dir,
        clientFactory: () =>
            MockClient((_) async => http.Response.bytes(bytes, 200)),
      );
      var progress = 0;
      final path = await store.download(release(), (n) => progress = n);
      expect(progress, bytes.length);
      expect(await File(path).readAsBytes(), bytes);
      await store.verify(path, release());
      await File(path).writeAsBytes(List.filled(bytes.length, 0));
      expect(() => store.verify(path, release()), throwsFormatException);
    },
  );
  test(
    'Incorrect checksum, short body and failed requests remove partial files',
    () async {
      final dir = await Directory.systemTemp.createTemp('lamma-update-test-');
      addTearDown(() => dir.delete(recursive: true));
      for (final kind in ['hash', 'short', 'status']) {
        final store = LocalApkStore(
          cacheDirectory: () async => dir,
          clientFactory: () => MockClient(
            (_) async => http.Response.bytes(
              kind == 'short' ? bytes.take(3).toList() : bytes,
              kind == 'status' ? 500 : 200,
            ),
          ),
        );
        await expectLater(
          store.download(
            release(digest: kind == 'hash' ? '0' * 64 : null),
            (_) {},
          ),
          throwsFormatException,
        );
        expect(
          await File('${dir.path}/app_updates/update.apk.part').exists(),
          isFalse,
        );
        expect(
          await File('${dir.path}/app_updates/update.apk').exists(),
          isFalse,
        );
      }
    },
  );
  test(
    'In-flight abort cleans partial download without waiting for a full APK',
    () async {
      final dir = await Directory.systemTemp.createTemp('lamma-update-test-');
      addTearDown(() => dir.delete(recursive: true));
      final begun = Completer<void>();
      late LocalApkStore store;
      store = LocalApkStore(
        cacheDirectory: () async => dir,
        clientFactory: () => MockClient.streaming((request, _) async {
          begun.complete();
          await (request as http.AbortableRequest).abortTrigger;
          throw http.RequestAbortedException();
        }),
      );
      final future = store.download(release(), (_) {});
      await begun.future;
      store.cancel();
      await expectLater(future, throwsA(isA<http.RequestAbortedException>()));
      expect(
        await File('${dir.path}/app_updates/update.apk.part').exists(),
        isFalse,
      );
    },
  );
}
