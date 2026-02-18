import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/ebook_purchase_model.dart';
import 'package:pgme/core/models/zoho_payment_models.dart';
import 'package:pgme/core/services/api_service.dart';

class EbookOrderService {
  final ApiService _apiService = ApiService();

  /// Create a Zoho payment session for ebook purchase
  Future<ZohoPaymentSession> createPaymentSession(
    String bookId, {
    Map<String, dynamic>? billingAddress,
  }) async {
    try {
      debugPrint('=== EbookOrderService: Creating payment session for book $bookId ===');

      final response = await _apiService.dio.post(
        ApiConstants.createEbookOrder,
        data: {
          'book_id': bookId,
          if (billingAddress != null) 'billing_address': billingAddress,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ZohoPaymentSession.fromJson(data);
      }

      throw Exception('Failed to create payment session');
    } on DioException catch (e) {
      debugPrint('DioException creating ebook payment session: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error creating ebook payment session: $e');
      rethrow;
    }
  }

  /// Verify ebook payment after Zoho checkout
  Future<ZohoVerificationResponse> verifyPayment({
    required String paymentSessionId,
    required String paymentId,
    String? signature,
  }) async {
    try {
      debugPrint('=== EbookOrderService: Verifying payment ===');

      final response = await _apiService.dio.post(
        ApiConstants.verifyEbookPayment,
        data: {
          'payment_session_id': paymentSessionId,
          'payment_id': paymentId,
          if (signature != null) 'signature': signature,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ZohoVerificationResponse.fromJson(data);
      }

      throw Exception('Payment verification failed');
    } on DioException catch (e) {
      debugPrint('DioException verifying ebook payment: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error verifying ebook payment: $e');
      rethrow;
    }
  }

  /// Get user's purchased ebooks
  Future<List<EbookPurchaseModel>> getUserPurchasedEbooks() async {
    try {
      debugPrint('=== EbookOrderService: Getting purchased ebooks ===');

      final response = await _apiService.dio.get(ApiConstants.ebookOrders);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final ebooksList = data['ebooks'] as List;
        return ebooksList
            .map((json) => EbookPurchaseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to load purchased ebooks');
    } on DioException catch (e) {
      debugPrint('DioException getting purchased ebooks: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting purchased ebooks: $e');
      rethrow;
    }
  }

  /// Get ebook view URL (presigned URL for reading)
  Future<Map<String, dynamic>> getEbookViewUrl(String bookId) async {
    try {
      debugPrint('=== EbookOrderService: Getting view URL for book $bookId ===');

      final response = await _apiService.dio.get(
        ApiConstants.ebookViewUrl(bookId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception('Failed to get ebook URL');
    } on DioException catch (e) {
      debugPrint('DioException getting ebook view URL: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting ebook view URL: $e');
      rethrow;
    }
  }
}
