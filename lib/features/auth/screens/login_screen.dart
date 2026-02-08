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

  // Dark blue background color
  static const Color _darkBlue = Color(0xFF0000CC);

  @override
  void initState() {
    super.initState();
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
      final phoneNumber = '91${_phoneController.text}';

      debugPrint('Sending OTP to: $phoneNumber');
      final success = await provider.sendOTP(phoneNumber);

      if (success && mounted) {
        debugPrint('OTP sent successfully, navigating to verification screen');
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: _darkBlue,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Blue header section with title
          SafeArea(
            bottom: false,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: isKeyboardOpen ? 120 : 198,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isKeyboardOpen ? 24 : 28,
                      fontWeight: FontWeight.w700,
                      height: 1.14,
                      letterSpacing: 0.14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your mobile number to\nreceive an OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isKeyboardOpen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      letterSpacing: 0.08,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // White bottom container with rounded top corners
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFEFEFE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mobile Number label
                    const Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF78828A),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Mobile Number Input
                    Container(
                      width: 327,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FE),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        textInputAction: TextInputAction.done,
                        autofocus: false,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF333333),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Enter your mobile number',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFAAAAAA),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.only(left: 16, top: 14, bottom: 14),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onSubmitted: (_) => _sendOTP(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Continue with Mobile Number Button
                    Center(
                      child: SizedBox(
                        width: 327,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _darkBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
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
                                  'Continue with Mobile Number',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
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

                    const Spacer(),

                    // Bottom padding to account for keyboard
                    SizedBox(height: keyboardHeight > 0 ? keyboardHeight + 16 : bottomPadding + 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
