import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/services/user_service.dart';
import 'package:pgme/core/services/storage_service.dart';

/// Top-level background handler (MUST be top-level, not a class method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background FCM message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  bool _initialized = false;

  /// Initialize Firebase Messaging and set up handlers.
  /// Call this from main.dart AFTER Firebase.initializeApp()
  Future<void> initialize() async {
    if (_initialized) return;

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS requires explicit permission, Android auto-grants)
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('FCM Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('User denied push notification permission');
      return;
    }

    // Set up foreground notification presentation (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen for notification taps (when app is in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a terminated state via notification tap
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    _initialized = true;
    debugPrint('Push notification service initialized');
  }

  /// Get FCM token and send to backend.
  /// Call this AFTER successful login.
  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: ${token.substring(0, 20)}...');
        await _userService.updateFCMToken(token);
        debugPrint('FCM token registered with backend');
      }
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }

  /// Subscribe to a subject topic
  Future<void> subscribeToSubject(String subjectId) async {
    try {
      final topic = 'subject_$subjectId';
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Failed to subscribe to subject topic: $e');
    }
  }

  /// Unsubscribe from a subject topic
  Future<void> unsubscribeFromSubject(String subjectId) async {
    try {
      final topic = 'subject_$subjectId';
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Failed to unsubscribe from subject topic: $e');
    }
  }

  /// Handle foreground message (app is open and in focus)
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground FCM: ${message.notification?.title}');
    // Foreground messages are shown as system notifications via
    // setForegroundNotificationPresentationOptions (iOS) and
    // the notification channel (Android).
  }

  /// Handle notification tap (app launched from background/terminated)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tap: ${message.data}');
    final data = message.data;
    final clickUrl = data['click_url'];

    if (clickUrl != null && clickUrl.toString().isNotEmpty) {
      _pendingNavigation = clickUrl.toString();
    }
  }

  /// Token refresh handler
  Future<void> _onTokenRefresh(String newToken) async {
    debugPrint('FCM token refreshed');
    try {
      final isAuth = await _storageService.isAuthenticated();
      if (isAuth) {
        await _userService.updateFCMToken(newToken);
        debugPrint('Refreshed FCM token registered with backend');
      }
    } catch (e) {
      debugPrint('Failed to register refreshed FCM token: $e');
    }
  }

  // Pending deep link navigation (consumed by the router/navigator)
  String? _pendingNavigation;

  /// Consume pending navigation (call from your app shell/router guard)
  String? consumePendingNavigation() {
    final nav = _pendingNavigation;
    _pendingNavigation = null;
    return nav;
  }

  /// Cleanup on logout
  Future<void> cleanup() async {
    // Don't delete the FCM token itself — the backend clears it on logout
    _initialized = false;
  }
}
