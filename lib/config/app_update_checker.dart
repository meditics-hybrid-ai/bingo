import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

const String defaultAppConfigUrl =
    'https://raw.githubusercontent.com/meditics-hybrid-ai/bingo/main/app_config.json';

abstract interface class AppUpdateChecker {
  Future<AppUpdateStatus> checkForUpdate();
}

class RemoteAppUpdateChecker implements AppUpdateChecker {
  const RemoteAppUpdateChecker({
    this.configUrl = defaultAppConfigUrl,
    http.Client? client,
  }) : _client = client;

  final String configUrl;
  final http.Client? _client;

  @override
  Future<AppUpdateStatus> checkForUpdate() async {
    final client = _client ?? http.Client();
    final shouldCloseClient = _client == null;

    try {
      final installedVersion = (await PackageInfo.fromPlatform()).version;
      final response = await client
          .get(Uri.parse(configUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AppUpdateStatus.upToDate();
      }

      final config = AppConfig.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      return AppUpdateStatus.fromVersions(
        installedVersion: installedVersion,
        config: config,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('App update check skipped: $error');
      }
      return AppUpdateStatus.upToDate();
    } finally {
      if (shouldCloseClient) {
        client.close();
      }
    }
  }
}

class AppConfig {
  const AppConfig({
    required this.latestVersion,
    required this.minimumSupportedVersion,
    required this.updateRequired,
    required this.androidUpdateUrl,
    required this.iosUpdateUrl,
    required this.updateUrl,
    required this.message,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final latestVersion = json['latest_version'] as String?;

    return AppConfig(
      latestVersion: latestVersion ?? '0.0.0',
      minimumSupportedVersion:
          json['minimum_supported_version'] as String? ??
          latestVersion ??
          '0.0.0',
      updateRequired: json['update_required'] as bool? ?? false,
      androidUpdateUrl: json['android_update_url'] as String?,
      iosUpdateUrl: json['ios_update_url'] as String?,
      updateUrl: json['update_url'] as String?,
      message:
          json['message'] as String? ??
          'A newer version of Meditics BINGO is available.',
    );
  }

  final String latestVersion;
  final String minimumSupportedVersion;
  final bool updateRequired;
  final String? androidUpdateUrl;
  final String? iosUpdateUrl;
  final String? updateUrl;
  final String message;

  String? updateUrlForPlatform(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.android => androidUpdateUrl ?? updateUrl,
      TargetPlatform.iOS => iosUpdateUrl ?? updateUrl,
      _ => updateUrl,
    };
  }
}

class AppUpdateStatus {
  const AppUpdateStatus({
    required this.needsUpdate,
    required this.isRequired,
    required this.latestVersion,
    required this.message,
    this.updateUrl,
  });

  factory AppUpdateStatus.upToDate() {
    return const AppUpdateStatus(
      needsUpdate: false,
      isRequired: false,
      latestVersion: null,
      message: '',
    );
  }

  factory AppUpdateStatus.fromVersions({
    required String installedVersion,
    required AppConfig config,
    TargetPlatform? platform,
  }) {
    final selectedPlatform = platform ?? defaultTargetPlatform;
    final isBelowMinimum = compareVersions(
      installedVersion,
      config.minimumSupportedVersion,
    ).isNegative;
    final isBelowLatest = compareVersions(
      installedVersion,
      config.latestVersion,
    ).isNegative;
    final needsUpdate = isBelowMinimum || isBelowLatest;

    return AppUpdateStatus(
      needsUpdate: needsUpdate,
      isRequired: isBelowMinimum || (config.updateRequired && isBelowLatest),
      latestVersion: config.latestVersion,
      updateUrl: config.updateUrlForPlatform(selectedPlatform),
      message: config.message,
    );
  }

  final bool needsUpdate;
  final bool isRequired;
  final String? latestVersion;
  final String? updateUrl;
  final String message;
}

@visibleForTesting
int compareVersions(String current, String remote) {
  final currentParts = _versionParts(current);
  final remoteParts = _versionParts(remote);
  final maxLength = currentParts.length > remoteParts.length
      ? currentParts.length
      : remoteParts.length;

  for (var index = 0; index < maxLength; index++) {
    final currentPart = index < currentParts.length ? currentParts[index] : 0;
    final remotePart = index < remoteParts.length ? remoteParts[index] : 0;

    if (currentPart != remotePart) {
      return currentPart.compareTo(remotePart);
    }
  }

  return 0;
}

List<int> _versionParts(String version) {
  final versionName = version
      .split('+')
      .first
      .trim()
      .replaceFirst(RegExp(r'^[vV]\.?'), '');

  return versionName
      .split('.')
      .map((part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
      .toList(growable: false);
}
