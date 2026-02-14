import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/utils/responsive_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class CareersScreen extends StatelessWidget {
  const CareersScreen({super.key});

  static const String _careersEmail = 'careers@pgme.in';

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);

    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFF5F7FA);
    final headerColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor =
        isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final cardColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final accentColor =
        isDark ? const Color(0xFF00BEFA) : const Color(0xFF0000C8);

    final hPadding = isTablet ? ResponsiveHelper.horizontalPadding(context) : 16.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            color: headerColor,
            padding: EdgeInsets.only(
                top: topPadding + (isTablet ? 20 : 16), bottom: isTablet ? 20 : 16, left: hPadding, right: hPadding),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(Icons.arrow_back, size: isTablet ? 30 : 24, color: textColor),
                ),
                const Spacer(),
                Text(
                  'Join PGME',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 25 : 20,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                SizedBox(width: isTablet ? 30 : 24),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(hPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxContentWidth(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isTablet ? 20 : 16),

                      // Hero section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 30 : 24),
                        decoration: BoxDecoration(
                          gradient: AppColors.blueGradient,
                          borderRadius: BorderRadius.circular(isTablet ? 21 : 16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.rocket_launch,
                                color: Colors.white, size: isTablet ? 50 : 40),
                            SizedBox(height: isTablet ? 20 : 16),
                            Text(
                              'Build the Future of\nMedical Education',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: isTablet ? 28 : 22,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: isTablet ? 10 : 8),
                            Text(
                              'Join our passionate team and help shape how the next generation of doctors learn.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: isTablet ? 17 : 14,
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isTablet ? 36 : 28),

                      // Why PGME section
                      Text(
                        'Why Join PGME?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 22 : 18,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: isTablet ? 20 : 16),

                      _buildBenefitCard(
                        icon: Icons.trending_up,
                        title: 'Impact at Scale',
                        description:
                            'Help thousands of medical students across India prepare for their postgraduate entrance exams.',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: accentColor,
                        isTablet: isTablet,
                      ),
                      _buildBenefitCard(
                        icon: Icons.people_outline,
                        title: 'Collaborative Culture',
                        description:
                            'Work with a team of educators, technologists, and healthcare professionals.',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: Colors.purple,
                        isTablet: isTablet,
                      ),
                      _buildBenefitCard(
                        icon: Icons.lightbulb_outline,
                        title: 'Innovation-Driven',
                        description:
                            'We embrace new ideas and cutting-edge technology to transform learning.',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: Colors.orange,
                        isTablet: isTablet,
                      ),
                      _buildBenefitCard(
                        icon: Icons.auto_graph,
                        title: 'Growth Opportunities',
                        description:
                            'Fast-growing startup with opportunities to learn, lead, and grow your career.',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: AppColors.success,
                        isTablet: isTablet,
                      ),

                      SizedBox(height: isTablet ? 36 : 28),

                      // Roles we hire for
                      Text(
                        'Roles We Hire For',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 22 : 18,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: isTablet ? 20 : 16),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 26 : 20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            _buildRoleRow('Faculty / Subject Experts',
                                Icons.school_outlined, textColor, secondaryTextColor, isTablet: isTablet),
                            Divider(color: borderColor, height: isTablet ? 30 : 24),
                            _buildRoleRow('Content Creators',
                                Icons.edit_outlined, textColor, secondaryTextColor, isTablet: isTablet),
                            Divider(color: borderColor, height: isTablet ? 30 : 24),
                            _buildRoleRow('Video Editors',
                                Icons.movie_outlined, textColor, secondaryTextColor, isTablet: isTablet),
                            Divider(color: borderColor, height: isTablet ? 30 : 24),
                            _buildRoleRow('App Developers',
                                Icons.code, textColor, secondaryTextColor, isTablet: isTablet),
                            Divider(color: borderColor, height: isTablet ? 30 : 24),
                            _buildRoleRow('Marketing & Growth',
                                Icons.campaign_outlined, textColor, secondaryTextColor, isTablet: isTablet),
                            Divider(color: borderColor, height: isTablet ? 30 : 24),
                            _buildRoleRow('Operations & Support',
                                Icons.support_agent_outlined, textColor, secondaryTextColor, isTablet: isTablet),
                          ],
                        ),
                      ),

                      SizedBox(height: isTablet ? 36 : 28),

                      // Contact section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 26 : 20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.mail_outline,
                                size: isTablet ? 50 : 40, color: accentColor),
                            SizedBox(height: isTablet ? 16 : 12),
                            Text(
                              'Interested? Get in Touch!',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 20 : 16,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: isTablet ? 10 : 8),
                            Text(
                              'Send your resume and a brief introduction to:',
                              style: TextStyle(
                                fontSize: isTablet ? 17 : 14,
                                color: secondaryTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isTablet ? 20 : 16),
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri(
                                  scheme: 'mailto',
                                  path: _careersEmail,
                                  queryParameters: {
                                    'subject': 'Career Inquiry - PGME',
                                  },
                                );
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 14),
                                decoration: BoxDecoration(
                                  gradient: AppColors.blueGradient,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.email_outlined,
                                        color: Colors.white, size: isTablet ? 25 : 20),
                                    SizedBox(width: isTablet ? 10 : 8),
                                    Text(
                                      _careersEmail,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: isTablet ? 19 : 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isTablet ? 150 : 120),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
    bool isTablet = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 55 : 44,
            height: isTablet ? 55 : 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isTablet ? 13 : 10),
            ),
            child: Icon(icon, color: iconColor, size: isTablet ? 30 : 24),
          ),
          SizedBox(width: isTablet ? 18 : 14),
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
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 13,
                    color: secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleRow(
      String role, IconData icon, Color textColor, Color secondaryTextColor, {bool isTablet = false}) {
    return Row(
      children: [
        Icon(icon, size: isTablet ? 25 : 20, color: secondaryTextColor),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Text(
            role,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: isTablet ? 17 : 14,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
