import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

/// The Terms & Conditions text, in one place.
///
/// Rendered both by the standalone settings page and by the checkout gate
/// sheet. Previously it lived privately inside the settings screen, so the
/// checkout flow had no way to show it — the checkbox there just linked away,
/// and users could accept without ever seeing the document. Mirrors the web
/// store's shared `TermsAndConditionsContent.jsx`.
class TermsContent {
  TermsContent._();

  static const String lastUpdated = 'Last Updated: February 23, 2026';

  /// iOS ships a reduced set: Apple's guidelines don't permit the
  /// refund/pricing/discount clauses to be surfaced in-app.
  static List<Map<String, String>> get sections =>
      Platform.isIOS ? _iosSections : _defaultSections;

  static const List<Map<String, String>> _defaultSections = [
    {
      'title': 'Welcome to PGME',
      'content':
          'These Terms and Conditions ("Terms") govern your access to and use of the PGME platform, including our mobile application and website (collectively, the "Platform"). By accessing or using the Platform, you agree to be bound by these Terms.',
    },
    {
      'title': '1. Acceptance of Terms',
      'content':
          'These Terms govern your use of the PGME platform, including mobile application and website.\nBy accessing or using the Platform, you agree to be legally bound by these Terms and our Refund Policy and Privacy Policy.\nIf you do not agree, you must discontinue use immediately.',
    },
    {
      'title': '2. Eligibility',
      'content':
          'You must be at least 18 years old and legally competent to enter into binding contracts under Indian law.',
    },
    {
      'title': '3. Account Registration',
      'content':
          'You are responsible for:\n\n• Maintaining confidentiality of login credentials\n• All activity under your account\n• Providing accurate information\n\nAccount sharing is strictly prohibited.\nPGME reserves the right to monitor usage patterns to detect unauthorized access.',
    },
    {
      'title': '4. Subscription & Payment',
      'content':
          'Access to paid content requires subscription.\n\nBy purchasing a subscription:\n\n• You agree to pay the listed fee\n• All prices are inclusive of applicable GST unless stated otherwise\n• Payments are non-refundable as per Refund Policy\n• Subscriptions are non-transferable and non-resalable\n\nIf applicable, subscription renewals will occur automatically unless cancelled before renewal date.',
    },
    {
      'title': '5. Intellectual Property',
      'content':
          'All content is the exclusive property of PGME MEDICAL EDUCATION LLP.\n\nYou are granted a limited, non-exclusive, non-transferable license for personal academic use only.\n\nYou may not:\n\n• Copy\n• Record\n• Screen capture\n• Share\n• Redistribute\n• Commercially exploit\n\nViolation may result in:\n\n• Immediate termination\n• Legal action\n• Permanent access ban\n• No refund',
    },
    {
      'title': '6. Prohibited Conduct',
      'content':
          'You shall not:\n\n• Attempt unauthorized access\n• Reverse engineer the platform\n• Circumvent security mechanisms\n• Engage in chargeback abuse\n• Upload malicious content',
    },
    {
      'title': '7. Live Sessions',
      'content':
          'PGME may:\n\n• Schedule or reschedule sessions\n• Record sessions\n• Modify faculty or content\n• Remove disruptive participants\n\nNo refund shall be issued due to scheduling changes.',
    },
    {
      'title': '8. Disclaimer',
      'content':
          'The Platform is provided "as is."\n\nPGME does not guarantee:\n\n• Uninterrupted access\n• Error-free service\n• Exam success\n• Professional outcomes\n\nEducational content is for academic assistance only.',
    },
    {
      'title': '9. Limitation of Liability',
      'content':
          'To the maximum extent permitted by law:\n\n• PGME shall not be liable for indirect or consequential damages\n• Total liability shall not exceed the amount paid for the relevant subscription\n• PGME is not liable for third-party payment gateway or banking issues',
    },
    {
      'title': '10. Indemnification',
      'content':
          'You agree to indemnify and hold harmless PGME from any claims, damages, losses, or expenses arising from:\n\n• Violation of these Terms\n• Unauthorized content sharing\n• Fraudulent payment disputes\n• Misuse of the Platform',
    },
    {
      'title': '11. Suspension & Termination',
      'content':
          'PGME may suspend or terminate accounts for:\n\n• Policy violations\n• Fraud\n• Unauthorized sharing\n• Chargeback abuse\n\nNo refund shall be granted in such cases.',
    },
    {
      'title': '12. Force Majeure',
      'content':
          'PGME shall not be liable for delays or failures caused by events beyond reasonable control, including but not limited to:\n\n• Natural disasters\n• Government restrictions\n• Internet or server failures\n• Power outages',
    },
    {
      'title': '13. Governing Law & Jurisdiction',
      'content':
          'These Terms shall be governed by the laws of India.\nAll disputes shall be subject to the exclusive jurisdiction of courts located in Jalandhar, Punjab.',
    },
    {
      'title': '14. Examinee Policy',
      'content':
          'Participation is subject to eligibility and compliance with all guidelines shared during registration.\nAttendance, timely submission of required materials, and professional conduct are mandatory.\nAny misconduct or violation of guidelines may lead to removal without refund.\nAccess is restricted to the registered examinee only; sharing credentials is strictly prohibited.\nAll session content, including recordings, remains the intellectual property of PGME and must not be shared or reproduced.\nPGME is not liable for technical or connectivity issues at the participant\'s end.',
    },
    {
      'title': '15. Examiner Policy',
      'content':
          'Participation is subject to adherence to all guidelines shared during onboarding and form submission.\nExaminers are expected to maintain professional conduct throughout all sessions.\nAll session content, including recordings, remains the intellectual property of PGME and must not be shared or reproduced.\nAccess is restricted to the registered examiner only; sharing credentials is strictly prohibited.\nPGME is not liable for technical or connectivity issues at the participant\'s end.',
    },
    {
      'title': '16. eBook Policy',
      'content':
          'The eBook is available exclusively within the app for reading and in-app download only.\nNo PDF, external soft copy, or hard copy will be provided.\nAccess is strictly limited to the registered user for personal academic use.\nNo refund will be provided if the eBook is already included in a purchased package.\nAny technical issue must be reported within 72 hours of purchase; no claims will be entertained thereafter.',
    },
    {
      'title': '17. Pricing Policy',
      'content':
          'The pricing of all products and services offered by PGME is an internal matter and is determined solely at the discretion of PGME. PGME reserves the full right to revise, modify, or update the pricing of any product or service at any time without prior notice.',
    },
    {
      'title': '18. Discount Policy',
      'content':
          'All discounts, promotional offers, and coupon benefits are subject to the sole discretion of PGME. PGME reserves the right to introduce, modify, or withdraw any discount or promotional offer at any time without prior notice.',
    },
    {
      'title': '19. Modifications',
      'content':
          'PGME may modify these Terms at any time. Continued use constitutes acceptance of revised Terms.',
    },
    {
      'title': '20. Contact',
      'content': 'Email: support@pgmemedicalteaching.com',
    },
  ];

