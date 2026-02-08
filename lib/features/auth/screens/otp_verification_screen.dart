import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/widgets/otp_input.dart';
import 'package:pgme/features/auth/providers/auth_provider.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  String _otp = '';
  bool _isLoading = false;

  // Colors
  static const Color _darkBlue = Color(0xFF0000C8);

  @override
  void initState() {
    super.initState();
    _initSmsListener();
  }

  Future<void> _initSmsListener() async {
    try {
      final signature = await SmsAutoFill().getAppSignature;
      debugPrint('App Signature for SMS: $signature');
    } catch (e) {
      debugPrint('Error getting app signature: $e');
    }
  }

  Future<void> _verifyOTP() async {
    if (_otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AuthProvider>();
      final success = await provider.verifyOTP(_otp);

      if (success && mounted) {
        debugPrint('=== OTP Verification Success ===');
        debugPrint('hasMultipleSessions: ${provider.hasMultipleSessions}');
        debugPrint('onboardingCompleted: ${provider.onboardingCompleted}');

        // Always show data collection first for new users
        if (!provider.onboardingCompleted) {
          debugPrint('Navigating to: /data-collection');
          context.go('/data-collection');
        } else if (provider.hasMultipleSessions) {
          debugPrint('Navigating to: /multiple-logins');
          context.go('/multiple-logins');
        } else {
          debugPrint('Navigating to: /home');
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onOTPChanged(String otp) {
    setState(() => _otp = otp);
  }

  void _onOTPCompleted(String otp) {
    setState(() => _otp = otp);
    if (otp.length == 4) {
      _verifyOTP();
    }
  }

  void _resendOTP() {
    // Go back to login screen to resend OTP
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Enter OTP title
              const Center(
                child: Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    letterSpacing: 0.12,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Center(
                child: Text(
                  'We have just sent you 4 digit code via your\nmobile number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.57,
                    letterSpacing: 0.07,
                    color: Color(0xFF78828A),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // OTP Input
              Center(
                child: OTPInput(
                  length: 4,
                  onChanged: _onOTPChanged,
                  onCompleted: _onOTPCompleted,
                ),
              ),

              const SizedBox(height: 32),

              // Continue button
              Center(
                child: SizedBox(
                  width: 327,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              letterSpacing: 0.08,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Didn't receive code? Resend Code
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive code? ",
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        letterSpacing: 0.08,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: _resendOTP,
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          letterSpacing: 0.08,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom padding for keyboard
              SizedBox(height: keyboardHeight > 0 ? keyboardHeight + 16 : bottomPadding + 24),
            ],
          ),
        ),
      ),
    );
  }
}
