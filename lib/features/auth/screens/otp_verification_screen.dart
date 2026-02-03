import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
        // Route based on onboarding status
        if (provider.onboardingCompleted) {
          // User has completed onboarding, go to home
          context.go('/home');
        } else {
          // User needs to complete onboarding
          context.go('/data-collection');
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

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double bottomPadding = keyboardHeight > 0 ? keyboardHeight + 16 : 50.0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Back button
          Positioned(
            top: 64,
            left: 24,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),

          // Logo at top
          Positioned(
            top: 118,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/illustrations/logo2.png',
                width: 240,
                height: 63,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(width: 240, height: 63);
                },
              ),
            ),
          ),

          // Title
          Positioned(
            top: 229,
            left: 0,
            right: 0,
            child: const Text(
              'Verify OTP',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: Color(0xFF000000),
              ),
            ),
          ),

          // Subtitle
          Positioned(
            top: 286,
            left: 24,
            right: 24,
            child: Opacity(
              opacity: 0.6,
              child: const Text(
                'Please enter the 4-digit OTP sent to\nyour mobile number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ),

          // OTP Input
          Positioned(
            top: 368,
            left: 0,
            right: 0,
            child: Center(
              child: OTPInput(
                length: 4,
                onCompleted: (otp) {
                  setState(() => _otp = otp);
                },
              ),
            ),
          ),

          // Verify Button
          Positioned(
            bottom: bottomPadding,
            left: 44,
            right: 44,
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
