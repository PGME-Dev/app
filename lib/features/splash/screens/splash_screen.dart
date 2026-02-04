import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/features/auth/providers/auth_provider.dart';
import 'package:pgme/core/services/storage_service.dart';

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
    final storageService = StorageService();

    // Check if intro screens have been seen
    final introSeen = await storageService.getIntroSeen();
    debugPrint('=== Splash Navigation ===');
    debugPrint('Intro seen: $introSeen');

    if (!mounted) return;

    // If intro not seen, show onboarding first
    if (!introSeen) {
      debugPrint('Navigating to onboarding...');
      context.go('/onboarding');
      return;
    }

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
    // Get screen dimensions for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Calculate responsive dimensions
    // White box: 85% of screen width, max 400px, with aspect ratio ~1.08
    final boxWidth = (screenWidth * 0.85).clamp(280.0, 400.0);
    final boxHeight = boxWidth * 1.08; // Maintain aspect ratio

    return Scaffold(
      body: Stack(
        children: [
          // Background pattern - full screen coverage
          Positioned.fill(
            child: Image.asset(
              'assets/illustrations/bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                // Fallback background color if image fails to load
                return Container(
                  color: const Color(0xFFF5F5F5),
                );
              },
            ),
          ),
          // White box with logo - centered and responsive
          Center(
            child: Container(
              width: boxWidth,
              height: boxHeight,
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.9, // Never exceed 90% of screen width
                maxHeight: screenHeight * 0.6, // Never exceed 60% of screen height
              ),
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
              child: Padding(
                padding: EdgeInsets.all(boxWidth * 0.1), // 10% padding
                child: Center(
                  child: Image.asset(
                    'assets/illustrations/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback text if logo fails to load
                      return const Text(
                        'PGME',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      );
                    },
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
