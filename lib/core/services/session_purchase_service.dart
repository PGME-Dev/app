import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/session_purchase_model.dart';
import 'package:pgme/core/models/zoho_payment_models.dart';
import 'package:pgme/core/services/api_service.dart';
import 'package:pgme/core/services/zoho_payment_service.dart';

class SessionPurchaseService {
  final ApiService _apiService = ApiService();
  final ZohoPaymentService _zohoPaymentService = ZohoPaymentService();

  /// Check if user has access to a session
  Future<SessionAccessStatus> checkSessionAccess(String sessionId) async {
    try {
      debugPrint('=== SessionPurchaseService: Checking session access ===');

      final response = await _apiService.dio.get(
        ApiConstants.sessionAccessStatus(sessionId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final accessData = response.data['data'] as Map<String, dynamic>;
        final accessStatus = SessionAccessStatus.fromJson(accessData);

        debugPrint('✓ Session access status: hasAccess=${accessStatus.hasAccess}, isFree=${accessStatus.isFree}');
        return accessStatus;
      }

      throw Exception('Failed to check session access');
    } on DioException catch (e) {
      debugPrint('✗ Check session access error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Create Razorpay order for session purchase
  Future<SessionOrderResponse> createOrder(String sessionId) async {
    try {
      debugPrint('=== SessionPurchaseService: Creating session order ===');

      final response = await _apiService.dio.post(
        ApiConstants.sessionCreateOrder(sessionId),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final orderData = response.data['data'] as Map<String, dynamic>;
        final order = SessionOrderResponse.fromJson(orderData);

        debugPrint('✓ Session order created: ${order.orderId}');
        return order;
      }

      throw Exception('Failed to create session order');
    } on DioException catch (e) {
      debugPrint('✗ Create session order error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Verify session payment
  Future<Map<String, dynamic>> verifyPayment({
    required String sessionId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      debugPrint('=== SessionPurchaseService: Verifying session payment ===');

      final response = await _apiService.dio.post(
        ApiConstants.sessionVerifyPayment(sessionId),
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final result = response.data['data'] as Map<String, dynamic>;

        debugPrint('✓ Session payment verified successfully');
        return result;
      }

      throw Exception('Failed to verify session payment');
    } on DioException catch (e) {
      debugPrint('✗ Verify session payment error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Join a live session (after purchase verification)
  Future<Map<String, dynamic>> joinSession(String sessionId) async {
    try {
      debugPrint('=== SessionPurchaseService: Joining session ===');

      final response = await _apiService.dio.post(
        ApiConstants.sessionJoin(sessionId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final result = response.data['data'] as Map<String, dynamic>;

        debugPrint('✓ Joined session successfully');
        return result;
      }

      throw Exception('Failed to join session');
    } on DioException catch (e) {
      debugPrint('✗ Join session error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Create test purchase (bypasses Razorpay for testing)
  Future<Map<String, dynamic>> createTestPurchase(String sessionId) async {
    try {
      debugPrint('=== SessionPurchaseService: Creating test purchase ===');

      final response = await _apiService.dio.post(
        ApiConstants.sessionTestPurchase(sessionId),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final result = response.data['data'] as Map<String, dynamic>;

        debugPrint('✓ Test purchase created: ${result['purchase_id']}');
        return result;
      }

      throw Exception('Failed to create test purchase');
    } on DioException catch (e) {
      debugPrint('✗ Create test purchase error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get user's session purchases
  Future<List<SessionPurchaseModel>> getUserSessionPurchases({
    bool? isActive,
    String? paymentStatus,
  }) async {
    try {
      debugPrint('=== SessionPurchaseService: Getting user session purchases ===');

      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['is_active'] = isActive.toString();
      if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;

      final response = await _apiService.dio.get(
        ApiConstants.userSessionPurchases,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final purchasesData = response.data['data']['purchases'] as List;
        final purchases = purchasesData
            .map((json) => SessionPurchaseModel.fromJson(json as Map<String, dynamic>))
            .toList();

        debugPrint('✓ ${purchases.length} session purchases retrieved');
        return purchases;
      }

      throw Exception('Failed to load session purchases');
    } on DioException catch (e) {
      debugPrint('✗ Get session purchases error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  // ============================================================================
  // ENROLLMENT METHODS
  // ============================================================================

  /// Check enrollment status for a session
  Future<Map<String, dynamic>> checkEnrollmentStatus(String sessionId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.sessionEnrollmentStatus(sessionId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception('Failed to check enrollment status');
    } on DioException catch (e) {
      debugPrint('✗ Check enrollment status error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  /// Enroll in a session (for free sessions)
  Future<Map<String, dynamic>> enrollInSession(String sessionId) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.sessionEnroll(sessionId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception('Failed to enroll in session');
    } on DioException catch (e) {
      debugPrint('✗ Enroll in session error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  // ============================================================================
  // ZOHO PAYMENTS METHODS
  // ============================================================================

  /// Create Zoho payment session for session purchase
  Future<ZohoPaymentSession> createPaymentSession(
    String sessionId, {
    Map<String, dynamic>? billingAddress,
  }) async {
    return await _zohoPaymentService.createPaymentSession(
      endpoint: ApiConstants.sessionCreateOrder(sessionId),
      data: billingAddress != null ? {'billing_address': billingAddress} : null,
    );
  }

  /// Verify Zoho payment for session purchase
  Future<ZohoVerificationResponse> verifyZohoPayment({
    required String sessionId,
    required String paymentSessionId,
    required String paymentId,
    String? signature,
  }) async {
    return await _zohoPaymentService.verifyPayment(
      endpoint: ApiConstants.sessionVerifyPayment(sessionId),
      paymentSessionId: paymentSessionId,
      paymentId: paymentId,
      signature: signature,
    );
  }
}
