import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pgme/core/services/user_service.dart';
import 'package:pgme/core/services/storage_service.dart';

/// Local notifications plugin (shared between foreground + background)
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

/// Android notification channel for push messages
const AndroidNotificationChannel _pushChannel = AndroidNotificationChannel(
  'pgme_push',
  'Push Notifications',
  description: 'Notifications from PGME',
  importance: Importance.high,
);

/// Initialize local notifications (called from both foreground and background)
Future<void> _initLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await _localNotifications.initialize(initSettings);

  // Create Android notification channel
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_pushChannel);
}

/// Show a local notification from an FCM message
Future<void> _showLocalNotification(RemoteMessage message) async {
  final title = message.notification?.title ??
      message.data['title'] as String? ??
      '';
  final body = message.notification?.body ??
      message.data['body'] as String? ??
      message.data['message'] as String? ??
      '';

  if (title.isEmpty && body.isEmpty) return;

  const androidDetails = AndroidNotificationDetails(
    'pgme_push',
    'Push Notifications',
    channelDescription: 'Notifications from PGME',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const darwinDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const details = NotificationDetails(
    android: androidDetails,
    iOS: darwinDetails,
  );

  final id = message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;

  await _localNotifications.show(id, title, body, details);
}

/// Top-level background handler (MUST be top-level, not a class method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background FCM message: ${message.messageId}');

  // Show local notification for data-only messages on both platforms.
  // Messages WITH a notification payload are shown automatically by the OS
  // in background, but data-only messages need manual handling.
  if (message.notification == null) {
    try {
      await _initLocalNotifications();
      await _showLocalNotification(message);
    } catch (e) {
      debugPrint('Background local notification error: $e');
    }
  }
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
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _tapSub;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Initialize Firebase Messaging and set up handlers.
  /// Call this from main.dart AFTER Firebase.initializeApp()
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize local notifications for showing FCM messages
    await _initLocalNotifications();

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

    // ignore: avoid_print
    print('===== FCM SETUP =====');
    // ignore: avoid_print
    print('FCM Permission: ${settings.authorizationStatus}');

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

    // Check APNs token (critical for iOS)
    final apnsToken = await _messaging.getAPNSToken();
    // ignore: avoid_print
    print('APNs Token: ${apnsToken != null ? "RECEIVED OK" : "NULL - notifications will NOT work!"}');

    // Listen for foreground messages
    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen for notification taps (when app is in background/terminated)
    _tapSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a terminated state via notification tap
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Listen for token refresh
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_onTokenRefresh);

    _initialized = true;
    debugPrint('Push notification service initialized');
  }

  /// Get FCM token and send to backend.
  /// Call this AFTER successful login.
  Future<void> registerToken() async {
    try {
      // On iOS, FCM requires the APNs token before it can return an FCM token.
      // There is a race condition on first launch where getToken() returns null
      // because the APNs token hasn't been exchanged yet. Retry up to 5 times.
      if (Platform.isIOS) {
        String? apnsToken;
        for (int i = 0; i < 5; i++) {
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
        if (apnsToken == null) {
          debugPrint('APNs token unavailable — FCM token registration deferred to onTokenRefresh');
          return;
        }
        debugPrint('APNs token confirmed, requesting FCM token');
      }

      final token = await _messaging.getToken();
      if (token != null) {
        // ignore: avoid_print
        print('===== FCM TOKEN (copy this for testing) =====');
        // ignore: avoid_print
        print(token);
        // ignore: avoid_print
        print('===== END FCM TOKEN =====');
        await _userService.updateFCMToken(token);
        debugPrint('FCM token registered with backend');
      } else {
        debugPrint('FCM token was null — will retry via onTokenRefresh');
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
    debugPrint('Foreground FCM: ${message.notification?.title ?? message.data['title']}');

    if (Platform.isIOS) {
      // On iOS, setForegroundNotificationPresentationOptions auto-shows
      // notification-payload messages. Only handle data-only messages.
      if (message.notification == null) {
        _showLocalNotification(message);
      }
    } else {
      // On Android, foreground messages are NEVER auto-shown by the OS.
      // We must always show a local notification manually.
      _showLocalNotification(message);
    }
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
    // Cancel stream subscriptions to prevent duplicate handlers on re-login
    await _foregroundSub?.cancel();
    await _tapSub?.cancel();
    await _tokenRefreshSub?.cancel();
    _foregroundSub = null;
    _tapSub = null;
    _tokenRefreshSub = null;
    // Don't delete the FCM token itself — the backend clears it on logout
    _initialized = false;
  }
}
