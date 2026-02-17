import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '918074220727';
    const message = 'Hi, I need help with the PGME app.';
    final url = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail() async {
    final url = Uri.parse(
      'mailto:support@pgme.in?subject=PGME App Support&body=Hi, I need help with...',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchPhone() async {
    final url = Uri.parse('tel:+918074220727');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final cardColor = isDark ? AppColors.darkCardBackground : const Color(0xFFF5F5F5);
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF888888);
    final hPadding = isTablet ? ResponsiveHelper.horizontalPadding(context) : 16.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: isTablet ? 54 : 44,
                      height: isTablet ? 54 : 44,
                      decoration: BoxDecoration(
                        color: cardColor,
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
                  Text(
                    'Help & Support',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 25 : 20,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxContentWidth(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Contact Support Section
                        Text(
                          'Contact Support',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            fontSize: isTablet ? 20 : 16,
                            letterSpacing: -0.5,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),

                        // WhatsApp Card
                        _buildContactCard(
                          icon: Icons.chat_outlined,
                          title: 'WhatsApp',
                          subtitle: 'Chat with us on WhatsApp',
                          iconBgColor: isDark ? const Color(0xFF1A4D1A) : const Color(0xFFE8F5E9),
                          iconColor: Colors.green,
                          cardColor: cardColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          onTap: _launchWhatsApp,
                          isTablet: isTablet,
                        ),
                        SizedBox(height: isTablet ? 16 : 12),

                        // Email Card
                        _buildContactCard(
                          icon: Icons.mail_outline,
                          title: 'Email',
                          subtitle: 'support@pgme.in',
                          iconBgColor: isDark ? const Color(0xFF1A1A4D) : const Color(0xFFE3F2FD),
                          iconColor: isDark ? const Color(0xFF90CAF9) : const Color(0xFF1976D2),
                          cardColor: cardColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          onTap: _launchEmail,
                          isTablet: isTablet,
                        ),
                        SizedBox(height: isTablet ? 16 : 12),

                        // Phone Card
                        _buildContactCard(
                          icon: Icons.phone_outlined,
                          title: 'Call Us',
                          subtitle: '+91 8074220727',
                          iconBgColor: isDark ? const Color(0xFF4D4D1A) : const Color(0xFFFFF8E1),
                          iconColor: Colors.orange,
                          cardColor: cardColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          onTap: _launchPhone,
                          isTablet: isTablet,
                        ),

                        SizedBox(height: isTablet ? 30 : 24),

                        // Support Hours
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A4D)
                                : const Color(0xFF0000D1).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF3D3D8C)
                                  : const Color(0xFF0000D1).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: isTablet ? 40 : 32,
                                color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF0000D1),
                              ),
                              SizedBox(height: isTablet ? 10 : 8),
                              Text(
                                'Support Hours',
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 20 : 16,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: isTablet ? 6 : 4),
                              Text(
                                'Monday - Saturday',
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: isTablet ? 17 : 14,
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                '9:00 AM - 6:00 PM IST',
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w500,
                                  fontSize: isTablet ? 17 : 14,
                                  color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF0000D1),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isTablet ? 40 : 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required Color iconColor,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
    bool isTablet = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        child: Row(
          children: [
            Container(
              width: isTablet ? 60 : 48,
              height: isTablet ? 60 : 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: isTablet ? 30 : 24,
                  color: iconColor,
                ),
              ),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 19 : 15,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: isTablet ? 3 : 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: isTablet ? 16 : 13,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: isTablet ? 20 : 16,
              color: secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

}
