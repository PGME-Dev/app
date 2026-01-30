import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/auth/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AuthProvider>();
      final success = await provider.sendOTP('+91${_phoneController.text}');

      if (success && mounted) {
        context.push('/otp-verification', extra: '+91${_phoneController.text}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP. Please try again.'),
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
    final isKeyboardOpen = keyboardHeight > 0;
    final double buttonBottomPadding = isKeyboardOpen ? keyboardHeight + 16 : 50.0;
    final double inputTopPosition = isKeyboardOpen ? 280 : 556;
    final double termsTopPosition = isKeyboardOpen ? 360 : 656;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Logo at top (hide when keyboard open)
          if (!isKeyboardOpen)
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

          // Skip button
          Positioned(
            top: 44,
            right: 0,
            child: SizedBox(
              width: 414,
              height: 64,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Login Illustration (hide when keyboard open)
          if (!isKeyboardOpen)
            Positioned(
              top: 270,
              left: 30,
              child: Image.asset(
                'assets/illustrations/login.png',
                width: 360,
                height: 380,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 260,
                    height: 280,
                    color: AppColors.cardBackground,
                    child: const Center(
                      child: Icon(
                        Icons.phone_android_rounded,
                        size: 80,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Title
          Positioned(
            top: isKeyboardOpen ? 100 : 261,
            left: 0,
            right: 0,
            child: const Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Color(0xFF000000),
              ),
            ),
          ),

          // Subtitle
          Positioned(
            top: isKeyboardOpen ? 150 : 326,
            left: 24,
            right: 24,
            child: const Text(
              'Enter your mobile number to receive\nan OTP',
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

          // Mobile Number Input
          Positioned(
            top: inputTopPosition,
            left: 24,
            right: 24,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: Row(
                children: [
                  // Country Code
                  const SizedBox(width: 16),
                  Image.asset(
                    'assets/images/flag_india.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        '🇮🇳',
                        style: TextStyle(fontSize: 20),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '+91',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Vertical divider line
                  Container(
                    width: 1,
                    height: 37,
                    color: AppColors.divider,
                  ),
                  const SizedBox(width: 12),

                  // Phone Number Input
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Mobile Number',
                        hintStyle: TextStyle(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        counterText: '',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Terms and Privacy
          Positioned(
            top: termsTopPosition,
            left: 24,
            right: 24,
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                  height: 1.0,
                ),
                children: [
                  TextSpan(text: 'By continuing you agree to our '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),

          // Send OTP Button
          Positioned(
            bottom: buttonBottomPadding,
            left: 44,
            right: 44,
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOTP,
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
                        'Send OTP',
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
