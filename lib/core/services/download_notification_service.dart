import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DownloadNotificationService {
  static final DownloadNotificationService _instance =
      DownloadNotificationService._internal();
  factory DownloadNotificationService() => _instance;
  DownloadNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'pgme_downloads';
  static const String _channelName = 'Downloads';
  static const String _channelDescription = 'Video download progress';

  bool _available = true; // false if native plugin not registered

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notifications.initialize(initSettings);
      _initialized = true;
    } catch (e) {
      // Plugin not available (e.g. hot reload without full restart)
      _available = false;
      _initialized = true; // Don't retry, just degrade gracefully
      debugPrint('DownloadNotification: initialize failed (plugin not available) - $e');
    }
  }

  /// Notification ID from videoId (stable per video)
  int _notifId(String videoId) => videoId.hashCode.abs() % 0x7FFFFFFF;

  /// Show/update progress notification
  Future<void> showProgress({
    required String videoId,
    required String title,
    required double progress,
  }) async {
    try {
      if (!_initialized) await initialize();
      if (!_available) return;

      final pct = (progress * 100).round();
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        showProgress: true,
        maxProgress: 100,
        progress: pct,
        onlyAlertOnce: true,
        autoCancel: false,
        playSound: false,
        enableVibration: false,
      );

      await _notifications.show(
        _notifId(videoId),
        title,
        progress <= 0 ? 'Preparing download...' : 'Downloading... $pct%',
        NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      debugPrint('DownloadNotification: showProgress error - $e');
    }
  }

  /// Show download complete notification
  Future<void> showComplete({
    required String videoId,
    required String title,
  }) async {
    try {
      if (!_initialized) await initialize();
      if (!_available) return;

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        autoCancel: true,
        ongoing: false,
      );

      await _notifications.show(
        _notifId(videoId),
        title,
        'Download complete',
        const NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      debugPrint('DownloadNotification: showComplete error - $e');
    }
  }

  /// Show download failed notification
  Future<void> showFailed({
    required String videoId,
    required String title,
  }) async {
    try {
      if (!_initialized) await initialize();
      if (!_available) return;

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        autoCancel: true,
        ongoing: false,
      );

      await _notifications.show(
        _notifId(videoId),
        title,
        'Download failed. Tap the video to retry.',
        const NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      debugPrint('DownloadNotification: showFailed error - $e');
    }
  }

  /// Cancel notification for a video
  Future<void> cancel(String videoId) async {
    try {
      if (!_available) return;
      await _notifications.cancel(_notifId(videoId));
    } catch (e) {
      debugPrint('DownloadNotification: cancel error - $e');
    }
  }
}
