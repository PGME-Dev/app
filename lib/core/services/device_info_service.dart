import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();

  static const String _deviceIdKey = 'persistent_device_id';
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();

  String? _cachedDeviceId;
  String? _cachedDeviceName;
  String? _cachedDeviceType;

  /// Get or generate persistent device ID
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null || deviceId.isEmpty) {
      // Generate new UUID for first launch
      deviceId = _uuid.v4();
      await prefs.setString(_deviceIdKey, deviceId);
      debugPrint('Generated new device ID: $deviceId');
    } else {
      debugPrint('Retrieved existing device ID: $deviceId');
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }

  /// Get device name
  Future<String> getDeviceName() async {
    if (_cachedDeviceName != null) {
      return _cachedDeviceName!;
    }

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _cachedDeviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _cachedDeviceName = '${iosInfo.name} ${iosInfo.model}';
      } else {
        _cachedDeviceName = 'Unknown Device';
      }
    } catch (e) {
      debugPrint('Error getting device name: $e');
      _cachedDeviceName = 'Unknown Device';
    }

    return _cachedDeviceName!;
  }

  /// Get device type
  Future<String> getDeviceType() async {
    if (_cachedDeviceType != null) {
      return _cachedDeviceType!;
    }

    if (Platform.isAndroid) {
      _cachedDeviceType = 'Android';
    } else if (Platform.isIOS) {
      _cachedDeviceType = 'iOS';
    } else if (kIsWeb) {
      _cachedDeviceType = 'Web';
    } else {
      _cachedDeviceType = 'Unknown';
    }

    return _cachedDeviceType!;
  }

  /// Get all device information at once
  Future<Map<String, String>> getDeviceInfo() async {
    final deviceId = await getDeviceId();
    final deviceName = await getDeviceName();
    final deviceType = await getDeviceType();

    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'device_type': deviceType,
    };
  }

  /// Get FCM token (optional - implement when Firebase is configured)
  Future<String?> getFcmToken() async {
    // TODO: Implement when Firebase is configured
    // final fcmToken = await FirebaseMessaging.instance.getToken();
    // return fcmToken;
    return null;
  }
}
