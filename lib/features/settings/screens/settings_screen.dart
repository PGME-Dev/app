import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : const Color(0xFFE4F4FF);
    final headerColor = isDark ? AppColors.darkSurface : Colors.white;
    final cardColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final dividerColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2D75DF);
    final toggleBgOff = isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE4F4FF);
    final toggleBgOn = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2D75DF);
    final toggleKnobColor = isDark ? Colors.white : const Color(0xFF000080);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 87 + topPadding,
            color: headerColor,
            child: Stack(
              children: [
                // Back Arrow
                Positioned(
                  top: topPadding + 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                // Title
                Positioned(
                  top: topPadding + 16,
                  left: 119,
                  child: SizedBox(
                    width: 155,
                    height: 20,
                    child: Text(
                      'System Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        height: 1.0,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Preferences Title
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 34),
                    child: Text(
                      'Preferences',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.25,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Preferences Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Dark Mode
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.dark_mode_outlined,
                                  size: 24,
                                  color: iconColor,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Dark Mode',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    themeProvider.toggleDarkMode();
                                  },
                                  child: Container(
                                    width: 54,
                                    height: 23.625,
                                    decoration: BoxDecoration(
                                      color: isDark ? toggleBgOn : toggleBgOff,
                                      borderRadius: BorderRadius.circular(43.88),
                                    ),
                                    child: AnimatedAlign(
                                      duration: const Duration(milliseconds: 200),
                                      alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        width: 18.5625,
                                        height: 18.5625,
                                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: toggleKnobColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 21),
                            child: Container(
                              height: 1,
                              color: dividerColor,
                            ),
                          ),
                          // Push Notifications
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.notifications_outlined,
                                  size: 24,
                                  color: iconColor,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Push Notifications',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _pushNotifications = !_pushNotifications;
                                    });
                                  },
                                  child: Container(
                                    width: 54,
                                    height: 23.625,
                                    decoration: BoxDecoration(
                                      color: _pushNotifications ? toggleBgOn : toggleBgOff,
                                      borderRadius: BorderRadius.circular(43.88),
                                    ),
                                    child: AnimatedAlign(
                                      duration: const Duration(milliseconds: 200),
                                      alignment: _pushNotifications ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        width: 18.5625,
                                        height: 18.5625,
                                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: toggleKnobColor,
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

                  const SizedBox(height: 34),

                  // Support Channels Title
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Support Channels',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.25,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Support Channels Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      height: 81,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: isDark
                            ? null
                            : const [
                                BoxShadow(
                                  color: Color(0x4D000000),
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                                BoxShadow(
                                  color: Color(0x26000000),
                                  blurRadius: 8,
                                  spreadRadius: 3,
                                  offset: Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/whatsapp_logo.png',
                              width: 30,
                              height: 30,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Whatsapp Support',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Message to get direct Assistance',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_back_ios,
                              size: 16,
                              color: textColor,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 34),

                  // Account Section Title
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Account',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.25,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Account Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // My Purchases
                          _buildLegalItem(
                            icon: Icons.shopping_bag_outlined,
                            title: 'My Purchases',
                            onTap: () {
                              context.push('/my-purchases');
                            },
                            textColor: textColor,
                            iconColor: iconColor,
                          ),
                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 21),
                            child: Container(
                              height: 1,
                              color: dividerColor,
                            ),
                          ),
                          // Join PGME - Careers
                          _buildLegalItem(
                            icon: Icons.work_outline,
                            title: 'Join PGME - Careers',
                            onTap: () {
                              context.push('/careers');
                            },
                            textColor: textColor,
                            iconColor: iconColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 34),

                  // Legal Compliances Title
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Legal Compliances',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.25,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Legal Compliances Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Terms And Conditions
                          _buildLegalItem(
                            icon: Icons.description_outlined,
                            title: 'Terms And Conditions',
                            onTap: () {},
                            textColor: textColor,
                            iconColor: iconColor,
                          ),
                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 21),
                            child: Container(
                              height: 1,
                              color: dividerColor,
                            ),
                          ),
                          // Privacy Policy
                          _buildLegalItem(
                            icon: Icons.security_outlined,
                            title: 'Privacy Policy',
                            onTap: () {},
                            textColor: textColor,
                            iconColor: iconColor,
                          ),
                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 21),
                            child: Container(
                              height: 1,
                              color: dividerColor,
                            ),
                          ),
                          // Refund Policy
                          _buildLegalItem(
                            icon: Icons.refresh,
                            title: 'Refund Policy',
                            onTap: () {},
                            textColor: textColor,
                            iconColor: iconColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom padding to prevent nav bar overlap
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: textColor,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
