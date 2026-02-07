import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_zoom_meeting_sdk/flutter_zoom_meeting_sdk.dart';
import 'package:flutter_zoom_meeting_sdk/enums/status_zoom_error.dart';
import 'package:flutter_zoom_meeting_sdk/models/zoom_meeting_sdk_request.dart';
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
  final FlutterZoomMeetingSdk _zoomSdk = FlutterZoomMeetingSdk();
  bool _isInitialized = false;

  /// Initialize the Zoom SDK (call once before first use)
  Future<bool> initZoomSDK() async {
    if (_isInitialized) return true;

    try {
      debugPrint('=== ZoomMeetingService: Initializing Zoom SDK ===');
      await _zoomSdk.initZoom();
      _isInitialized = true;
      debugPrint('Zoom SDK initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize Zoom SDK: $e');
      return false;
    }
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
    debugPrint('=== ZoomMeetingService: Joining Zoom meeting ===');

    // Step 1: Initialize SDK
    final initialized = await initZoomSDK();
    if (!initialized) {
      throw Exception('Failed to initialize Zoom SDK');
    }

    // Step 2: Get SDK signature (JWT) from backend
    final zoomSignature = await getZoomSignature(sessionId);

    // Step 3: Authenticate with the JWT and wait for result via stream
    debugPrint('Authenticating with Zoom SDK...');
    final authCompleter = Completer<bool>();
    StreamSubscription? authSubscription;

    authSubscription = _zoomSdk.onAuthenticationReturn.listen((event) {
      debugPrint('Zoom auth event: ${event.params?.statusEnum}');
      if (event.params?.statusEnum == StatusZoomError.success) {
        if (!authCompleter.isCompleted) {
          authCompleter.complete(true);
        }
      } else {
        if (!authCompleter.isCompleted) {
          authCompleter.completeError(
            Exception('Zoom authentication failed: ${event.params?.statusLabel}'),
          );
        }
      }
      authSubscription?.cancel();
    });

    await _zoomSdk.authZoom(jwtToken: zoomSignature.signature);

    // Wait for auth result (timeout after 15 seconds)
    final authSuccess = await authCompleter.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        authSubscription?.cancel();
        throw Exception('Zoom authentication timed out');
      },
    );

    if (!authSuccess) {
      throw Exception('Zoom authentication failed');
    }

    // Step 4: Join the meeting
    debugPrint('Joining meeting: ${zoomSignature.meetingNumber}');
    await _zoomSdk.joinMeeting(
      ZoomMeetingSdkRequest(
        meetingNumber: zoomSignature.meetingNumber,
        password: zoomSignature.password,
        displayName: displayName,
      ),
    );

    debugPrint('Zoom joinMeeting called successfully');
    return true;
  }
}
