import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

final class InstalledApp {
  const InstalledApp(this.version, this.buildNumber);
  final String version;
  final int buildNumber;
}

abstract interface class UpdatePlatform {
  bool get supported;
  Future<InstalledApp> installedApp();
  Future<bool> canInstall();
  Future<void> requestInstallPermission();
  Future<void> install(String path, int expectedBuild);
}

final class AndroidUpdatePlatform implements UpdatePlatform {
  static const channel = MethodChannel('com.lamma.lamma/updates');
  @override
  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  @override
  Future<InstalledApp> installedApp() async {
    if (!supported) return const InstalledApp('0.2.0', 2);
    final data = await channel.invokeMapMethod<String, dynamic>('appInfo');
    return InstalledApp(
      data!['version'] as String,
      (data['buildNumber'] as num).toInt(),
    );
  }

  @override
  Future<bool> canInstall() async =>
      await channel.invokeMethod<bool>('canInstall') ?? false;
  @override
  Future<void> requestInstallPermission() =>
      channel.invokeMethod<void>('requestInstallPermission');
  @override
  Future<void> install(String path, int expectedBuild) =>
      channel.invokeMethod<void>('install', {
        'path': path,
        'buildNumber': expectedBuild,
      });
}
