import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditics_bingo/config/app_update_checker.dart';

void main() {
  test('compares dotted versions numerically', () {
    expect(compareVersions('1.0.0', '1.0.1'), isNegative);
    expect(compareVersions('1.0.10', '1.0.2'), isPositive);
    expect(compareVersions('1.2.0+4', '1.2.0'), isZero);
  });

  test('requires update below minimum supported version', () {
    final status = AppUpdateStatus.fromVersions(
      installedVersion: '1.0.0',
      config: const AppConfig(
        latestVersion: '1.2.0',
        minimumSupportedVersion: '1.1.0',
        updateRequired: false,
        androidUpdateUrl: null,
        iosUpdateUrl: null,
        updateUrl: null,
        message: 'Please update.',
      ),
    );

    expect(status.needsUpdate, isTrue);
    expect(status.isRequired, isTrue);
  });

  test('marks newer latest version as optional unless required by config', () {
    final status = AppUpdateStatus.fromVersions(
      installedVersion: '1.0.0',
      config: const AppConfig(
        latestVersion: '1.1.0',
        minimumSupportedVersion: '1.0.0',
        updateRequired: false,
        androidUpdateUrl: null,
        iosUpdateUrl: null,
        updateUrl: null,
        message: 'Please update.',
      ),
    );

    expect(status.needsUpdate, isTrue);
    expect(status.isRequired, isFalse);
  });

  test('uses platform-specific update URLs when available', () {
    const config = AppConfig(
      latestVersion: '1.1.0',
      minimumSupportedVersion: '1.0.0',
      updateRequired: false,
      androidUpdateUrl: 'https://play.google.com/store/apps/details?id=test',
      iosUpdateUrl: 'https://apps.apple.com/app/test/id123',
      updateUrl: 'https://example.com/fallback',
      message: 'Please update.',
    );

    final androidStatus = AppUpdateStatus.fromVersions(
      installedVersion: '1.0.0',
      config: config,
      platform: TargetPlatform.android,
    );
    final iosStatus = AppUpdateStatus.fromVersions(
      installedVersion: '1.0.0',
      config: config,
      platform: TargetPlatform.iOS,
    );

    expect(
      androidStatus.updateUrl,
      'https://play.google.com/store/apps/details?id=test',
    );
    expect(iosStatus.updateUrl, 'https://apps.apple.com/app/test/id123');
  });
}
