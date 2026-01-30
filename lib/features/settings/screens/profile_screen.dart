import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/settings/screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final cardColor = isDark ? AppColors.darkCardBackground : const Color(0xFFE4F4FF);
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF888888);
    final iconBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final iconColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final dividerColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final borderColor = isDark ? AppColors.darkDivider : const Color(0x5C000080);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top curved box with profile info
            Container(
              width: double.infinity,
              height: 276,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                  bottomRight: Radius.circular(80),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 71),
                  // Profile picture circle
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: secondaryTextColor,
                        width: 3,
                      ),
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 40,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 31),
                  // Name
                  Text(
                    'Attharv Shrivastav',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      height: 20 / 18,
                      letterSpacing: -0.5,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  // Qualifications
                  Opacity(
                    opacity: 0.5,
                    child: Text(
                      'Qualifications',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 20 / 14,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Active Packages Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Packages',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 20 / 16,
                      letterSpacing: -0.5,
                      color: textColor,
                    ),
                  ),
                  Opacity(
                    opacity: 0.4,
                    child: Text(
                      'Upgrade',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 20 / 12,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 17),

            // Active Package Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 182,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A4D) : const Color(0xFF0000D1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 9),
                    // Current Plan Badge
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Text(
                          'CURRENT PLAN',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            height: 20 / 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Plan Name
                    const Padding(
                      padding: EdgeInsets.only(left: 17),
                      child: Text(
                        'CURRENT PLAN NAME',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 20 / 14,
                          letterSpacing: 0.07,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Opacity(
                        opacity: 0.4,
                        child: Container(
                          height: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    // Expires and Manage Row
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 26, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Expires info
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Opacity(
                                opacity: 0.5,
                                child: Text(
                                  'EXPIRES ON',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    height: 20 / 10,
                                    letterSpacing: 0.05,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                'Jan 25, 2026',
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                  height: 20 / 10,
                                  letterSpacing: 0.05,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          // Manage Button
                          GestureDetector(
                            onTap: () {
                              context.push('/manage-plans');
                            },
                            child: Container(
                              width: 97,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(
                                  'Manage',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    height: 20 / 14,
                                    letterSpacing: 0.07,
                                    color: isDark ? const Color(0xFF1A1A4D) : const Color(0xFF0000D1),
                                  ),
                                ),
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

            const SizedBox(height: 6),

            // Basic Information Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Basic Information',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 20 / 16,
                      letterSpacing: -0.5,
                      color: textColor,
                    ),
                  ),
                  Opacity(
                    opacity: 0.4,
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 20 / 12,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 9),

            // Basic Information Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Full Name
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'FULL NAME',
                      value: 'Attharv Shrivastav',
                      showDivider: true,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      iconBgColor: iconBgColor,
                      iconColor: iconColor,
                      dividerColor: dividerColor,
                    ),
                    // Email
                    _buildInfoRow(
                      icon: Icons.mail_outline,
                      label: 'EMAIL',
                      value: 'attharv21@gmail.com',
                      showDivider: true,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      iconBgColor: iconBgColor,
                      iconColor: iconColor,
                      dividerColor: dividerColor,
                    ),
                    // Phone Number
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'PHONE NUMBER',
                      value: '+91 9630000080',
                      showDivider: true,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      iconBgColor: iconBgColor,
                      iconColor: iconColor,
                      dividerColor: dividerColor,
                    ),
                    // Something Else
                    _buildInfoRow(
                      icon: null,
                      label: 'SOMETHING ELSE',
                      value: 'Khaksfhjak',
                      showDivider: false,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      iconBgColor: iconBgColor,
                      iconColor: iconColor,
                      dividerColor: dividerColor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Address Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Address',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 20 / 16,
                      letterSpacing: -0.5,
                      color: textColor,
                    ),
                  ),
                  Opacity(
                    opacity: 0.4,
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 20 / 12,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 9),

            // Address Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 107,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location icon circle
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconBgColor,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: iconColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Address text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'A-29 Chandra Nagar',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                height: 1.4,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'AB road, MR-9',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1.4,
                                color: textColor,
                              ),
                            ),
                            Row(
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Text(
                                    'Indore, MP',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      height: 1.4,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                                Text(
                                  '452010',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.4,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Log Out Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  // Navigate to login page
                  context.go('/login');
                },
                child: Container(
                  width: double.infinity,
                  height: 56.92,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(7.94),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      // Log out icon circle
                      Container(
                        width: 33.75,
                        height: 33.75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconBgColor,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.logout,
                            size: 15.88,
                            color: iconColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 17.2 / 14,
                          letterSpacing: 0.07,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Settings Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  // Navigate to settings screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56.92,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(7.94),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      // Settings icon circle
                      Container(
                        width: 33.75,
                        height: 33.75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconBgColor,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.settings_outlined,
                            size: 13,
                            color: iconColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 17.2 / 14,
                          letterSpacing: 0.07,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData? icon,
    required String label,
    required String value,
    required bool showDivider,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconBgColor,
    required Color iconColor,
    required Color dividerColor,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBgColor,
                ),
                child: icon != null
                    ? Center(
                        child: Icon(
                          icon,
                          size: 22,
                          color: iconColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Label and Value
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        height: 1.5,
                        color: secondaryTextColor,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.4,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: dividerColor,
            ),
          ),
      ],
    );
  }
}