  static const List<Map<String, String>> _iosSections = [
    {
      'title': 'Welcome to PGME',
      'content':
          'These Terms and Conditions ("Terms") govern your access to and use of the PGME platform, including our mobile application and website (collectively, the "Platform"). By accessing or using the Platform, you agree to be bound by these Terms.',
    },
    {
      'title': '1. Acceptance of Terms',
      'content':
          'These Terms govern your use of the PGME platform, including mobile application and website.\nBy accessing or using the Platform, you agree to be legally bound by these Terms and our Privacy Policy.\nIf you do not agree, you must discontinue use immediately.',
    },
    {
      'title': '2. Eligibility',
      'content':
          'You must be at least 18 years old and legally competent to enter into binding contracts under Indian law.',
    },
    {
      'title': '3. Account Registration',
      'content':
          'You are responsible for:\n\n• Maintaining confidentiality of login credentials\n• All activity under your account\n• Providing accurate information\n\nAccount sharing is strictly prohibited.\nPGME reserves the right to monitor usage patterns to detect unauthorized access.',
    },
    {
      'title': '4. Intellectual Property',
      'content':
          'All content is the exclusive property of PGME MEDICAL EDUCATION LLP.\n\nYou are granted a limited, non-exclusive, non-transferable license for personal academic use only.\n\nYou may not:\n\n• Copy\n• Record\n• Screen capture\n• Share\n• Redistribute\n• Commercially exploit\n\nViolation may result in:\n\n• Immediate termination\n• Legal action\n• Permanent access ban',
    },
    {
      'title': '5. Prohibited Conduct',
      'content':
          'You shall not:\n\n• Attempt unauthorized access\n• Reverse engineer the platform\n• Circumvent security mechanisms\n• Upload malicious content',
    },
    {
      'title': '6. Live Sessions',
      'content':
          'PGME may:\n\n• Schedule or reschedule sessions\n• Record sessions\n• Modify faculty or content\n• Remove disruptive participants',
    },
    {
      'title': '7. Disclaimer',
      'content':
          'The Platform is provided "as is."\n\nPGME does not guarantee:\n\n• Uninterrupted access\n• Error-free service\n• Exam success\n• Professional outcomes\n\nEducational content is for academic assistance only.',
    },
    {
      'title': '8. Limitation of Liability',
      'content':
          'To the maximum extent permitted by law:\n\n• PGME shall not be liable for indirect or consequential damages',
    },
    {
      'title': '9. Indemnification',
      'content':
          'You agree to indemnify and hold harmless PGME from any claims, damages, losses, or expenses arising from:\n\n• Violation of these Terms\n• Unauthorized content sharing\n• Misuse of the Platform',
    },
    {
      'title': '10. Suspension & Termination',
      'content':
          'PGME may suspend or terminate accounts for:\n\n• Policy violations\n• Fraud\n• Unauthorized sharing',
    },
    {
      'title': '11. Force Majeure',
      'content':
          'PGME shall not be liable for delays or failures caused by events beyond reasonable control, including but not limited to:\n\n• Natural disasters\n• Government restrictions\n• Internet or server failures\n• Power outages',
    },
    {
      'title': '12. Governing Law & Jurisdiction',
      'content':
          'These Terms shall be governed by the laws of India.\nAll disputes shall be subject to the exclusive jurisdiction of courts located in Jalandhar, Punjab.',
    },
    {
      'title': '13. Examinee Policy',
      'content':
          'Participation is subject to eligibility and compliance with all guidelines shared during registration.\nAttendance, timely submission of required materials, and professional conduct are mandatory.\nAny misconduct or violation of guidelines may lead to removal without refund.\nAccess is restricted to the registered examinee only; sharing credentials is strictly prohibited.\nAll session content, including recordings, remains the intellectual property of PGME and must not be shared or reproduced.\nPGME is not liable for technical or connectivity issues at the participant\'s end.',
    },
    {
      'title': '14. Examiner Policy',
      'content':
          'Participation is subject to adherence to all guidelines shared during onboarding and form submission.\nExaminers are expected to maintain professional conduct throughout all sessions.\nAll session content, including recordings, remains the intellectual property of PGME and must not be shared or reproduced.\nAccess is restricted to the registered examiner only; sharing credentials is strictly prohibited.\nPGME is not liable for technical or connectivity issues at the participant\'s end.',
    },
    {
      'title': '15. eBook Policy',
      'content':
          'The eBook is available exclusively within the app for reading and in-app download only.\nNo PDF, external soft copy, or hard copy will be provided.\nAccess is strictly limited to the registered user for personal academic use.\nNo refund will be provided if the eBook is already included in a purchased package.\nAny technical issue must be reported within 72 hours of purchase; no claims will be entertained thereafter.',
    },
    {
      'title': '16. Modifications',
      'content':
          'PGME may modify these Terms at any time. Continued use constitutes acceptance of revised Terms.',
    },
    {
      'title': '17. Contact',
      'content': 'Email: support@pgmemedicalteaching.com',
    },
  ];
}

/// Renders the terms body — the "Last Updated" line followed by every section.
///
/// Layout-agnostic on purpose: it carries no scroll view, padding shell, or
/// card, so the settings page can wrap it in its card and the checkout gate
/// sheet can put it inside a scroll view it controls.
class TermsAndConditionsContent extends StatelessWidget {
  const TermsAndConditionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);

    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textPrimary.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TermsContent.lastUpdated,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isTablet ? 15 : 12,
            fontStyle: FontStyle.italic,
            color: secondaryTextColor,
          ),
        ),
        SizedBox(height: isTablet ? 26 : 20),
        ...TermsContent.sections.map(
          (section) => _buildSection(
            section['title']!,
            section['content']!,
            textColor,
            secondaryTextColor,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    String title,
    String content,
    Color titleColor,
    Color contentColor, {
    bool isTablet = false,
  }) {
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
