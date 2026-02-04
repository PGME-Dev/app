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
        if (provider.onboardingCompleted) {
          context.go('/home');
        } else {
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

  void _onOTPCompleted(String otp) {
    setState(() => _otp = otp);
    if (otp.length == 4) {
      _verifyOTP();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Back button
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider, width: 1),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),

              // Top flexible section - only logo
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/illustrations/logo2.png',
                    height: isKeyboardOpen ? 36 : 50,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(height: isKeyboardOpen ? 36 : 50);
                    },
                  ),
                ),
              ),

              // Bottom section - all form content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isKeyboardOpen ? 24 : 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF000000),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Enter the 4-digit OTP sent to your mobile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isKeyboardOpen ? 13 : 15,
                      color: const Color(0x99000000),
                    ),
                  ),

                  SizedBox(height: isKeyboardOpen ? 20 : 28),

                  // OTP Input
                  OTPInput(
                    length: 4,
                    onCompleted: _onOTPCompleted,
                  ),

                  SizedBox(height: isKeyboardOpen ? 16 : 20),

                  // Resend OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive? ",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: isKeyboardOpen ? 12 : 13,
                          color: const Color(0x99000000),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('OTP resent successfully'),
                              backgroundColor: AppColors.primaryBlue,
                            ),
                          );
                        },
                        child: Text(
                          'Resend',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: isKeyboardOpen ? 12 : 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isKeyboardOpen ? 20 : 28),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
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

                  SizedBox(height: isKeyboardOpen ? 12 : 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
