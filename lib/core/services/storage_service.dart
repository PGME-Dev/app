import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pgme/core/constants/api_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _cachedDeviceId;

  // Token Management
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(
      key: ApiConstants.accessTokenKey,
      value: token,
    );
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: ApiConstants.accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: ApiConstants.refreshTokenKey,
      value: token,
    );
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: ApiConstants.refreshTokenKey);
  }

  Future<void> saveSessionId(String sessionId) async {
    await _secureStorage.write(
      key: ApiConstants.sessionIdKey,
      value: sessionId,
    );
  }

  Future<String?> getSessionId() async {
    return await _secureStorage.read(key: ApiConstants.sessionIdKey);
  }

  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(
      key: ApiConstants.userIdKey,
      value: userId,
    );
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: ApiConstants.userIdKey);
  }

  Future<void> saveOnboardingStatus(bool completed) async {
    await _secureStorage.write(
      key: ApiConstants.onboardingCompletedKey,
      value: completed.toString(),
    );
  }

  Future<bool> getOnboardingStatus() async {
    final value = await _secureStorage.read(
      key: ApiConstants.onboardingCompletedKey,
    );
    return value == 'true';
  }

  // Intro screens seen status (informational onboarding carousel)
  Future<void> saveIntroSeen(bool seen) async {
    await _secureStorage.write(
      key: ApiConstants.introSeenKey,
      value: seen.toString(),
    );
  }

  Future<bool> getIntroSeen() async {
    final value = await _secureStorage.read(
      key: ApiConstants.introSeenKey,
    );
    return value == 'true';
  }

  // Save all tokens at once
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required String sessionId,
    required String userId,
    required bool onboardingCompleted,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveSessionId(sessionId),
      saveUserId(userId),
      saveOnboardingStatus(onboardingCompleted),
    ]);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all stored data (logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  // Clear specific keys
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: ApiConstants.accessTokenKey),
      _secureStorage.delete(key: ApiConstants.refreshTokenKey),
      _secureStorage.delete(key: ApiConstants.sessionIdKey),
    ]);
  }

  /// Stable per-install device identifier used for session tracking.
  ///
  /// Deliberately NOT derived from OS device info: Android's
  /// `androidInfo.id` is `Build.ID` (the firmware build fingerprint), which
  /// changes on every OS/security update, and iOS's `identifierForVendor`
  /// can be null in edge cases. Either drifting/falling back to a shared
  /// literal caused the backend to stop recognizing the device and force a
  /// "session terminated from another device" logout on a single, unshared
  /// device. Stored in SharedPreferences (not secure storage) so it is not
  /// wiped by clearAll() on logout/session-termination and stays stable for
  /// the lifetime of this install.
  Future<String> getOrCreateDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(ApiConstants.deviceIdKey);

    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _generateUuidV4();
      await prefs.setString(ApiConstants.deviceIdKey, deviceId);
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }

  @visibleForTesting
  void resetDeviceIdCacheForTesting() {
    _cachedDeviceId = null;
  }

  String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant 10xx
    String hex(int start, int end) => bytes
        .sublist(start, end)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }
}
