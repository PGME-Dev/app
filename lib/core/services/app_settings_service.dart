import 'package:flutter/foundation.dart';
import 'package:pgme/core/services/api_service.dart';
import 'package:pgme/core/constants/api_constants.dart';

class AppSettingsService {
  static final AppSettingsService _instance = AppSettingsService._internal();
  factory AppSettingsService() => _instance;
  AppSettingsService._internal();

  Map<String, dynamic>? _cachedSettings;

  /// Fetch all app settings from the public endpoint.
  /// Results are cached in memory; use [forceRefresh] to bypass cache.
  Future<Map<String, dynamic>> getSettings({bool forceRefresh = false}) async {
    if (_cachedSettings != null && !forceRefresh) {
      return _cachedSettings!;
    }

    try {
      final response = await ApiService().dio.get(ApiConstants.appSettings);
      final data = response.data;
      if (data != null && data['data'] != null && data['data']['settings'] != null) {
        _cachedSettings = Map<String, dynamic>.from(data['data']['settings']);
      } else {
        _cachedSettings = {};
      }
    } catch (e) {
      debugPrint('AppSettingsService: Failed to fetch settings: $e');
      _cachedSettings ??= {};
    }

    return _cachedSettings!;
  }

  /// Get a specific setting value as a String, or null if not found.
  String? getString(String key) {
    final value = _cachedSettings?[key];
    if (value == null) return null;
    return value.toString();
  }

  /// Clear the cached settings.
  void clearCache() {
    _cachedSettings = null;
  }
}
