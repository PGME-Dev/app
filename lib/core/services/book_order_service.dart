import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/book_order_model.dart';
import 'package:pgme/core/models/zoho_payment_models.dart';
import 'package:pgme/core/services/api_service.dart';
import 'package:pgme/core/services/zoho_payment_service.dart';

class BookOrderService {
  final ApiService _apiService = ApiService();
  final ZohoPaymentService _zohoPaymentService = ZohoPaymentService();

  /// Create Razorpay order for book purchase
  Future<BookOrderResponse> createOrder({
    required List<Map<String, dynamic>> items,
    required String recipientName,
    required String shippingPhone,
    required String shippingAddress,
  }) async {
    try {
      debugPrint('=== BookOrderService: Creating order ===');

      final response = await _apiService.dio.post(
        ApiConstants.createBookOrder,
        data: {
          'items': items,
          'recipient_name': recipientName,
          'shipping_phone': shippingPhone,
          'shipping_address': shippingAddress,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BookOrderResponse.fromJson(data);
      }

      throw Exception(response.data['message'] ?? 'Failed to create order');
    } on DioException catch (e) {
      debugPrint('DioException creating order: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  /// Verify Razorpay payment
  Future<PaymentVerifyResponse> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      debugPrint('=== BookOrderService: Verifying payment ===');

      final response = await _apiService.dio.post(
        ApiConstants.verifyBookPayment,
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return PaymentVerifyResponse.fromJson(data);
      }

      throw Exception(response.data['message'] ?? 'Payment verification failed');
    } on DioException catch (e) {
      debugPrint('DioException verifying payment: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Payment verification failed');
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      rethrow;
    }
  }

  /// Create test order (bypasses Razorpay for testing)
  Future<Map<String, dynamic>> createTestOrder({
    required List<Map<String, dynamic>> items,
    required String recipientName,
    required String shippingPhone,
    required String shippingAddress,
  }) async {
    try {
      debugPrint('=== BookOrderService: Creating test order ===');

      final response = await _apiService.dio.post(
        ApiConstants.testBookOrder,
        data: {
          'items': items,
          'recipient_name': recipientName,
          'shipping_phone': shippingPhone,
          'shipping_address': shippingAddress,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception(response.data['message'] ?? 'Failed to create test order');
    } on DioException catch (e) {
      debugPrint('DioException creating test order: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error creating test order: $e');
      rethrow;
    }
  }

  /// Get user's book orders
  Future<List<BookOrderModel>> getUserOrders({
    String? orderStatus,
    String? paymentStatus,
    int limit = 20,
  }) async {
    try {
      debugPrint('=== BookOrderService: Getting user orders ===');

      final queryParams = <String, dynamic>{'limit': limit};
      if (orderStatus != null) queryParams['order_status'] = orderStatus;
      if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;

      final response = await _apiService.dio.get(
        ApiConstants.bookOrders,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final ordersData = response.data['data']['orders'] as List;
        return ordersData
            .map((json) => BookOrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('DioException getting orders: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting orders: $e');
      rethrow;
    }
  }

  /// Get order by ID
  Future<BookOrderModel> getOrderById(String orderId) async {
    try {
      debugPrint('=== BookOrderService: Getting order $orderId ===');

      final response = await _apiService.dio.get(
        ApiConstants.bookOrderDetails(orderId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final orderData = response.data['data']['order'] as Map<String, dynamic>;
        return BookOrderModel.fromJson(orderData);
      }

      throw Exception('Failed to load order details');
    } on DioException catch (e) {
      debugPrint('DioException getting order: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting order: $e');
      rethrow;
    }
  }

  /// Cancel an order
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      debugPrint('=== BookOrderService: Cancelling order $orderId ===');

      final response = await _apiService.dio.post(
        ApiConstants.cancelBookOrder(orderId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception(response.data['message'] ?? 'Failed to cancel order');
    } on DioException catch (e) {
      debugPrint('DioException cancelling order: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      rethrow;
    }
  }

  // ============================================================================
  // ZOHO PAYMENTS METHODS
  // ============================================================================

  /// Create Zoho payment session for book order
  Future<ZohoPaymentSession> createPaymentSession({
    required List<Map<String, dynamic>> items,
    required String recipientName,
    required String shippingPhone,
    required String shippingAddress,
    Map<String, dynamic>? billingAddress,
    Map<String, dynamic>? shippingAddressStructured,
  }) async {
    return await _zohoPaymentService.createPaymentSession(
      endpoint: ApiConstants.createBookOrder,
      data: {
        'items': items,
        'recipient_name': recipientName,
        'shipping_phone': shippingPhone,
        'shipping_address': shippingAddress,
        if (billingAddress != null) 'billing_address': billingAddress,
        if (shippingAddressStructured != null) 'shipping_address_structured': shippingAddressStructured,
      },
    );
  }

  /// Verify Zoho payment for book order
  Future<ZohoVerificationResponse> verifyZohoPayment({
    required String paymentSessionId,
    required String paymentId,
    String? signature,
  }) async {
    return await _zohoPaymentService.verifyPayment(
      endpoint: ApiConstants.verifyBookPayment,
      paymentSessionId: paymentSessionId,
      paymentId: paymentId,
      signature: signature,
    );
  }
}
