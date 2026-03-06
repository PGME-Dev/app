import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core_ios/constants/api_constants.dart';
import 'package:pgme/core_ios/models/book_request_model.dart';
import 'package:pgme/core_ios/services/api_service.dart';

class BookRequestService {
  final ApiService _apiService = ApiService();

  /// Get user's book requests
  Future<List<BookRequestModel>> getUserRequests({
    String? orderStatus,
    String? paymentStatus,
    int limit = 20,
  }) async {
    try {
      debugPrint('=== BookRequestService: Getting user requests ===');

      final queryParams = <String, dynamic>{'limit': limit};
      if (orderStatus != null) queryParams['order_status'] = orderStatus;
      if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;

      final response = await _apiService.dio.get(
        ApiConstants.activeBookRequests,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final requestsData = response.data['data']['orders'] as List;
        return requestsData
            .map((json) => BookRequestModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('DioException getting requests: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting requests: $e');
      rethrow;
    }
  }

  /// Get request by ID
  Future<BookRequestModel> getRequestById(String orderId) async {
    try {
      debugPrint('=== BookRequestService: Getting request $orderId ===');

      final response = await _apiService.dio.get(
        ApiConstants.activeBookRequestDetails(orderId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final requestData = response.data['data']['order'] as Map<String, dynamic>;
        return BookRequestModel.fromJson(requestData);
      }

      throw Exception('Failed to load request details');
    } on DioException catch (e) {
      debugPrint('DioException getting request: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting request: $e');
      rethrow;
    }
  }

  /// Cancel a request
  Future<Map<String, dynamic>> cancelRequest(String orderId) async {
    try {
      debugPrint('=== BookRequestService: Cancelling request $orderId ===');

      final response = await _apiService.dio.post(
        ApiConstants.activeCancelBookRequest(orderId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception(response.data['message'] ?? 'Failed to cancel request');
    } on DioException catch (e) {
      debugPrint('DioException cancelling request: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error cancelling request: $e');
      rethrow;
    }
  }

}
