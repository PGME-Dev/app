import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);

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
            top: isTablet ? 80 : 60,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/illustrations/cong.png',
                width: isTablet ? 500 : 400,
                height: isTablet ? 450 : 360,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: isTablet ? 500 : 400,
                    height: isTablet ? 450 : 360,
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(isTablet ? 30 : 24),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_circle_outline,
                        size: isTablet ? 125 : 100,
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
            top: isTablet ? 533 : 423,
            left: isTablet ? 36 : 28,
            right: isTablet ? 36 : 28,
            child: Text(
              'Congratulations',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isTablet ? 40 : 32,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.0,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Description text
          Positioned(
            top: isTablet ? 593 : 473,
            left: isTablet ? 36 : 28,
            right: isTablet ? 36 : 28,
            child: Text(
              'mollit aliquip nostrud consequat proident ex aliquip sit',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isTablet ? 25 : 20,
                fontWeight: FontWeight.w400,
                color: textColor.withValues(alpha: 0.7),
                height: 1.0,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Buttons at bottom
          Positioned(
            left: isTablet ? 60 : 32,
            right: isTablet ? 60 : 32,
            bottom: bottomPadding + (isTablet ? 60 : 48),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isTablet ? 500 : double.infinity),
                child: Column(
                  children: [
                    // Continue to Dashboard Button
                    GestureDetector(
                      onTap: () {
                        // Navigate to subscribed dashboard after purchase
                        context.go('/home?subscribed=true');
                      },
                      child: Container(
                        width: isTablet ? 400 : 326,
                        height: isTablet ? 66 : 54,
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(isTablet ? 28 : 22),
                        ),
                        child: Center(
                          child: Text(
                            'Continue to Dashboard',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: isTablet ? 25 : 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isTablet ? 20 : 16),

                    // Download Invoice Button
                    GestureDetector(
                      onTap: () {
                        // Download invoice functionality
                      },
                      child: Container(
                        width: isTablet ? 400 : 326,
                        height: isTablet ? 66 : 54,
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(isTablet ? 28 : 22),
                        ),
                        child: Center(
                          child: Text(
                            'Download Invoice',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: isTablet ? 25 : 20,
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
            ),
          ),
        ],
      ),
    );
  }
}
