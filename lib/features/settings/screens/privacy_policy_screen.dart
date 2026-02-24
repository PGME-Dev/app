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
                  constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxContentWidth(context)),
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
                          'Last Updated: February 23, 2026',
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
                          'PGME ("we," "our," or "us") operates the PGME mobile application (the "App"). This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our App. Please read this Privacy Policy carefully. By using the App, you agree to the collection and use of information in accordance with this policy.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '1. Information We Collect',
                          'Personal Information:\n• Identity Information: Full name, date of birth, gender\n• Contact Information: Phone number, email address\n• Educational Background: Undergraduate college/university, postgraduate college/university, current professional designation, current affiliated organisation\n• Address Information: Residential address, billing address, shipping address (for book orders)\n• Profile Information: Profile photograph\n• Payment Information: Transaction details processed through our payment partner (Zoho Payments). We do not store your credit/debit card numbers directly.\n\nDevice Information:\n• Device Identifiers: Android ID or iOS Vendor Identifier\n• Device Details: Device brand, model, and operating system type\n• Network Information: Network connection status\n\nLocation Information (with your explicit consent):\n• Precise Location: GPS coordinates used for address auto-fill during profile setup and address selection\n• Address Data: Structured address components obtained through reverse geocoding via OpenStreetMap\n\nYou can disable location access at any time through your device settings.\n\nUsage Information:\n• Learning Activity: Video watch progress, document reading progress, module and course completion status, time spent on content\n• Session Activity: Live session attendance, meeting participation records\n• Purchase History: Subscription purchases, session purchases, book orders, payment status\n• Notification Activity: Notification delivery status, read/unread status\n\nLocally Stored Data:\n• Authentication Tokens: Encrypted access tokens and session identifiers stored in secure device storage\n• Downloaded Content: Video lectures and PDF documents downloaded for offline access\n• User Preferences: Theme settings, notification preferences, subject selections',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '2. How We Use Your Information',
                          'We use the information we collect for the following purposes:\n\n• Account Management: To create, maintain, and authenticate your account using phone-based OTP verification\n• Service Delivery: To provide access to courses, live sessions, study materials, and other educational content\n• Progress Tracking: To track and synchronise your learning progress across devices\n• Payment Processing: To process subscription payments, session purchases, and book orders through our payment partner\n• Order Fulfillment: To deliver physical books to your shipping address and provide order tracking\n• Communication: To send push notifications about class reminders, new content, purchase confirmations, and important announcements\n• Personalisation: To recommend content and send notifications based on your selected subjects and preferences\n• Device Management: To manage active sessions across multiple devices and provide secure access\n• Customer Support: To respond to your inquiries and provide technical assistance\n• App Improvement: To analyse usage patterns and improve our services',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '3. Third-Party Services',
                          'We integrate the following third-party services that may collect or process your data:\n\n• Firebase (Google): Push notification delivery (FCM), app infrastructure. Data shared: FCM device token, notification delivery data.\n• Zoho Payments: Secure payment processing for subscriptions, sessions, and book orders. Data shared: Transaction amount, payment session identifiers.\n• Zoom Video Communications: Live interactive video sessions and classes. Data shared: Meeting access credentials, participant information.\n• MSG91: OTP delivery for phone-based authentication. Data shared: Phone number for OTP delivery.\n• OpenStreetMap (Nominatim): Reverse geocoding for address auto-fill. Data shared: GPS coordinates for address lookup.\n• Amazon CloudFront (AWS): Content delivery network for streaming video lectures and serving media content. Data shared: Standard web request data (IP address, user agent).',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '4. Data Storage and Security',
                          'Data Storage:\n• Your personal information is stored on secure cloud servers\n• Authentication tokens are stored in encrypted device storage (Android EncryptedSharedPreferences / iOS Keychain)\n• Downloaded content is stored locally on your device in a private application directory\n• All data transmission between the App and our servers is encrypted using HTTPS/TLS\n\nSecurity Measures:\n• Encrypted data transmission (HTTPS/TLS)\n• Encrypted local storage for sensitive data (tokens, credentials)\n• JWT-based authentication with token refresh mechanism\n• Session management with device-level access control\n• Secure payment processing through PCI-compliant payment partners\n\nData Retention:\n• We retain your personal information for as long as your account is active or as needed to provide services\n• Learning progress data is retained to enable continued access to your course history\n• Payment records are retained as required by applicable financial regulations\n• You may request deletion of your account and associated data at any time (see Section 7)',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '5. Sharing of Information',
                          'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n• Service Providers: With third-party service providers who assist us in operating the App (as listed in Section 3), strictly for the purposes described\n• Payment Processing: With Zoho Payments to process your transactions securely\n• Legal Requirements: When required by law, regulation, legal process, or governmental request\n• Safety and Security: To protect the rights, property, or safety of PGME, our users, or the public\n• Business Transfers: In connection with a merger, acquisition, or sale of assets, with appropriate notice to users',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '6. Permissions',
                          'The App requests the following device permissions:\n\n• Camera: Required for live Zoom video sessions\n• Microphone: Required for audio in live Zoom sessions\n• Location: Address auto-fill during profile setup (optional)\n• Storage: Downloading videos and documents for offline access\n• Notifications: Receiving class reminders and important updates\n• Bluetooth: Audio device connectivity during Zoom sessions\n• Internet: Core app functionality and content delivery\n\nAll permissions are requested at the time of use and can be managed through your device settings.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '7. Your Rights and Choices',
                          'You have the following rights regarding your personal information:\n\n• Access and Update: You can view and update your profile information at any time through the Edit Profile section in the App\n• Device Session Management: You can view all active sessions and remotely logout from any device through the App settings\n• Notification Preferences: You can manage notification preferences within the App settings or disable push notifications through your device settings\n• Location Access: You can enable or disable location access through your device settings at any time\n• Data Deletion: You may request complete deletion of your account and all associated personal data by contacting us. Upon receiving a valid deletion request, we will delete your personal data within 30 days, except where retention is required by law\n• Data Download: You may request a copy of your personal data in a portable format by contacting us',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '8. Children\'s Privacy',
                          'The App is not intended for use by individuals under the age of 18. We do not knowingly collect personal information from children under 18 years of age. If we become aware that we have collected personal information from a child under 18, we will take steps to delete such information promptly.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '9. Changes to This Privacy Policy',
                          'We may update this Privacy Policy from time to time. We will notify you of any material changes by:\n\n• Posting the updated Privacy Policy within the App\n• Sending a push notification about the update\n• Updating the "Last Updated" date at the top of this policy\n\nYour continued use of the App after any changes constitutes your acceptance of the updated Privacy Policy.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '10. Data Transfer',
                          'Your information may be transferred to and processed on servers located outside your country of residence. By using the App, you consent to the transfer of your information to facilities maintained by us or our third-party service providers, where applicable data protection laws may differ from those in your jurisdiction.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '11. Cookies and Tracking',
                          'The App itself does not use browser cookies. However, our integrated WebView-based payment gateway (Zoho Payments) may use cookies or similar technologies as necessary for secure payment processing.',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '12. Contact Us',
                          'If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us at:\n\nPGME (Post Graduate Medical Education)\nEmail: support@pgmemedicalteaching.com',
                          textColor,
                          secondaryTextColor,
                          isTablet: isTablet,
                        ),

                        _buildSection(
                          '13. Grievance Officer',
                          'In accordance with applicable regulations, the details of the Grievance Officer are as follows:\n\nName: [Grievance Officer Name]\nEmail: [grievance-officer-email@pgme.com]\nAddress: [Registered Office Address]\n\nResponse time: We will acknowledge your grievance within 24 hours and resolve it within 15 days from the date of receipt.',
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
