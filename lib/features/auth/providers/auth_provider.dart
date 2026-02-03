import 'package:flutter/material.dart';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/user_model.dart';
import 'package:pgme/core/services/auth_service.dart';
import 'package:pgme/core/services/user_service.dart';
import 'package:pgme/core/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  UserModel? _user;
  bool _isAuthenticated = false;
  bool _onboardingCompleted = false;
  bool _isInitialized = false;
  String? _msg91ReqId; // Store MSG91 request ID for OTP verification

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isInitialized => _isInitialized;
  String? get msg91ReqId => _msg91ReqId;

  AuthProvider() {
    _initializeMSG91();
    // Don't auto-check auth status - it causes rebuilds during screen initialization
    // Call checkAuthStatus() manually when needed (e.g., on splash screen)
  }

  /// Initialize MSG91 Widget
  void _initializeMSG91() {
    try {
      debugPrint('=== Initializing MSG91 Widget ===');
      debugPrint('Widget ID: ${ApiConstants.msg91WidgetId}');
      debugPrint('Auth Token: ${ApiConstants.msg91AuthToken.substring(0, 10)}...');

      OTPWidget.initializeWidget(
        ApiConstants.msg91WidgetId,
        ApiConstants.msg91AuthToken,
      );

      debugPrint('✓ MSG91 Widget initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('✗ MSG91 initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Check authentication status - call this manually when needed (e.g., splash screen)
  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await _storageService.isAuthenticated();
      if (isAuth) {
        // Try to fetch user profile
        _user = await _userService.getProfile();
        _isAuthenticated = true;
        _onboardingCompleted = _user!.onboardingCompleted;
      }
    } catch (e) {
      // If profile fetch fails, clear tokens
      await _storageService.clearAll();
      _isAuthenticated = false;
      _onboardingCompleted = false;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Send OTP using MSG91
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      debugPrint('=== Sending OTP via MSG91 ===');
      debugPrint('Phone number: $phoneNumber');

      final response = await OTPWidget.sendOTP({
        'identifier': phoneNumber,
      });

      debugPrint('MSG91 Response: $response');
      debugPrint('Response type: ${response?['type']}');
      debugPrint('Response message: ${response?['message']}');

      if (response != null && response['type'] == 'success') {
        // MSG91 returns request ID in the 'message' field for successful OTP send
        _msg91ReqId = response['message'] as String?;
        debugPrint('✓ OTP sent successfully. Request ID: $_msg91ReqId');
        notifyListeners();
        return true;
      } else {
        final errorMsg = response?['message'] ?? 'Failed to send OTP';
        debugPrint('✗ OTP sending failed: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('✗ Send OTP error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  /// Verify OTP with MSG91 and authenticate with backend
  Future<bool> verifyOTP(String otp) async {
    try {
      if (_msg91ReqId == null) {
        throw Exception('No request ID found. Please request OTP first.');
      }

      // Step 1: Verify OTP with MSG91
      debugPrint('=== Verifying OTP with MSG91 ===');
      debugPrint('Request ID: $_msg91ReqId');
      debugPrint('OTP: $otp');

      final msg91Response = await OTPWidget.verifyOTP({
        'reqId': _msg91ReqId!,
        'otp': otp,
      });

      debugPrint('MSG91 Verify Response: $msg91Response');
      debugPrint('Response type: ${msg91Response?['type']}');
      debugPrint('Response message: ${msg91Response?['message']}');
      debugPrint('Response data: ${msg91Response?['data']}');

      if (msg91Response == null || msg91Response['type'] != 'success') {
        throw Exception(msg91Response?['message'] ?? 'Invalid OTP');
      }

      // Step 2: Get MSG91 access token (it's in the 'message' field, not 'data')
      final msg91AccessToken = msg91Response['message'] as String?;
      debugPrint('MSG91 Access Token: $msg91AccessToken');

      if (msg91AccessToken == null || msg91AccessToken.isEmpty) {
        throw Exception('MSG91 access token not received');
      }

      // Step 3: Verify with backend and get JWT tokens
      final authResponse = await _authService.verifyMSG91Token(
        msg91AccessToken,
      );

      // Step 4: Update provider state
      _user = authResponse.user;
      _isAuthenticated = true;
      _onboardingCompleted = authResponse.user.onboardingCompleted;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required String name,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String address,
  }) async {
    try {
      final updatedUser = await _userService.updateProfile({
        'name': name,
        'email': email,
        'date_of_birth': dateOfBirth,
        'gender': gender.toLowerCase(),
        'address': address,
      });

      // Complete onboarding after profile update
      await _userService.completeOnboarding();

      // Update local state
      _user = updatedUser.copyWith(onboardingCompleted: true);
      _onboardingCompleted = true;
      await _storageService.saveOnboardingStatus(true);

      notifyListeners();
    } catch (e) {
      debugPrint('Update profile error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      await _storageService.clearAll();
      _user = null;
      _isAuthenticated = false;
      _onboardingCompleted = false;
      _msg91ReqId = null;
      notifyListeners();
    }
  }

  /// Retry OTP via different channel
  Future<bool> retryOTP({int? channel}) async {
    try {
      if (_msg91ReqId == null) {
        throw Exception('No request ID found. Please request OTP first.');
      }

      final response = await OTPWidget.retryOTP({
        'reqId': _msg91ReqId!,
        if (channel != null) 'retryChannel': channel,
      });

      if (response != null && response['type'] == 'success') {
        return true;
      } else {
        throw Exception(response?['message'] ?? 'Failed to retry OTP');
      }
    } catch (e) {
      debugPrint('Retry OTP error: $e');
      throw Exception('Failed to retry OTP: ${e.toString()}');
    }
  }

  /// Get active sessions
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      return await _authService.getActiveSessions();
    } catch (e) {
      debugPrint('Get sessions error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Logout specific device session
  Future<void> logoutDeviceSession(String sessionId) async {
    try {
      await _authService.logoutDeviceSession(sessionId);
    } catch (e) {
      debugPrint('Logout device error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
