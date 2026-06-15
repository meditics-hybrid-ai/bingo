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
        updateUrl: null,
        message: 'Please update.',
      ),
    );

    expect(status.needsUpdate, isTrue);
    expect(status.isRequired, isFalse);
  });
}
