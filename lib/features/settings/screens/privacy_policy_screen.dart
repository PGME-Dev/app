import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                    'Privacy Policy',
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
                          'Introduction',
                          'PGME ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our Platform.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '1. Information We Collect',
                          'We collect several types of information to provide and improve our services:\n\nPersonal Information:\n• Name and contact details (email, phone number)\n• Account credentials\n• Profile information\n• Payment and billing information\n\nUsage Information:\n• Course progress and performance\n• Video viewing history\n• Test and assessment results\n• Device information and IP address\n• App usage analytics',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '2. How We Collect Information',
                          'We collect information through:\n\n• Direct input when you create an account or update your profile\n• Automatically through your use of the Platform\n• From third-party authentication services (if applicable)\n• Through cookies and similar tracking technologies\n• From payment processors when you make purchases',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '3. How We Use Your Information',
                          'We use your information to:\n\n• Provide and maintain our services\n• Process your transactions and manage subscriptions\n• Personalize your learning experience\n• Send notifications about courses, sessions, and updates\n• Improve our content and platform functionality\n• Analyze usage patterns and trends\n• Prevent fraud and ensure platform security\n• Comply with legal obligations',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '4. Information Sharing and Disclosure',
                          'We may share your information with:\n\nService Providers:\n• Payment processors (Zoho Payments)\n• Cloud storage providers (Cloudinary)\n• Analytics services (Firebase)\n• Video hosting services (Zoom)\n• SMS/OTP services (MSG91)\n\nWe do not sell your personal information to third parties.\n\nWe may disclose information when:\n• Required by law or legal process\n• Necessary to protect our rights or safety\n• In connection with a business transfer or merger',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '5. Data Security',
                          'We implement industry-standard security measures to protect your information:\n\n• Encrypted data transmission (HTTPS/SSL)\n• Secure storage using encryption\n• Regular security audits\n• Access controls and authentication\n• Secure payment processing\n\nHowever, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '6. Data Retention',
                          'We retain your information for as long as:\n\n• Your account is active\n• Necessary to provide our services\n• Required by law or for legitimate business purposes\n• Needed to resolve disputes or enforce our agreements\n\nYou may request deletion of your account and associated data by contacting us.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '7. Your Rights and Choices',
                          'You have the right to:\n\n• Access your personal information\n• Correct inaccurate data\n• Request deletion of your data\n• Opt-out of marketing communications\n• Withdraw consent for data processing\n• Export your data\n\nTo exercise these rights, please contact us through the app support section.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '8. Cookies and Tracking',
                          'We use cookies and similar technologies to:\n\n• Maintain your session and preferences\n• Analyze platform usage\n• Improve user experience\n• Provide personalized content\n\nYou can control cookie preferences through your device settings.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '9. Third-Party Links',
                          'Our Platform may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '10. Children\'s Privacy',
                          'Our Platform is intended for users aged 18 and above. We do not knowingly collect information from children under 18. If you believe we have collected such information, please contact us immediately.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '11. International Data Transfers',
                          'Your information may be transferred to and processed in countries other than your country of residence. We ensure appropriate safeguards are in place to protect your information during such transfers.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '12. Changes to This Policy',
                          'We may update this Privacy Policy from time to time. We will notify you of significant changes by:\n\n• Posting the updated policy on the Platform\n• Sending an in-app notification\n• Updating the "Last Updated" date\n\nYour continued use of the Platform after changes constitutes acceptance of the updated policy.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '13. Contact Us',
                          'If you have questions or concerns about this Privacy Policy or our data practices, please contact us through:\n\n• The support section in the app\n• Our website contact form\n• Email support (available in the app)',
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
