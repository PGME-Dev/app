import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class CareersScreen extends StatelessWidget {
  const CareersScreen({super.key});

  static const String _careersEmail = 'careers@pgme.in';

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            color: headerColor,
            padding: EdgeInsets.only(
                top: topPadding + 16, bottom: 16, left: 16, right: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(Icons.arrow_back, size: 24, color: textColor),
                ),
                const Spacer(),
                Text(
                  'Join PGME',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 24),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Hero section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.blueGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.rocket_launch,
                            color: Colors.white, size: 40),
                        const SizedBox(height: 16),
                        const Text(
                          'Build the Future of\nMedical Education',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join our passionate team and help shape how the next generation of doctors learn.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Why PGME section
                  Text(
                    'Why Join PGME?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

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
                  ),

                  const SizedBox(height: 28),

                  // Roles we hire for
                  Text(
                    'Roles We Hire For',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildRoleRow('Faculty / Subject Experts',
                            Icons.school_outlined, textColor, secondaryTextColor),
                        Divider(color: borderColor, height: 24),
                        _buildRoleRow('Content Creators',
                            Icons.edit_outlined, textColor, secondaryTextColor),
                        Divider(color: borderColor, height: 24),
                        _buildRoleRow('Video Editors',
                            Icons.movie_outlined, textColor, secondaryTextColor),
                        Divider(color: borderColor, height: 24),
                        _buildRoleRow('App Developers',
                            Icons.code, textColor, secondaryTextColor),
                        Divider(color: borderColor, height: 24),
                        _buildRoleRow('Marketing & Growth',
                            Icons.campaign_outlined, textColor, secondaryTextColor),
                        Divider(color: borderColor, height: 24),
                        _buildRoleRow('Operations & Support',
                            Icons.support_agent_outlined, textColor, secondaryTextColor),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Contact section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.mail_outline,
                            size: 40, color: accentColor),
                        const SizedBox(height: 12),
                        Text(
                          'Interested? Get in Touch!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send your resume and a brief introduction to:',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: AppColors.blueGradient,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.email_outlined,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  _careersEmail,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
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

                  const SizedBox(height: 120),
                ],
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
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
      String role, IconData icon, Color textColor, Color secondaryTextColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: secondaryTextColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            role,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
