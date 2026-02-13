import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : const Color(0xFFF5F7FA);
    final headerBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF000000).withValues(alpha: 0.7);
    final cardBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final backButtonBgColor = isDark ? AppColors.darkBackground : const Color(0xFFF5F7FA);

    final hPadding = isTablet ? ResponsiveHelper.horizontalPadding(context) : 16.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(top: topPadding + (isTablet ? 20 : 16), left: hPadding, right: hPadding, bottom: isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: headerBgColor,
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x0A000000),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: isTablet ? 54 : 44,
                    height: isTablet ? 54 : 44,
                    decoration: BoxDecoration(
                      color: backButtonBgColor,
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: isTablet ? 22 : 18,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
                Expanded(
                  child: Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isTablet ? 25 : 20,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: isTablet ? 26 : 20,
                left: hPadding,
                right: hPadding,
                bottom: bottomPadding + (isTablet ? 26 : 20),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isTablet ? 900 : double.infinity),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isTablet ? 26 : 20),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(isTablet ? 21 : 16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Updated: February 13, 2026',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: isTablet ? 15 : 12,
                            fontStyle: FontStyle.italic,
                            color: secondaryTextColor,
                          ),
                        ),
                        SizedBox(height: isTablet ? 26 : 20),

                        _buildSection(
                          'Welcome to PGME',
                          'These Terms and Conditions ("Terms") govern your access to and use of the PGME platform, including our mobile application and website (collectively, the "Platform"). By accessing or using the Platform, you agree to be bound by these Terms.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '1. Acceptance of Terms',
                          'By creating an account or accessing any part of the Platform, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy. If you do not agree to these Terms, you must not use the Platform.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '2. Eligibility',
                          'You must be at least 18 years of age to use the Platform. By using the Platform, you represent and warrant that you meet this age requirement and have the legal capacity to enter into these Terms.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '3. User Accounts',
                          'To access certain features of the Platform, you must create an account. You are responsible for:\n\n• Maintaining the confidentiality of your account credentials\n• All activities that occur under your account\n• Ensuring that your account information is accurate and up-to-date\n\nYou must notify us immediately of any unauthorized use of your account.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '4. Subscription and Payments',
                          'Access to premium content requires a paid subscription. By purchasing a subscription, you agree to:\n\n• Pay all applicable fees for the selected subscription plan\n• Provide accurate payment information\n• Our refund policy as outlined separately\n\nAll payments are processed securely through our payment gateway partners.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '5. Content and Intellectual Property',
                          'All content on the Platform, including but not limited to courses, videos, study materials, and assessments, is owned by PGME or our content partners. You are granted a limited, non-exclusive, non-transferable license to access and use the content solely for your personal educational purposes.\n\nYou may not:\n\n• Copy, distribute, or reproduce any content\n• Share your account credentials with others\n• Record, screenshot, or capture any content\n• Use content for commercial purposes',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '6. User Conduct',
                          'You agree to use the Platform in accordance with all applicable laws and regulations. Prohibited activities include:\n\n• Violating any intellectual property rights\n• Attempting to gain unauthorized access to the Platform\n• Interfering with or disrupting the Platform\n• Harassing or threatening other users\n• Posting inappropriate or offensive content',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '7. Live Sessions',
                          'Access to live sessions is subject to availability and capacity limits. PGME reserves the right to:\n\n• Schedule, reschedule, or cancel live sessions\n• Limit the number of participants\n• Record sessions for later viewing\n• Remove disruptive participants',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '8. Privacy and Data Protection',
                          'Your use of the Platform is subject to our Privacy Policy, which explains how we collect, use, and protect your personal information. By using the Platform, you consent to our data practices as described in the Privacy Policy.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '9. Disclaimers',
                          'The Platform and all content are provided "as is" without warranties of any kind, either express or implied. PGME does not guarantee:\n\n• Uninterrupted or error-free operation\n• That content will meet your specific requirements\n• Specific exam results or outcomes\n• The accuracy or completeness of any content',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '10. Limitation of Liability',
                          'To the maximum extent permitted by law, PGME shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the Platform.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '11. Termination',
                          'PGME reserves the right to suspend or terminate your account at any time for:\n\n• Violation of these Terms\n• Fraudulent or illegal activity\n• Non-payment of fees\n• Any other reason at our sole discretion',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '12. Changes to Terms',
                          'We reserve the right to modify these Terms at any time. Changes will be effective immediately upon posting to the Platform. Your continued use of the Platform after changes constitutes acceptance of the modified Terms.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '13. Contact Information',
                          'For questions or concerns about these Terms, please contact us through the support section in the app or visit our website.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, Color titleColor, Color contentColor, {bool isTablet = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 26 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          SizedBox(height: isTablet ? 10 : 8),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isTablet ? 17 : 14,
              height: 1.6,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }
}
