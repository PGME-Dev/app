import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/zoho_payment_models.dart';
import 'package:pgme/core/services/api_service.dart';

/// Service to handle Zoho Payments API calls
/// This service provides generic methods for payment session creation and verification
/// that can be reused across packages, sessions, and book orders
class ZohoPaymentService {
  final ApiService _apiService = ApiService();

  /// Generic method to create payment session for any endpoint
  ///
  /// [endpoint] - The API endpoint to call (e.g., '/payments/create-order')
  /// [data] - Optional request body data
  ///
  /// Returns a [ZohoPaymentSession] with payment_session_id and amount
  Future<ZohoPaymentSession> createPaymentSession({
    required String endpoint,
    Map<String, dynamic>? data,
  }) async {
    try {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🚀 ZohoPaymentService: Creating payment session');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📍 Endpoint: $endpoint');
      debugPrint('📦 Request Data: ${data ?? "null"}');

      final response = await _apiService.dio.post(
        endpoint,
        data: data,
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 201 && response.data['success'] == true) {
        final sessionData = response.data['data'] as Map<String, dynamic>;
        final session = ZohoPaymentSession.fromJson(sessionData);

        debugPrint('✅ Payment session created successfully!');
        debugPrint('🎫 Payment Session ID: ${session.paymentSessionId}');
        debugPrint('💰 Amount: ${session.amount} ${session.currency}');
        debugPrint('🔖 Reference: ${session.referenceNumber}');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('');
        return session;
      }

      debugPrint('❌ Failed to create payment session');
      debugPrint('Message: ${response.data['message']}');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception(response.data['message'] ?? 'Failed to create payment session');
    } on DioException catch (e) {
      debugPrint('❌ DioException creating payment session');
      debugPrint('Error: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Generic method to verify payment for any endpoint
  ///
  /// [endpoint] - The API endpoint to call (e.g., '/payments/verify')
  /// [paymentSessionId] - The payment_session_id from Zoho
  /// [paymentId] - The payment_id returned by Zoho widget
  /// [signature] - Optional signature from Zoho for additional verification
  ///
  /// Returns a [ZohoVerificationResponse] with purchase details
  Future<ZohoVerificationResponse> verifyPayment({
    required String endpoint,
    required String paymentSessionId,
    required String paymentId,
    String? signature,
  }) async {
    try {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔐 ZohoPaymentService: Verifying payment');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📍 Endpoint: $endpoint');
      debugPrint('🎫 Payment Session ID: $paymentSessionId');
      debugPrint('💳 Payment ID: $paymentId');
      debugPrint('🔏 Signature: ${signature ?? "null"}');

      final requestData = {
        'payment_session_id': paymentSessionId,
        'payment_id': paymentId,
        if (signature != null) 'signature': signature,
      };

      debugPrint('📦 Request Data: $requestData');

      final response = await _apiService.dio.post(
        endpoint,
        data: requestData,
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final verificationData = response.data['data'] as Map<String, dynamic>;
        final verification = ZohoVerificationResponse.fromJson(verificationData);

        debugPrint('✅ Payment verified successfully!');
        debugPrint('🎁 Purchase ID: ${verification.purchaseId}');
        debugPrint('📅 Expires At: ${verification.expiresAt ?? "N/A"}');
        debugPrint('💬 Message: ${verification.message}');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('');
        return verification;
      }

      debugPrint('❌ Payment verification failed');
      debugPrint('Message: ${response.data['message']}');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception(response.data['message'] ?? 'Payment verification failed');
    } on DioException catch (e) {
      debugPrint('❌ DioException verifying payment');
      debugPrint('Error: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get Zoho Account ID from environment variables
  ///
  /// Returns the Zoho Payments Account ID configured in .env
  String getZohoAccountId() {
    return ApiConstants.zohoAccountId;
  }

  /// Get Zoho API key from environment variables
  ///
  /// Returns the Zoho Payments API key configured in .env
  String getZohoApiKey() {
    return ApiConstants.zohoApiKey;
  }

  /// Get Zoho payment script URL
  ///
  /// Returns the Zoho Payments JavaScript SDK URL
  String getZohoScriptUrl() {
    return ApiConstants.zohoScriptUrl;
  }
}
