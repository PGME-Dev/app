import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_zoom_meeting_sdk/flutter_zoom_meeting_sdk.dart';
// import 'package:flutter_zoom_meeting_sdk/enums/status_meeting_status.dart';
// import 'package:flutter_zoom_meeting_sdk/models/zoom_meeting_sdk_request.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/services/api_service.dart';

/// Custom exception types for better error handling
enum ZoomErrorType {
  authenticationFailed,
  joinFailed,
  timeout,
  networkError,
  hostNotJoined,
  meetingEnded,
  unknown,
}

class ZoomJoinException implements Exception {
  final ZoomErrorType type;
  final String message;
  final String? technicalDetails;

  ZoomJoinException({
    required this.type,
    required this.message,
    this.technicalDetails,
  });

  @override
  String toString() => message;
}

/// Response model for the Zoom SDK signature from backend
class ZoomSignatureResponse {
  final String sdkKey;
  final String signature;
  final String meetingNumber;
  final String password;
  final Map<String, dynamic> meetingOptions;

  ZoomSignatureResponse({
    required this.sdkKey,
    required this.signature,
    required this.meetingNumber,
    required this.password,
    this.meetingOptions = const {},
  });

  factory ZoomSignatureResponse.fromJson(Map<String, dynamic> json) {
    return ZoomSignatureResponse(
      sdkKey: json['sdkKey'] as String,
      signature: json['signature'] as String,
      meetingNumber: json['meetingNumber'] as String,
      password: json['password'] as String,
      meetingOptions: json['meetingOptions'] != null
          ? Map<String, dynamic>.from(json['meetingOptions'] as Map)
          : {},
    );
  }
}

class ZoomMeetingService {
  final ApiService _apiService = ApiService();
  // final FlutterZoomMeetingSdk _zoomSdk = FlutterZoomMeetingSdk();

  /// Initialize the Zoom SDK (call once before first use)
  // TODO: Re-enable when flutter_zoom_meeting_sdk is available
  // Future<bool> initZoomSDK() async {
  //   try {
  //     debugPrint('=== ZoomMeetingService: Initializing Zoom SDK ===');
  //
  //     final result = await _zoomSdk.initZoom();
  //
  //     if (result.isSuccess) {
  //       debugPrint('Zoom SDK initialized successfully: ${result.message}');
  //       return true;
  //     } else {
  //       debugPrint('Zoom SDK initialization failed: ${result.message}');
  //       return false;
  //     }
  //   } catch (e) {
  //     debugPrint('Zoom SDK initialization error: $e');
  //     return false;
  //   }
  // }

  Future<bool> initZoomSDK() async {
    debugPrint('Zoom SDK temporarily disabled');
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
  // TODO: Re-enable when flutter_zoom_meeting_sdk is available
  Future<bool> joinMeeting({
    required String sessionId,
    required String displayName,
  }) async {
    throw ZoomJoinException(
      type: ZoomErrorType.unknown,
      message: 'Zoom meetings are temporarily disabled. Please contact support.',
    );
  }
}
