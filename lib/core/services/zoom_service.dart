import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// flutter_zoom_meeting_sdk disabled due to broken build.gradle
// import 'package:flutter_zoom_meeting_sdk/flutter_zoom_meeting_sdk.dart';
// import 'package:flutter_zoom_meeting_sdk/enums/status_zoom_error.dart';
// import 'package:flutter_zoom_meeting_sdk/models/zoom_meeting_sdk_request.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/services/api_service.dart';

/// Response model for the Zoom SDK signature from backend
class ZoomSignatureResponse {
  final String sdkKey;
  final String signature;
  final String meetingNumber;
  final String password;

  ZoomSignatureResponse({
    required this.sdkKey,
    required this.signature,
    required this.meetingNumber,
    required this.password,
  });

  factory ZoomSignatureResponse.fromJson(Map<String, dynamic> json) {
    return ZoomSignatureResponse(
      sdkKey: json['sdkKey'] as String,
      signature: json['signature'] as String,
      meetingNumber: json['meetingNumber'] as String,
      password: json['password'] as String,
    );
  }
}

class ZoomMeetingService {
  final ApiService _apiService = ApiService();

  /// Initialize the Zoom SDK (call once before first use)
  Future<bool> initZoomSDK() async {
    // Zoom SDK disabled — always fails so callers fall back to external Zoom app
    debugPrint('ZoomMeetingService: Zoom SDK is disabled (broken package)');
    return false;
  }

  /// Fetch Zoom SDK signature (JWT) from backend
  Future<ZoomSignatureResponse> getZoomSignature(String sessionId) async {
    try {
      debugPrint('=== ZoomMeetingService: Getting Zoom signature ===');

      final response = await _apiService.dio.get(
        ApiConstants.sessionZoomSignature(sessionId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final signatureResponse = ZoomSignatureResponse.fromJson(data);
        debugPrint('Zoom signature obtained for meeting: ${signatureResponse.meetingNumber}');
        return signatureResponse;
      }

      throw Exception('Failed to get Zoom signature');
    } on DioException catch (e) {
      debugPrint('Get Zoom signature error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  /// Join a Zoom meeting in-app using the Meeting SDK
  Future<bool> joinMeeting({
    required String sessionId,
    required String displayName,
  }) async {
    // Zoom SDK disabled — throw so callers fall back to external Zoom app
    throw Exception('Zoom SDK is currently unavailable. Opening in external Zoom app.');
  }
}
