import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/services/storage_service.dart';
import 'package:pgme/features/onboarding/providers/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Welcome to PGME',
      subtitle: 'Your PostGraduate Medical Education,\nStructured and Simplified',
      illustration: 'assets/illustrations/onboarding_1.png',
    ),
    OnboardingData(
      title: 'Learn Subject\nby Subject',
      subtitle: 'Carefully structured courses\ndesigned for clarity and depth',
      illustration: 'assets/illustrations/onboarding_2.png',
    ),
    OnboardingData(
      title: 'Watch Recorded\nLectures Anytime',
      subtitle: 'Learn at your pace with\nHigh-Quality Recorded Sessions',
      illustration: 'assets/illustrations/onboarding_3.png',
    ),
    OnboardingData(
      title: 'Stay Updated with\nLive Webinars',
      subtitle: 'Interactive sessions with experts\nto enhance your learning',
      illustration: 'assets/illustrations/onboarding_4.png',
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

  Future<void> _onNext() async {
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
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60),
                  // Logo
                  Image.asset(
                    'assets/illustrations/logo2.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(height: 40);
                    },
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _onSkip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
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
                  return _OnboardingPage(
                    data: _pages[index],
                    screenHeight: screenHeight,
                  );
                },
              ),
            ),

            // Bottom section with indicators and button
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 24),
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
                                  ? AppColors.primaryBlue
                                  : AppColors.primaryBlue.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: Consumer<OnboardingProvider>(
                      builder: (context, provider, _) {
                        final isLastPage = provider.currentPage == _pages.length - 1;
                        return ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isLastPage ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
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
  final double screenHeight;

  const _OnboardingPage({
    required this.data,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.9;

    return Column(
      children: [
        // Illustration - fixed large size
        SizedBox(
          height: imageSize,
          width: imageSize,
          child: Image.asset(
            data.illustration,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(
                    Icons.school_outlined,
                    size: 120,
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  ),
                ),
              );
            },
          ),
        ),

        // Text content - takes remaining space
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
