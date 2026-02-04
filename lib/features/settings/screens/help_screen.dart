import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

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

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final cardColor = isDark ? AppColors.darkCardBackground : const Color(0xFFF5F5F5);
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF888888);
    final dividerColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Help & Support',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact Support Section
                    Text(
                      'Contact Support',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

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
                    ),
                    const SizedBox(height: 12),

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
                    ),
                    const SizedBox(height: 12),

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
                    ),

                    const SizedBox(height: 24),

                    // FAQ Section
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildFaqItem(
                      question: 'How do I purchase a course?',
                      answer: 'Go to the Home tab, browse available packages, and tap on any package to view details and purchase options.',
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),

                    _buildFaqItem(
                      question: 'How do I access my purchased content?',
                      answer: 'After purchase, go to the Courses tab to access your video lectures, notes, and study materials.',
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),

                    _buildFaqItem(
                      question: 'Can I download videos for offline viewing?',
                      answer: 'Yes, you can download videos within the app for offline access. Look for the download icon on each video.',
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),

                    _buildFaqItem(
                      question: 'How do I change my selected subject?',
                      answer: 'Go to your Profile, tap on the subject badge next to your name, and select a new subject from the list.',
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),

                    _buildFaqItem(
                      question: 'What payment methods are accepted?',
                      answer: 'We accept all major payment methods including UPI, Credit/Debit cards, Net Banking, and popular wallets.',
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    // Support Hours
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A1A4D)
                            : const Color(0xFF0000D1).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
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
                            size: 32,
                            color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF0000D1),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Support Hours',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Monday - Saturday',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            '9:00 AM - 6:00 PM IST',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF0000D1),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color dividerColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: secondaryTextColor,
          collapsedIconColor: secondaryTextColor,
          title: Text(
            question,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: textColor,
            ),
          ),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 13,
                height: 1.5,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
