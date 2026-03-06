import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core_ios/constants/api_constants.dart';
import 'package:pgme/core_ios/models/session_access_model.dart';
import 'package:pgme/core_ios/services/api_service.dart';

class SessionAccessService {
  final ApiService _apiService = ApiService();

  /// Check if user has access to a session
  Future<SessionAccessStatus> checkSessionAccess(String sessionId) async {
    try {
      debugPrint('=== SessionAccessService: Checking session access ===');

      final response = await _apiService.dio.get(
        ApiConstants.sessionAccessStatus(sessionId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final accessData = response.data['data'] as Map<String, dynamic>;
        final accessStatus = SessionAccessStatus.fromJson(accessData);

        debugPrint('Session access status: hasAccess=${accessStatus.hasAccess}, isFree=${accessStatus.isFree}');
        return accessStatus;
      }

      throw Exception('Failed to check session access');
    } on DioException catch (e) {
      debugPrint('Check session access error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Join a live session (after access verification)
  Future<Map<String, dynamic>> joinSession(String sessionId) async {
    try {
      debugPrint('=== SessionAccessService: Joining session ===');

      final response = await _apiService.dio.post(
        ApiConstants.sessionJoin(sessionId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final result = response.data['data'] as Map<String, dynamic>;

        debugPrint('Joined session successfully');
        return result;
      }

      throw Exception('Failed to join session');
    } on DioException catch (e) {
      debugPrint('Join session error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get user's session access records
  Future<List<SessionAccessModel>> getUserSessionRecords({
    bool? isActive,
    String? paymentStatus,
  }) async {
    try {
      debugPrint('=== SessionAccessService: Getting user session records ===');

      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['is_active'] = isActive.toString();
      if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;

      final response = await _apiService.dio.get(
        ApiConstants.activeSessionActivity,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final recordsData = response.data['data']['purchases'] as List;
        final records = recordsData
            .map((json) => SessionAccessModel.fromJson(json as Map<String, dynamic>))
            .toList();

        debugPrint('${records.length} session access records retrieved');
        return records;
      }

      throw Exception('Failed to load session access records');
    } on DioException catch (e) {
      debugPrint('Get session access records error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('Unexpected error: $e');
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
      debugPrint('Check enrollment status error: $e');
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
      debugPrint('Enroll in session error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

}
