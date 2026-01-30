import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final cardBgColor = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final buttonColor = isDark ? const Color(0xFF0047CF) : AppColors.primaryBlue;
    final iconColor = isDark ? const Color(0xFF00BEFA) : AppColors.success;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Congratulations Illustration
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/illustrations/cong.png',
                width: 400,
                height: 360,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 400,
                    height: 360,
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 100,
                        color: iconColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Title - Congratulations
          Positioned(
            top: 423,
            left: 28,
            child: SizedBox(
              width: 333,
              child: Text(
                'Congratulations',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.0,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Description text
          Positioned(
            top: 473,
            left: 28,
            child: SizedBox(
              width: 333,
              child: Text(
                'mollit aliquip nostrud consequat proident ex aliquip sit',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: textColor.withValues(alpha: 0.7),
                  height: 1.0,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Buttons at bottom
          Positioned(
            left: 32,
            right: 32,
            bottom: bottomPadding + 48,
            child: Column(
              children: [
                // Continue to Dashboard Button
                GestureDetector(
                  onTap: () {
                    // Navigate to subscribed dashboard after purchase
                    context.go('/home?subscribed=true');
                  },
                  child: Container(
                    width: 326,
                    height: 54,
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Text(
                        'Continue to Dashboard',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.0,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Download Invoice Button
                GestureDetector(
                  onTap: () {
                    // Download invoice functionality
                  },
                  child: Container(
                    width: 326,
                    height: 54,
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Text(
                        'Download Invoice',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.0,
                          letterSpacing: 0,
                        ),
                      ),
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
}
