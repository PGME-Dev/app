import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Dark blue background color matching the design
  static const Color _darkBlue = Color(0xFF0033CC);

  @override
  void initState() {
    super.initState();
    // Set status bar to light icons for dark background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait 2 seconds for splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Always show onboarding screens first, then login
    debugPrint('=== Splash Navigation ===');
    debugPrint('Navigating to onboarding...');
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _darkBlue,
      body: Stack(
        children: [
          // Main content centered
          Container(
            width: double.infinity,
            height: double.infinity,
            color: _darkBlue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PGME logo in the center (slightly offset to the right)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Image.asset(
                    'assets/illustrations/pgme.png',
                    width: screenSize.width * 0.35,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.medical_services,
                        size: 100,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // PGME text below the logo
                Image.asset(
                  'assets/illustrations/pgmetext.png',
                  width: screenSize.width * 0.45,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'PGME',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Version number at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: Text(
                'Ver 1.6.5',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
