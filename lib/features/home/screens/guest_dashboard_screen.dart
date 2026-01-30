import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class GuestDashboardScreen extends StatelessWidget {
  const GuestDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFDCEAF7);
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: EdgeInsets.only(top: topPadding + 16, left: 23, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hello text and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Aviraj!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                            height: 20 / 22,
                            letterSpacing: -0.5,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Opacity(
                          opacity: 0.4,
                          child: Text(
                            'What do you want to learn today?',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.05,
                              letterSpacing: -1,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Get Help Button and Notification
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Open WhatsApp support
                        },
                        child: Container(
                          width: 103,
                          height: 31,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF138808),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Get Help',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  height: 20 / 14,
                                  letterSpacing: -0.5,
                                  color: Color(0xFF138808),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Image.asset(
                                'assets/icons/whatsapp_logo.png',
                                width: 20,
                                height: 20,
                                color: const Color(0xFF138808),
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.chat,
                                    size: 18,
                                    color: Color(0xFF138808),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Notification Icon
                      GestureDetector(
                        onTap: () {
                          // Open notifications
                        },
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 24,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Live Class Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: Container(
                width: double.infinity,
                height: 135,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: const Alignment(-0.85, 0),
                    end: const Alignment(0.85, 0),
                    colors: isDark
                        ? [const Color(0xFF0D2A5C), const Color(0xFF1A5A9E)]
                        : [const Color(0xFF1847A2), const Color(0xFF8EC6FF)],
                    stops: const [0.3469, 0.7087],
                  ),
                ),
                child: Stack(
                  children: [
                    // Image on right
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(24),
                        ),
                        child: Image.asset(
                          'assets/illustrations/home.png',
                          width: 161,
                          height: 83,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(width: 161, height: 83);
                          },
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.only(left: 13, top: 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Live Class Badge
                          Container(
                            width: 76,
                            height: 19,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(7.15),
                            ),
                            child: const Center(
                              child: Text(
                                'LIVE CLASS',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11.62,
                                  height: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Title
                          const Text(
                            'Advanced Neuro Surgery',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Subtitle
                          const Text(
                            'Starts Today - 7:00 PM',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Buttons
                          Row(
                            children: [
                              Container(
                                width: 84,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Join Live',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      height: 1.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 9),
                              GestureDetector(
                                onTap: () {
                                  context.push('/session-details');
                                },
                                child: Container(
                                  width: 98,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurface : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'View Details',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13,
                                        height: 1.0,
                                        color: isDark ? const Color(0xFF00BEFA) : AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
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

            const SizedBox(height: 24),

            // Subject Section Header
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subject',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      height: 20 / 18,
                      letterSpacing: -0.5,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Browse All',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Subject Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'Community Medicine',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 20 / 16,
                    letterSpacing: -0.5,
                    color: textColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // What we offer Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'What we offer',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      height: 20 / 18,
                      letterSpacing: -0.5,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Browse All',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Package Cards Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Practical Package Card
                  Expanded(
                    child: _buildPackageCard(
                      context: context,
                      title: 'Practical Package',
                      isDark: isDark,
                      cardBgColor: cardBgColor,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      iconColor: iconColor,
                      onEnroll: () {
                        context.push('/purchase');
                      },
                      onViewPackage: () {
                        context.push('/practical-packages');
                      },
                    ),
                  ),
                  const SizedBox(width: 9),
                  // Theory Package Card
                  Expanded(
                    child: _buildPackageCard(
                      context: context,
                      title: 'Theory Package',
                      isDark: isDark,
                      cardBgColor: cardBgColor,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      iconColor: iconColor,
                      onEnroll: () {
                        context.push('/purchase');
                      },
                      onViewPackage: () {
                        context.push('/revision-series');
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Your Faculty Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Faculty',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Browse All',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Faculty Cards
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildFacultyCard(index, isDark, cardBgColor, textColor, borderColor);
                },
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard({
    required BuildContext context,
    required String title,
    required bool isDark,
    required Color cardBgColor,
    required Color surfaceColor,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onEnroll,
    required VoidCallback onViewPackage,
  }) {
    final buttonBgColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);
    final viewButtonBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final viewButtonTextColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF0000D1);

    return Container(
      height: 376,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // White box with play button
          Container(
            width: 142,
            height: 244,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: _buildPlayButton(isDark, textColor, surfaceColor),
            ),
          ),
          const SizedBox(height: 9),
          // Package Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 20 / 16,
                letterSpacing: -0.5,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 11),
          // Enroll Now Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: GestureDetector(
              onTap: onEnroll,
              child: Container(
                width: double.infinity,
                height: 26,
                decoration: BoxDecoration(
                  color: buttonBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Enroll Now',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          // View Package Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: GestureDetector(
              onTap: onViewPackage,
              child: Container(
                width: double.infinity,
                height: 26,
                decoration: BoxDecoration(
                  color: viewButtonBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'View',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 1.0,
                      color: viewButtonTextColor,
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

  Widget _buildPlayButton(bool isDark, Color textColor, Color surfaceColor) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: surfaceColor,
        shape: BoxShape.circle,
        border: Border.all(color: textColor, width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.play_arrow,
          size: 24,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildFacultyCard(int index, bool isDark, Color cardBgColor, Color textColor, Color borderColor) {
    return Container(
      width: 140,
      height: 148,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          // Doctor image
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/illustrations/doc.png',
              width: 88,
              height: 81,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 88,
                  height: 81,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF999999),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Name
          Text(
            'Dr. Name LastName',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Specialty
          Opacity(
            opacity: 0.5,
            child: Text(
              'Community Medicine',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
