class ApiConstants {
  // Base URL - Use deployed backend on Render
  static const String baseUrl = 'https://pgme-backend.onrender.com/api/v1';

  // Timeout
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // MSG91 Configuration
  static const String msg91WidgetId = '3662626a546d363538363637';
  static const String msg91AuthToken = '476937TtIKe4opN3690e3faeP1';

  // Authentication Endpoints
  static const String verifyWidget = '/auth/verify-widget';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String activeSessions = '/auth/active-sessions';
  static String deviceSession(String sessionId) => '/auth/device-session/$sessionId';

  // User Endpoints (Onboarding accessible)
  static const String profile = '/users/profile';
  static const String uploadPhoto = '/users/upload-photo';
  static const String subjectSelection = '/users/subject-selection';
  static const String onboardingComplete = '/users/onboarding-complete';

  // User Endpoints (Protected - requires onboarding)
  static const String preferences = '/users/preferences';
  static const String fcmToken = '/users/fcm-token';

  // Subject Endpoints
  static const String subjects = '/subjects';
  static String subject(String subjectId) => '/subjects/$subjectId';

  // Dashboard Endpoints (Fixed to match backend routes)
  static const String nextUpcomingSession = '/live-sessions/next-upcoming';
  static const String liveSessions = '/live-sessions';
  static String liveSessionDetails(String sessionId) => '/live-sessions/$sessionId';
  static String sessionAccessStatus(String sessionId) => '/live-sessions/$sessionId/access-status';
  static String sessionCreateOrder(String sessionId) => '/live-sessions/$sessionId/create-order';
  static String sessionVerifyPayment(String sessionId) => '/live-sessions/$sessionId/verify-payment';
  static String sessionTestPurchase(String sessionId) => '/live-sessions/$sessionId/test-purchase';
  static String sessionJoin(String sessionId) => '/live-sessions/$sessionId/join';
  static const String userSessionPurchases = '/users/session-purchases';
  static const String subjectSelections = '/users/subject-selections';
  static const String packages = '/packages';
  static String packageSeries(String packageId) => '/packages/$packageId/series';
  static String packageTestPurchase(String packageId) => '/packages/$packageId/test-purchase';
  static const String lastWatched = '/users/progress/last-watched';
  static const String faculty = '/faculty';
  static String facultyDetails(String facultyId) => '/faculty/$facultyId';

  // Library Endpoints
  static const String userLibrary = '/users/library';
  static String libraryItem(String libraryId) => '/users/library/$libraryId';
  static String libraryBookmark(String libraryId) => '/users/library/$libraryId/bookmark';

  // Purchase Endpoints
  static const String userPurchases = '/users/purchases';
  static const String purchases = '/users/purchases';
  static const String subscriptionStatus = '/users/purchases/subscription-status';
  static String purchaseDetails(String purchaseId) => '/users/purchases/$purchaseId';

  // Series & Progress Endpoints
  static const String series = '/series';
  static const String progress = '/users/progress';
  static const String updateProgress = '/users/progress';

  // Library Endpoints (additional)
  static const String library = '/users/library';
  static const String addToLibrary = '/users/library';
  static String removeFromLibrary(String libraryId) => '/users/library/$libraryId';

  // Book Endpoints
  static const String books = '/books';
  static const String bookCategories = '/books/categories';
  static const String searchBooks = '/books/search';
  static String bookDetails(String bookId) => '/books/$bookId';
  static String bookStock(String bookId) => '/books/$bookId/stock';

  // Book Order Endpoints
  static const String bookOrders = '/book-orders';
  static const String createBookOrder = '/book-orders/create-order';
  static const String verifyBookPayment = '/book-orders/verify-payment';
  static const String testBookOrder = '/book-orders/test-order';
  static String bookOrderDetails(String orderId) => '/book-orders/$orderId';
  static String cancelBookOrder(String orderId) => '/book-orders/$orderId/cancel';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String sessionIdKey = 'session_id';
  static const String userIdKey = 'user_id';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String introSeenKey = 'intro_seen';
}
