import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
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
                    width: 358,
                    height: 135,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: const Alignment(-0.85, 0),
                        end: const Alignment(0.85, 0),
                        colors: isDark
                            ? [const Color(0xFF0D2A5C), const Color(0xFF2D5A9E)]
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
                                      color: const Color(0xFF2470E4),
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
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'View Details',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 13,
                                            height: 1.0,
                                            color: AppColors.primaryBlue,
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

                // For You Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'For You',
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

                // For You Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resume Card (Left - Tall)
                      _buildResumeCard(isDark, textColor),
                      const SizedBox(width: 9),
                      // Right Column - Theory and Practical
                      Column(
                        children: [
                          _buildTheoryCard(context, isDark, textColor),
                          const SizedBox(height: 9),
                          _buildPracticalCard(context, isDark, textColor),
                        ],
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
                      return _buildFacultyCard(index, isDark, textColor, cardBgColor);
                    },
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeCard(bool isDark, Color textColor) {
    return Container(
      width: 176,
      height: 281,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: const Alignment(-0.5, -0.5),
          end: const Alignment(0.5, 0.5),
          colors: isDark
              ? [const Color(0xFF1A3A5C), const Color(0xFF2D5A9E)]
              : [const Color(0xFFCDE5FF), const Color(0xFF8FC6FF)],
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESUME',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Continue where\nyou left off',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    height: 1.3,
                    color: isDark ? Colors.white : const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anatomy -Heart\nValves',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.3,
                    color: isDark ? const Color(0xFF00BEFA) : AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          // Play button and time
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              '45 Min Left',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF000000),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 16,
            child: _buildPlayButton(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryCard(BuildContext context, bool isDark, Color textColor) {
    return GestureDetector(
      onTap: () {
        // Navigate to theory/revision series (unlocked)
        context.push('/revision-series?subscribed=true');
      },
      child: Container(
        width: 173,
        height: 137,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: const Alignment(-0.5, -0.5),
            end: const Alignment(0.8, 0.8),
            colors: isDark
                ? [const Color(0xFF1A3A5C), const Color(0xFF2D5A9E)]
                : [const Color(0xFFCDE5FF), const Color(0xFF8FC6FF)],
            stops: const [0.1132, 0.9348],
          ),
        ),
        child: Stack(
          children: [
            // Image
            Positioned(
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(13),
                ),
                child: Image.asset(
                  'assets/illustrations/1.png',
                  width: 101,
                  height: 78,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(width: 101, height: 78);
                  },
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THEORY',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View Classes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),
            // Play button
            Positioned(
              bottom: 12,
              right: 12,
              child: _buildPlayButton(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticalCard(BuildContext context, bool isDark, Color textColor) {
    return GestureDetector(
      onTap: () {
        // Navigate to practical packages to show sessions list
        context.push('/practical-packages?subscribed=true');
      },
      child: Container(
        width: 173,
        height: 135,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: const Alignment(-0.5, -0.5),
            end: const Alignment(0.8, 0.8),
            colors: isDark
                ? [const Color(0xFF1A3A5C), const Color(0xFF2D5A9E)]
                : [const Color(0xFFCDE5FF), const Color(0xFF8EC6FF)],
            stops: const [0.0689, 0.899],
          ),
        ),
        child: Stack(
          children: [
            // Image
            Positioned(
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(14),
                ),
                child: Image.asset(
                  'assets/illustrations/2.png',
                  width: 123,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(width: 123, height: 85);
                  },
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRACTICAL',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View Classes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),
            // Play button
            Positioned(
              bottom: 12,
              right: 12,
              child: _buildPlayButton(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(bool isDark) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF000000),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.play_arrow,
          size: 18,
          color: isDark ? Colors.white : const Color(0xFF000000),
        ),
      ),
    );
  }

  Widget _buildFacultyCard(int index, bool isDark, Color textColor, Color cardBgColor) {
    return Container(
      width: 140,
      height: 148,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0),
          width: 1,
        ),
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
                    color: isDark ? AppColors.darkSurface : const Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: isDark ? AppColors.darkTextTertiary : const Color(0xFF999999),
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
        ],
      ),
    );
  }
}
