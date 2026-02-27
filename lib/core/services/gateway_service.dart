import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/gateway_models.dart';
import 'package:pgme/core/services/api_service.dart';

/// Service to handle Gateway API calls
/// This service provides generic methods for gateway session creation and verification
/// that can be reused across packages, sessions, and book requests
class GatewayService {
  final ApiService _apiService = ApiService();

  /// Generic method to create gateway session for any endpoint
  ///
  /// [endpoint] - The API endpoint to call (e.g., '/payments/create-order')
  /// [data] - Optional request body data
  ///
  /// Returns a [GatewaySession] with payment_session_id and amount
  Future<GatewaySession> initSession({
    required String endpoint,
    Map<String, dynamic>? data,
  }) async {
    try {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('GatewayService: Creating gateway session');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Endpoint: $endpoint');
      debugPrint('Request Data: ${data ?? "null"}');

      final response = await _apiService.dio.post(
        endpoint,
        data: data,
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode == 201 && response.data['success'] == true) {
        final sessionData = response.data['data'] as Map<String, dynamic>;
        final session = GatewaySession.fromJson(sessionData);

        debugPrint('Gateway session created successfully!');
        debugPrint('Session ID: ${session.paymentSessionId}');
        debugPrint('Amount: ${session.amount} ${session.currency}');
        debugPrint('Reference: ${session.referenceNumber}');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('');
        return session;
      }

      debugPrint('Failed to create gateway session');
      debugPrint('Message: ${response.data['message']}');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception(response.data['message'] ?? 'Failed to create gateway session');
    } on DioException catch (e) {
      debugPrint('DioException creating gateway session');
      debugPrint('Error: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('Unexpected error: $e');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Generic method to confirm gateway session for any endpoint
  ///
  /// [endpoint] - The API endpoint to call (e.g., '/payments/verify')
  /// [paymentSessionId] - The payment_session_id from the gateway
  /// [paymentId] - The payment_id returned by the gateway widget
  /// [signature] - Optional signature for additional verification
  ///
  /// Returns a [GatewayVerificationResponse] with access details
  Future<GatewayVerificationResponse> confirmSession({
    required String endpoint,
    required String paymentSessionId,
    required String paymentId,
    String? signature,
  }) async {
    try {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('GatewayService: Confirming gateway session');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Endpoint: $endpoint');
      debugPrint('Session ID: $paymentSessionId');
      debugPrint('Payment ID: $paymentId');
      debugPrint('Signature: ${signature ?? "null"}');

      final requestData = {
        'payment_session_id': paymentSessionId,
        'payment_id': paymentId,
        if (signature != null) 'signature': signature,
      };

      debugPrint('Request Data: $requestData');

      final response = await _apiService.dio.post(
        endpoint,
        data: requestData,
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final verificationData = response.data['data'] as Map<String, dynamic>;
        final verification = GatewayVerificationResponse.fromJson(verificationData);

        debugPrint('Gateway session confirmed successfully!');
        debugPrint('Record ID: ${verification.purchaseId}');
        debugPrint('Expires At: ${verification.expiresAt ?? "N/A"}');
        debugPrint('Message: ${verification.message}');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('');
        return verification;
      }

      debugPrint('Gateway session confirmation failed');
      debugPrint('Message: ${response.data['message']}');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception(response.data['message'] ?? 'Gateway session confirmation failed');
    } on DioException catch (e) {
      debugPrint('DioException confirming gateway session');
      debugPrint('Error: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('Unexpected error: $e');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get Gateway Account ID from environment variables
  ///
  /// Returns the Gateway Account ID configured in .env
  String getAccountId() {
    return ApiConstants.gatewayAccountId;
  }

  /// Get Gateway API key from environment variables
  ///
  /// Returns the Gateway API key configured in .env
  String getApiKey() {
    return ApiConstants.gatewayApiKey;
  }

  /// Get Gateway script URL
  ///
  /// Returns the Gateway JavaScript SDK URL
  String getScriptUrl() {
    return ApiConstants.gatewayScriptUrl;
  }
}
