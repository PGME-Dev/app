import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pgme/core_ios/constants/api_constants.dart';

/// Resolves the web-store base URL dynamically from the backend.
///
/// Sends `platform` + app `version` and returns the matching base URL.
/// Returns `null` on any failure (network error, timeout, 4xx, 5xx, malformed body).
/// Callers must treat `null` as "service unavailable — show try-again message"
/// and must NOT fall back to a hardcoded URL.
class WebStoreRedirectService {
  static const Duration _timeout = Duration(seconds: 5);

  static Future<String?> fetchBaseUrl() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final platform = Platform.isIOS ? 'ios' : 'android';

      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
      ));

      final res = await dio.get<Map<String, dynamic>>(
        ApiConstants.webStoreRedirect,
        queryParameters: {
          'platform': platform,
          'version': info.version,
        },
      );

      final body = res.data;
      if (body == null) return null;
      final data = body['data'];
      if (data is! Map) return null;
      final baseUrl = data['base_url'];
      if (baseUrl is String && baseUrl.isNotEmpty) {
        return baseUrl;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
