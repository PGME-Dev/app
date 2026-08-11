import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/workshop_model.dart';
import 'package:pgme/core/models/gateway_models.dart';
import 'package:pgme/core/services/api_service.dart';
import 'package:pgme/core/services/gateway_service.dart';

/// Workshops — multi-day live programmes.
///
/// One purchase or registration covers every day. Joining an individual day
/// goes through [joinDay], which reuses the live-session join endpoint: a day
/// *is* a LiveSession server-side, and the backend resolves entitlement against
/// the parent workshop.
class WorkshopService {
  final ApiService _apiService = ApiService();
  final GatewayService _gatewayService = GatewayService();

  // ==========================================================================
  // Catalogue
  // ==========================================================================

  Future<List<WorkshopModel>> getWorkshops({
    String? subjectId,
    String? status,
    bool upcomingOnly = true,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (subjectId != null) queryParams['subject_id'] = subjectId;
      if (status != null) queryParams['status'] = status;
      if (upcomingOnly) queryParams['upcoming_only'] = 'true';

      final response = await _apiService.dio.get(
        ApiConstants.workshops,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data']['workshops'] as List;
        final workshops = list
            .map((json) => WorkshopModel.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('✓ ${workshops.length} workshops retrieved');
        return workshops;
      }

      throw Exception('Failed to load workshops');
    } on DioException catch (e) {
      debugPrint('✗ Get workshops error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Full detail: agenda, faculty and — when signed in — the caller's access,
  /// attendance and certificate state.
  Future<WorkshopModel> getWorkshopDetails(String workshopId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.workshopDetails(workshopId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return WorkshopModel.fromJson(
          response.data['data']['workshop'] as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to load workshop');
    } on DioException catch (e) {
      debugPrint('✗ Get workshop details error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<WorkshopCapacityModel?> getCapacity(String workshopId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.workshopCapacity(workshopId),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return WorkshopCapacityModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      // Non-critical: the detail screen renders fine without seat counts.
      debugPrint('Get workshop capacity failed: $e');
      return null;
    }
  }

  Future<List<WorkshopRecordingModel>> getRecordings(String workshopId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.workshopRecordings(workshopId),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data']['recordings'] as List;
        return list
            .map((j) => WorkshopRecordingModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get workshop recordings failed: $e');
      return [];
    }
  }

  // ==========================================================================
  // Registration
  // ==========================================================================

  /// Register for a free workshop. When the workshop is full and waitlisting is
  /// on, the server returns a waitlisted enrollment rather than failing — the
  /// caller should read `waitlisted` in the response.
  Future<Map<String, dynamic>> enroll(String workshopId) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.workshopEnroll(workshopId),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          ...(response.data['data'] as Map<String, dynamic>),
          'message': response.data['message'],
        };
      }
      throw Exception('Failed to register for workshop');
    } on DioException catch (e) {
      debugPrint('✗ Workshop enroll error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  Future<void> cancelEnrollment(String workshopId) async {
    try {
      await _apiService.dio.delete(ApiConstants.workshopEnroll(workshopId));
    } on DioException catch (e) {
      debugPrint('✗ Workshop cancel enrollment error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>?> getEnrollmentStatus(String workshopId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.workshopEnrollmentStatus(workshopId),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Get workshop enrollment status failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkAccess(String workshopId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.workshopAccessStatus(workshopId),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Check workshop access failed: $e');
      return null;
    }
  }

  // ==========================================================================
  // Joining a day
  // ==========================================================================

  /// Register attendance for one day and get its meeting link.
  ///
  /// Takes the day's `session_id` and calls the shared live-session join
  /// endpoint — the backend recognises the workshop and gates on the parent's
  /// entitlement, so there is a single join path for both products.
  Future<Map<String, dynamic>> joinDay(String sessionId) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.sessionJoin(sessionId),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to join this day');
    } on DioException catch (e) {
      debugPrint('✗ Join workshop day error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  // ==========================================================================
  // Certificates
  // ==========================================================================

  Future<WorkshopCertificateStatusModel?> getCertificateStatus(
    String workshopId,
  ) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.workshopCertificate(workshopId),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return WorkshopCertificateStatusModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Get certificate status failed: $e');
      return null;
    }
  }

  /// Issue (idempotent) and return a short-lived download URL for the PDF.
  Future<Map<String, dynamic>> claimCertificate(String workshopId) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.workshopCertificate(workshopId),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to generate certificate');
    } on DioException catch (e) {
      debugPrint('✗ Claim certificate error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  // ==========================================================================
  // Payment
  // ==========================================================================

  Future<GatewaySession> initSession(
    String workshopId, {
    Map<String, dynamic>? billingAddress,
    String? couponCode,
    bool? termsAccepted,
  }) async {
    final data = <String, dynamic>{
      if (billingAddress != null) 'billing_address': billingAddress,
      if (couponCode != null) 'coupon_code': couponCode,
      if (termsAccepted != null) 'terms_accepted': termsAccepted,
    };
    return await _gatewayService.initSession(
      endpoint: ApiConstants.activeWorkshopInitAccess(workshopId),
      data: data.isEmpty ? null : data,
    );
  }

  Future<GatewayVerificationResponse> confirmSession({
    required String workshopId,
    required String paymentSessionId,
    required String paymentId,
    String? signature,
  }) async {
    return await _gatewayService.confirmSession(
      endpoint: ApiConstants.activeWorkshopConfirmAccess(workshopId),
      paymentSessionId: paymentSessionId,
      paymentId: paymentId,
      signature: signature,
    );
  }
}
