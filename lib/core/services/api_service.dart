import 'package:dio/dio.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initializeDio();
  }

  late Dio _dio;
  final StorageService _storageService = StorageService();

  Dio get dio => _dio;

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add request interceptor to inject access token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add access token to headers if available
          final token = await _storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized (token expired)
          if (error.response?.statusCode == 401) {
            // Try to refresh the token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              final options = error.requestOptions;
              final token = await _storageService.getAccessToken();
              options.headers['Authorization'] = 'Bearer $token';

              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              // Refresh failed, logout user
              await _storageService.clearAll();
              return handler.next(error);
            }
          }

          // Handle 403 Forbidden (onboarding incomplete)
          if (error.response?.statusCode == 403) {
            final message = error.response?.data?['message'] as String?;
            if (message?.contains('onboarding') ?? false) {
              // Navigation will be handled by the UI layer
            }
          }

          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor for debugging (remove in production)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // Only log in debug mode
          // print(obj);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Authorization': null, // Don't use access token for refresh
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await _storageService.saveAccessToken(data['access_token']);
        await _storageService.saveRefreshToken(data['refresh_token']);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Error handling helper
  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] as String?;

          if (statusCode == 400) {
            return message ?? 'Invalid request. Please check your input.';
          } else if (statusCode == 401) {
            return message ?? 'Session expired. Please login again.';
          } else if (statusCode == 403) {
            return message ?? 'Access denied.';
          } else if (statusCode == 404) {
            return 'Resource not found.';
          } else if (statusCode == 500) {
            return 'Server error. Please try again later.';
          }
          return message ?? 'An error occurred. Please try again.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network.';
        default:
          return 'An unexpected error occurred. Please try again.';
      }
    }
    return 'An error occurred. Please try again.';
  }
}
