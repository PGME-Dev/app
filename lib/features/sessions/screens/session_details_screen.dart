import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class SessionDetailsScreen extends StatelessWidget {
  const SessionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final cardBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFE4F4FF);
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            SizedBox(height: topPadding),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Stack(
                children: [
                  // Back Arrow
                  Positioned(
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
                  Center(
                    child: SizedBox(
                      width: 144,
                      height: 20,
                      child: Text(
                        'Session Details',
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

            const SizedBox(height: 17),

            // Session Info Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: 361,
                height: 288,
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Course Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(27),
                      child: Image.asset(
                        'assets/illustrations/course.png',
                        width: 203,
                        height: 125,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 203,
                            height: 125,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(27),
                            ),
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 50,
                              color: iconColor,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    // LIVE SESSION label
                    Opacity(
                      opacity: 0.5,
                      child: SizedBox(
                        width: 89,
                        height: 20,
                        child: Text(
                          'LIVE SESSION',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            height: 2.0,
                            letterSpacing: 0.05,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    // Session Name
                    SizedBox(
                      width: 249,
                      height: 20,
                      child: Text(
                        'Name of the session topic',
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
                    const SizedBox(height: 9),
                    // Doctor Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Doctor Avatar
                        Container(
                          width: 19.43,
                          height: 18.92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/illustrations/doc.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 12,
                                  color: secondaryTextColor,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Dr. Aviraj',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 19),
                    // Badges Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LIVE NOW Badge
                        Container(
                          width: 93,
                          height: 22,
                          decoration: BoxDecoration(
                            color: iconColor,
                            borderRadius: BorderRadius.circular(41),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'LIVE NOW',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 90 MINUTES Badge
                        Container(
                          width: 93,
                          height: 22,
                          decoration: BoxDecoration(
                            color: iconColor,
                            borderRadius: BorderRadius.circular(41),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '90 MINUTES',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Meeting Access Title
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SizedBox(
                width: 152,
                height: 20,
                child: Text(
                  'Meeting Access',
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

            const SizedBox(height: 12),

            // Meeting Access Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: 361,
                height: 284,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x4D000000),
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 10,
                            spreadRadius: 4,
                            offset: Offset(0, 6),
                          ),
                        ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Platform
                      Opacity(
                        opacity: 0.5,
                        child: Text(
                          'PLATFORM',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Microsoft Teams',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Divider
                      Opacity(
                        opacity: 0.5,
                        child: Container(
                          width: 299,
                          height: 1,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Meeting ID and Passcode Row
                      Row(
                        children: [
                          // Meeting ID
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Text(
                                    'MEETING ID',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'xxxx-xxx-xxxxx-xxx',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Passcode
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Text(
                                    'PASSCODE',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'password',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Launch Meeting Button
                      Center(
                        child: Container(
                          width: 299,
                          height: 48,
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Center(
                            child: Text(
                              'LAUNCH MEETING',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                height: 1.11,
                                letterSpacing: 0.09,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Meeting Instructions Title
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SizedBox(
                width: 200,
                height: 20,
                child: Text(
                  'Meeting Instuctions',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    height: 1.0,
                    letterSpacing: -0.5,
                    color: textColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Meeting Instructions Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: 361,
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInstructionItem(
                        'Ensure your Student ID is visible in your profile name.',
                        textColor,
                        iconColor,
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                        'Mute your microphone upon entry to avoid echo in the OR.',
                        textColor,
                        iconColor,
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                        'Q&A session will follow the primary procedure.',
                        textColor,
                        iconColor,
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                        'Recording will be available 24 hours after the session',
                        textColor,
                        iconColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 120), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text, Color textColor, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.link,
          size: 20,
          color: iconColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Opacity(
            opacity: 0.5,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.43,
                letterSpacing: -0.5,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
