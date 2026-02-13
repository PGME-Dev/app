import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : const Color(0xFFF5F7FA);
    final headerBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF000000).withValues(alpha: 0.7);
    final cardBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final backButtonBgColor = isDark ? AppColors.darkBackground : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(top: topPadding + 16, left: 16, right: 16, bottom: 16),
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: backButtonBgColor,
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
                Expanded(
                  child: Text(
                    'Refund Policy',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
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
                top: 20,
                left: 16,
                right: 16,
                bottom: bottomPadding + 20,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Updated: February 13, 2026',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildSection(
                      'Overview',
                      'This Refund Policy outlines the terms and conditions for requesting refunds for subscriptions and purchases made through the PGME platform. We are committed to ensuring customer satisfaction while maintaining fair policies for all users.',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '1. Eligibility for Refunds',
                      'Refunds may be requested under the following circumstances:\n\n• Technical issues preventing access to purchased content\n• Duplicate payments or billing errors\n• Subscription purchased but not activated\n• Content significantly different from description\n\nRefund requests must be made within 7 days of purchase.',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '2. Non-Refundable Items',
                      'The following are NOT eligible for refunds:\n\n• Subscriptions after 7 days from purchase date\n• Partial refunds for used subscription periods\n• Subscriptions where significant content has been accessed (more than 20% of total content)\n• Live sessions already attended\n• Downloaded study materials\n• Promotional or discounted subscriptions (unless specifically stated)\n• Third-party products or services',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '3. Refund Request Process',
                      'To request a refund:\n\n1. Contact our support team through the app within 7 days of purchase\n2. Provide your transaction details and order ID\n3. Explain the reason for your refund request\n4. Allow 3-5 business days for review\n5. Receive notification of approval or denial\n6. If approved, refund will be processed within 7-10 business days',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '4. Refund Method',
                      'Approved refunds will be issued to the original payment method:\n\n• Credit/Debit Card: 7-10 business days\n• UPI/Net Banking: 5-7 business days\n• Wallet: 3-5 business days\n\nProcessing times may vary depending on your bank or payment provider.',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '5. Subscription Cancellation',
                      'You may cancel your subscription at any time:\n\n• Cancellation takes effect at the end of the current billing period\n• You will continue to have access until the subscription expires\n• No refunds for the remaining period after cancellation\n• You can resubscribe at any time',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '6. Technical Issues',
                      'If you experience technical difficulties:\n\n• Contact support immediately for assistance\n• We will attempt to resolve the issue within 48 hours\n• If the issue cannot be resolved, you may be eligible for a full refund\n• Refunds for technical issues are evaluated on a case-by-case basis',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '7. Billing Errors',
                      'In case of billing errors:\n\n• Duplicate charges will be refunded in full\n• Incorrect amounts will be corrected immediately\n• Processing fees (if any) will also be refunded\n• Refunds for billing errors are processed within 3-5 business days',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '8. Content Access After Refund',
                      'Upon approval of a refund:\n\n• Your access to the subscription content will be immediately revoked\n• Downloaded materials must be deleted\n• Any certificates or completion records may be invalidated\n• You will not be able to access live sessions or recordings',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '9. Promotional Offers and Discounts',
                      'Special terms for promotional subscriptions:\n\n• Discounted subscriptions are generally non-refundable\n• Free trial periods do not qualify for refunds\n• Bundle packages may have specific refund terms\n• Referral bonuses and credits are non-refundable',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '10. Denial of Refund Requests',
                      'Refund requests may be denied if:\n\n• Requested after the 7-day window\n• Significant content has been accessed\n• Terms of Service have been violated\n• Evidence of abuse or fraud\n• Incomplete or inaccurate information provided\n\nYou will be notified of the reason for denial.',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '11. Partial Refunds',
                      'In certain cases, partial refunds may be offered:\n\n• Based on unused portion of subscription\n• For technical issues affecting limited content\n• At our sole discretion on a case-by-case basis\n\nPartial refund calculations will be clearly explained.',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '12. Dispute Resolution',
                      'If you disagree with a refund decision:\n\n• You may appeal within 15 days of the decision\n• Provide additional information or documentation\n• Appeals will be reviewed by senior management\n• Final decisions will be communicated within 7 business days',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '13. Changes to Refund Policy',
                      'We reserve the right to modify this Refund Policy at any time. Changes will be effective immediately upon posting. Your continued use of the Platform constitutes acceptance of the updated policy.',
                      textColor,
                      secondaryTextColor,
                    ),

                    _buildSection(
                      '14. Contact Information',
                      'For refund requests or questions about this policy:\n\n• Use the support section in the app\n• Provide your transaction ID and order details\n• Allow 24-48 hours for initial response\n• Keep all communication records for reference',
                      textColor,
                      secondaryTextColor,
                    ),

                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1)).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please read this policy carefully before making a purchase. By completing a purchase, you acknowledge that you have read and agree to this Refund Policy.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: textColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildSection(String title, String content, Color titleColor, Color contentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.6,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }
}
