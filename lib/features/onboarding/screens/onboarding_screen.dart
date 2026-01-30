import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
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
      subtitle: 'Your PostGraduate Medical Education, Structures and Simplified',
      illustration: 'assets/illustrations/onboarding_1.png',
    ),
    OnboardingData(
      title: 'Learn Subject\nby Subject',
      subtitle: 'Carefully structured courses designed for clarity and depth',
      illustration: 'assets/illustrations/onboarding_2.png',
    ),
    OnboardingData(
      title: 'Watch Recorded\nlectures anytime',
      subtitle: 'Learn at your pace with High-Quality Recorded Sessions',
      illustration: 'assets/illustrations/onboarding_3.png',
    ),
    OnboardingData(
      title: 'Stay Updated with\nLive Webinars',
      subtitle: 'Learn at your pace with High-Quality Recorded Sessions',
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

  void _onSkip() {
    context.read<OnboardingProvider>().completeOnboarding();
    context.go('/login');
  }

  void _onNext() {
    final provider = context.read<OnboardingProvider>();
    if (provider.currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      provider.completeOnboarding();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PageView content (first so other widgets render on top)
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _OnboardingPage(data: _pages[index]);
              },
            ),
          ),

          // Logo at top
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
            right: 16,
            child: TextButton(
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
          ),

          // Page Indicator dots
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Consumer<OnboardingProvider>(
              builder: (context, provider, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(right: index < _pages.length - 1 ? 13 : 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: provider.currentPage == index
                            ? AppColors.primaryBlue
                            : const Color.fromRGBO(158, 158, 158, 0.3),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Next Button
          Positioned(
            bottom: 50,
            left: 44,
            right: 44,
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Next',
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

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Illustration
        Positioned(
          top: 350,
          left: 50,
          right: 50,
          child: Center(
            child: Image.asset(
              data.illustration,
              width: 420,
              height: 420,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.cardBackground,
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 80,
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Title
        Positioned(
          top: 261,
          left: 24,
          right: 24,
          child: Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: 0,
              color: Color(0xFF000000),
            ),
          ),
        ),

        // Subtitle
        Positioned(
          top: 360,
          left: 24,
          right: 24,
          child: Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              height: 1.2,
              letterSpacing: 0,
              color: Color(0xFF000000),
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
