/// Singleton service to manage session invalidation state
/// Used to communicate between API interceptor and UI layer
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  bool _sessionInvalidated = false;

  /// Check if current session has been invalidated (logged out from another device)
  bool get isSessionInvalidated => _sessionInvalidated;

  /// Mark session as invalidated (called by API interceptor on 401)
  void markSessionInvalidated() {
    _sessionInvalidated = true;
  }

  /// Clear the invalidation flag (called after user acknowledges logout)
  void clearSessionInvalidation() {
    _sessionInvalidated = false;
  }
}
