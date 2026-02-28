import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Requests extra background execution time on iOS so downloads
/// can continue briefly after the user switches away.
/// On Android this is a no-op (Android already allows background networking).
class BackgroundTaskService {
  static final BackgroundTaskService _instance = BackgroundTaskService._internal();
  factory BackgroundTaskService() => _instance;
  BackgroundTaskService._internal();

  static const _channel = MethodChannel('com.pgme.app/background_download');
  bool _active = false;

  /// Request background execution time (iOS gives ~30s).
  /// Safe to call multiple times — only the first call takes effect.
  Future<void> beginBackgroundTask() async {
    if (!Platform.isIOS || _active) return;
    try {
      await _channel.invokeMethod('beginBackgroundTask');
      _active = true;
      debugPrint('BackgroundTaskService: background task started');
    } catch (e) {
      debugPrint('BackgroundTaskService: failed to begin - $e');
    }
  }

  /// End the background task (call when all downloads finish or fail).
  Future<void> endBackgroundTask() async {
    if (!Platform.isIOS || !_active) return;
    try {
      await _channel.invokeMethod('endBackgroundTask');
      _active = false;
      debugPrint('BackgroundTaskService: background task ended');
    } catch (e) {
      debugPrint('BackgroundTaskService: failed to end - $e');
    }
  }

  bool get isActive => _active;
}
