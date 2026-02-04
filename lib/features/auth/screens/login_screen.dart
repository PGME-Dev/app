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
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Prevent automatic focus on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocusNode.unfocus();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
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
      // MSG91 expects format: 91XXXXXXXXXX (no + or spaces)
      final phoneNumber = '91${_phoneController.text}';

      debugPrint('Sending OTP to: $phoneNumber');
      final success = await provider.sendOTP(phoneNumber);

      if (success && mounted) {
        debugPrint('OTP sent successfully, navigating to verification screen');
        // Navigate to OTP screen
        context.push('/otp-verification');
      } else if (mounted) {
        debugPrint('OTP sending failed: success = false');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('OTP sending error: $e');
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
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Flexible top section - expands to fill available space
              Expanded(
                flex: isKeyboardOpen ? 1 : 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/illustrations/logo2.png',
                      height: isKeyboardOpen ? 40 : 53,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(height: isKeyboardOpen ? 40 : 53);
                      },
                    ),

                    // Illustration - only when keyboard is closed
                    if (!isKeyboardOpen) ...[
                      const SizedBox(height: 16),
                      Flexible(
                        child: Image.asset(
                          'assets/illustrations/login.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.phone_android_rounded,
                              size: 80,
                              color: AppColors.textTertiary,
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom section - fixed content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isKeyboardOpen ? 24 : 32,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF000000),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Enter your mobile number to receive an OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isKeyboardOpen ? 14 : 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF000000),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mobile Number Input
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider, width: 1),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Image.asset(
                          'assets/images/flag_india.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('🇮🇳', style: TextStyle(fontSize: 20));
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
                        Container(width: 1, height: 32, color: AppColors.divider),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            textInputAction: TextInputAction.done,
                            autofocus: false,
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
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onSubmitted: (_) => _sendOTP(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Terms and Privacy
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: isKeyboardOpen ? 11 : 13,
                        color: const Color(0xFF000000),
                      ),
                      children: const [
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

                  const SizedBox(height: 20),

                  // Send OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
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
