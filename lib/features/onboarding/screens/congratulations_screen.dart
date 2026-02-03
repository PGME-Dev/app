import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/onboarding/providers/onboarding_provider.dart';
import 'package:pgme/features/auth/providers/auth_provider.dart';

class CongratulationsScreen extends StatefulWidget {
  const CongratulationsScreen({super.key});

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  bool _isCompleting = false;

  Future<void> _completeToDashboard() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    try {
      final onboardingProvider = context.read<OnboardingProvider>();
      final authProvider = context.read<AuthProvider>();

      // Mark onboarding as complete
      await onboardingProvider.completeOnboarding();

      // Update auth provider state
      if (authProvider.user != null) {
        // Refresh user data to get updated onboarding status
        await authProvider.checkAuthStatus();
      }

      if (mounted) {
        // Clear navigation stack and go to home
        context.go('/home');
      }
    } catch (e) {
      setState(() => _isCompleting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Try Again',
              textColor: Colors.white,
              onPressed: _completeToDashboard,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSubject = context.read<OnboardingProvider>().selectedSubject;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              // Success Icon/Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 120,
                    color: AppColors.success,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Congratulations Title
              const Text(
                'Congratulations!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),

              const SizedBox(height: 16),

              // Success Message
              Text(
                selectedSubject != null
                    ? 'You\'ve successfully selected ${selectedSubject.name} as your primary subject!'
                    : 'Your profile setup is complete!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // Welcome message
              const Text(
                'Welcome to PGME!\nLet\'s start your learning journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // Continue to Dashboard Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isCompleting ? null : _completeToDashboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 0,
                  ),
                  child: _isCompleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Continue to Dashboard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
