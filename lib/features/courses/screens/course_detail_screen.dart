import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF718BA9);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Back Arrow - goes back to previous screen
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

          // Title "TECOM REVISION SERIES I"
          Positioned(
            top: topPadding + 16,
            left: 80,
            child: SizedBox(
              width: 234,
              height: 20,
              child: Text(
                _getSeriesTitle(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.0,
                  letterSpacing: -0.5,
                  color: textColor,
                ),
              ),
            ),
          ),

          // Search icon
          Positioned(
            top: topPadding + 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                // Search functionality
              },
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  Icons.search,
                  size: 24,
                  color: textColor,
                ),
              ),
            ),
          ),

          // Two Gradient Boxes Row
          Positioned(
            top: topPadding + 60,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Watch Lectures Video Box
                _buildWatchLecturesBox(context, isDark),
                const SizedBox(width: 12),
                // View Notes Box
                _buildViewNotesBox(context, isDark),
              ],
            ),
          ),

          // Subject Title Section
          Positioned(
            top: topPadding + 290,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject Title',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    height: 1.0,
                    letterSpacing: -0.5,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'aliqua dolor proident exercitation cillum exercitation laboris voluptate ea reprehenderit eu consequat pariatur qui eu aliqua dolor proident exercitation cillum exercitation laboris voluptate ea reprehenderit eu consequat pariatur qui eu',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.5,
                    letterSpacing: 0,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Details',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    height: 1.0,
                    letterSpacing: -0.5,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailItem('Ensure your Student ID is visible in your profile name.', textColor, iconColor),
                const SizedBox(height: 12),
                _buildDetailItem('Mute your microphone upon entry to avoid echo in the OR.', textColor, iconColor),
                const SizedBox(height: 12),
                _buildDetailItem('Q&A session will follow the primary procedure.', textColor, iconColor),
                const SizedBox(height: 12),
                _buildDetailItem('Recording will be available 24 hours after the session', textColor, iconColor),
              ],
            ),
          ),

        ],
      ),
    );
  }

  String _getSeriesTitle() {
    // Handle practical session courses
    if (courseId.startsWith('practical-')) {
      final number = courseId.replaceFirst('practical-', '');
      switch (number) {
        case '1':
          return 'PRACTICAL SESSION I';
        case '2':
          return 'PRACTICAL SESSION II';
        case '3':
          return 'PRACTICAL SESSION III';
        case '4':
          return 'PRACTICAL SESSION IV';
        default:
          return 'PRACTICAL SESSION $number';
      }
    }

    // Handle TECOM revision series
    switch (courseId) {
      case '1':
        return 'TECOM REVISION SERIES I';
      case '2':
        return 'TECOM REVISION SERIES II';
      case '3':
        return 'TECOM REVISION SERIES III';
      case '4':
        return 'TECOM REVISION SERIES IV';
      default:
        return 'TECOM REVISION SERIES $courseId';
    }
  }

  Widget _buildWatchLecturesBox(BuildContext context, bool isDark) {
    return Container(
      width: 175,
      height: 211,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: const Alignment(-0.7, 0.7),
          end: const Alignment(0.7, -0.7),
          colors: isDark
              ? [const Color(0xFF1A3A5C), const Color(0xFF2D5A9E)]
              : [const Color(0xFFEBF3FC), const Color(0xFF8EC6FF)],
          stops: const [0.1752, 0.8495],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Title text
          Positioned(
            top: 20,
            left: 16,
            child: Text(
              'Watch Lectures\nVideo',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 1.3,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : const Color(0xFF000000),
              ),
            ),
          ),
          // 3.png Image (placed before button so button is on top)
          Positioned(
            bottom: -65,
            left: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/illustrations/3.png',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Watch Button (last so it's on top)
          Positioned(
            top: 84,
            left: 10,
            child: GestureDetector(
              onTap: () {
                context.push('/lecture/$courseId');
              },
              child: Container(
                width: 92,
                height: 27,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(10.87),
                ),
                child: Center(
                  child: Text(
                    'Watch',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 16.73 / 14,
                      letterSpacing: -0.42,
                      color: isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4),
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

  Widget _buildViewNotesBox(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        context.push('/available-notes/$courseId');
      },
      child: Container(
        width: 175,
        height: 211,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: const Alignment(-0.7, 0.7),
            end: const Alignment(0.7, -0.7),
            colors: isDark
                ? [const Color(0xFF1A3A5C), const Color(0xFF2D5A9E)]
                : [const Color(0xFFEBF3FC), const Color(0xFF8EC6FF)],
            stops: const [0.1752, 0.8495],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 4.png Image (flipped horizontally) - placed first so title is on top
            Positioned(
              top: -35,
              right: -145,
              child: IgnorePointer(
                child: Transform.flip(
                  flipX: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/illustrations/4.png',
                      width: 400,
                      height: 400,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 163,
                          height: 114,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.folder_outlined,
                            size: 40,
                            color: isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Title text
            Positioned(
              top: 20,
              left: 16,
              child: Text(
                'View Notes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  height: 1.3,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF000000),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String text, Color textColor, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.link,
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.4,
              letterSpacing: 0,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

}
