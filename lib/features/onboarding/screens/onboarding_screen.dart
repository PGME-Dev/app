import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/services/storage_service.dart';
import 'package:pgme/features/onboarding/providers/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  // Dark blue background color matching the design
  static const Color _darkBlue = Color(0xFF0033CC);
  static const Color _buttonColor = Color(0xFF00C2FF);

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Secure Access\nLearning Sessions',
      subtitle: 'Secured Log In ensures that the content is only\navailable for registered Learners',
      illustration: 'assets/illustrations/1.png',
    ),
    OnboardingData(
      title: 'Theory and Practical\nPreparations',
      subtitle: 'Get access to structured theory and practical\nmock lessons and tests.',
      illustration: 'assets/illustrations/2.png',
    ),
    OnboardingData(
      title: 'Get Revision Notes and\nAccess to Live Classes',
      subtitle: 'Register for Live Sessions and Access\nRecordings. Access dedicated notes to ace\nyour examinations',
      illustration: 'assets/illustrations/3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    context.read<OnboardingProvider>().setCurrentPage(page);
  }

  Future<void> _onSkip() async {
    await StorageService().saveIntroSeen(true);
    if (mounted) {
      context.go('/login');
    }
  }

  Future<void> _onContinue() async {
    final provider = context.read<OnboardingProvider>();
    if (provider.currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await StorageService().saveIntroSeen(true);
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with Logo and Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo in top left
                  Image.asset(
                    'assets/illustrations/pgme.png',
                    width: 52,
                    height: 33,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(height: 33, width: 52);
                    },
                  ),
                  // Skip button
                  GestureDetector(
                    onTap: _onSkip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: _pages[index], index: index);
                },
              ),
            ),

            // Bottom section with indicators, button and terms
            Padding(
              padding: EdgeInsets.fromLTRB(25, 0, 25, bottomPadding + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Consumer<OnboardingProvider>(
                    builder: (context, provider, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: provider.currentPage == index ? 24 : 8,
                            height: 8,
                            margin: EdgeInsets.only(
                              right: index < _pages.length - 1 ? 8 : 0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: provider.currentPage == index
                                  ? _buttonColor
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Continue/Get Started button
                  Consumer<OnboardingProvider>(
                    builder: (context, provider, _) {
                      final isLastPage = provider.currentPage == _pages.length - 1;
                      return GestureDetector(
                        onTap: _onContinue,
                        child: Container(
                          width: 325,
                          height: 50,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _buttonColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: Text(
                              isLastPage ? 'Get Started' : 'Continue',
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.0, // 100% line-height
                                letterSpacing: 0,
                                color: Color(0xFF0000D1),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Terms and Privacy text
                  SizedBox(
                    width: 327,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.5, // line-height: 18px / 12px
                          color: Colors.white,
                        ),
                        children: [
                          const TextSpan(text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const TextSpan(text: ' and\n'),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final int index;

  const _OnboardingPage({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 0.85;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Illustration with circle background
          Expanded(
            flex: 4,
            child: Center(
              child: SizedBox(
                width: circleSize,
                height: circleSize,
                child: Stack(
                  children: [
                    // Outer circle (largest)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Middle circle
                    Center(
                      child: Container(
                        width: circleSize * 0.78,
                        height: circleSize * 0.78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Inner circle (smallest)
                    Center(
                      child: Container(
                        width: circleSize * 0.56,
                        height: circleSize * 0.56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Dotted points on circle lines
                    ..._buildCircleDots(circleSize),
                    // Main illustration centered exactly on circle
                    Positioned.fill(
                      child: Center(
                        child: Image.asset(
                          data.illustration,
                          width: circleSize * 2.0,
                          height: circleSize * 2.0,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_outlined,
                              size: 100,
                              color: Colors.white.withValues(alpha: 0.3),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Text content
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Title
                SizedBox(
                  width: 355,
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: index == 2 ? 29 : 33,
                      fontWeight: FontWeight.w700,
                      height: 1.0, // 100% line-height
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                SizedBox(
                  width: 341,
                  child: Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.57,
                      letterSpacing: 0,
                      color: Color(0xFF00C2FF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCircleDots(double circleSize) {
    final center = circleSize / 2;
    final List<Widget> dots = [];

    // Three circles: outer (100%), middle (78%), inner (56%)
    // Dots should be exactly ON the border lines
    final outerRadius = center - 1.5;
    final middleRadius = (circleSize * 0.78 / 2) - 1.5;
    final innerRadius = (circleSize * 0.56 / 2) - 1.5;

    // Dot configurations: [angle in degrees, circleIndex (2=outer, 1=middle, 0=inner), size]
    final dotConfigs = [
      // Outer circle dots
      [30.0, 2, 7.0],
      [90.0, 2, 5.0],
      [150.0, 2, 8.0],
      [210.0, 2, 6.0],
      [270.0, 2, 7.0],
      [330.0, 2, 5.0],
      // Middle circle dots
      [15.0, 1, 6.0],
      [60.0, 1, 8.0],
      [120.0, 1, 5.0],
      [180.0, 1, 7.0],
      [240.0, 1, 6.0],
      [300.0, 1, 8.0],
      // Inner circle dots
      [45.0, 0, 5.0],
      [105.0, 0, 7.0],
      [165.0, 0, 6.0],
      [225.0, 0, 8.0],
      [285.0, 0, 5.0],
      [345.0, 0, 7.0],
    ];

    for (final config in dotConfigs) {
      final angle = config[0] as double;
      final circleIndex = config[1] as int;
      final dotSize = config[2] as double;

      final radians = angle * math.pi / 180;
      final cosVal = math.cos(radians);
      final sinVal = math.sin(radians);

      final dotRadius = circleIndex == 2 ? outerRadius : (circleIndex == 1 ? middleRadius : innerRadius);

      dots.add(
        Positioned(
          left: center + dotRadius * cosVal - dotSize / 2,
          top: center - dotRadius * sinVal - dotSize / 2,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return dots;
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String illustration;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.illustration,
  });
}
