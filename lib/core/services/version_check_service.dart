import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pgme/core/services/app_settings_service.dart';

class VersionCheckResult {
  final bool updateRequired;
  final String? storeUrl;
  final String currentVersion;
  final String? minVersion;

  const VersionCheckResult({
    required this.updateRequired,
    this.storeUrl,
    required this.currentVersion,
    this.minVersion,
  });
}

class VersionCheckService {
  static final VersionCheckService _instance = VersionCheckService._internal();
  factory VersionCheckService() => _instance;
  VersionCheckService._internal();

  /// Check if the current app version meets the minimum required version.
  /// Returns a [VersionCheckResult] indicating whether an update is required.
  ///
  /// If settings cannot be fetched or the relevant keys are missing,
  /// the user is NOT blocked (fail-open).
  Future<VersionCheckResult> checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "1.6.5"

      final settings = await AppSettingsService().getSettings(forceRefresh: true);

      final bool isAndroid = Platform.isAndroid;

      final String forceUpdateKey =
          isAndroid ? 'android_force_update' : 'ios_force_update';
      final String minVersionKey =
          isAndroid ? 'android_min_version' : 'ios_min_version';
      final String storeUrlKey =
          isAndroid ? 'android_store_url' : 'ios_store_url';

      final forceUpdate = settings[forceUpdateKey];
      final minVersion = settings[minVersionKey]?.toString();
      final storeUrl = settings[storeUrlKey]?.toString();

      // Force update must be enabled AND a minimum version must be set
      final isForceEnabled =
          forceUpdate == true || forceUpdate == 'true';

      if (!isForceEnabled || minVersion == null || minVersion.isEmpty) {
        return VersionCheckResult(
          updateRequired: false,
          currentVersion: currentVersion,
        );
      }

      final bool needsUpdate = _isVersionLower(currentVersion, minVersion);

      return VersionCheckResult(
        updateRequired: needsUpdate,
        storeUrl: storeUrl,
        currentVersion: currentVersion,
        minVersion: minVersion,
      );
    } catch (e) {
      debugPrint('VersionCheckService: Version check failed: $e');
      // Fail-open: don't block the user if we can't check
      return const VersionCheckResult(
        updateRequired: false,
        currentVersion: 'unknown',
      );
    }
  }

  /// Compare two semver version strings.
  /// Returns true if [current] is strictly lower than [minimum].
  /// Supports versions like "1.6.5", "2.0", "1.0.0".
  bool _isVersionLower(String current, String minimum) {
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final minimumParts = minimum.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad shorter list with zeros
    final maxLen = currentParts.length > minimumParts.length
        ? currentParts.length
        : minimumParts.length;

    while (currentParts.length < maxLen) {
      currentParts.add(0);
    }
    while (minimumParts.length < maxLen) {
      minimumParts.add(0);
    }

    for (int i = 0; i < maxLen; i++) {
      if (currentParts[i] < minimumParts[i]) return true;
      if (currentParts[i] > minimumParts[i]) return false;
    }

    return false; // Versions are equal — no update needed
  }
}
