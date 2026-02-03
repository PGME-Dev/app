import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/features/auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait 2 seconds for splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Check authentication status
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    // Navigate based on authentication and onboarding status
    if (authProvider.isAuthenticated) {
      // User is authenticated
      if (authProvider.onboardingCompleted) {
        // Onboarding complete → Go to home
        context.go('/home');
      } else {
        // Onboarding incomplete → Go to data collection (profile setup)
        context.go('/data-collection');
      }
    } else {
      // Not authenticated → Go to login
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background pattern with specific positioning
          Positioned(
            top: -31.73,
            left: -39.21,
            child: Image.asset(
              'assets/illustrations/bg.png',
              width: 564.22,
              height: 993.39,
              fit: BoxFit.cover,
            ),
          ),
          // White box with logo on top of background - no animation
          Center(
            child: Container(
              width: 361.45,
              height: 391.68,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 32,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/illustrations/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
