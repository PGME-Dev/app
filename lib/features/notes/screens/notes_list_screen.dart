import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class NotesListScreen extends StatefulWidget {
  final bool isSubscribed;

  const NotesListScreen({
    super.key,
    this.isSubscribed = false,
  });

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back arrow, title, and search
            Padding(
              padding: EdgeInsets.only(top: topPadding + 16, left: 16, right: 16),
              child: Row(
                children: [
                  // Back Arrow - navigates to home
                  GestureDetector(
                    onTap: () {
                      // Navigate back to home tab
                      context.go('/home?subscribed=${widget.isSubscribed}');
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
                  const Spacer(),
                  // Title
                  Text(
                    'My Enrolled Courses',
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
                  const Spacer(),
                  // Search icon
                  GestureDetector(
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
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Show different content based on subscription status
            if (widget.isSubscribed)
              _buildSubscribedContent(isDark, textColor, secondaryTextColor, iconColor)
            else
              _buildGuestContent(context, isDark, textColor, secondaryTextColor, iconColor),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  // Guest content - Free samples
  Widget _buildGuestContent(BuildContext context, bool isDark, Color textColor, Color secondaryTextColor, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Two Gradient Boxes Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Lecture Box
              _buildLectureBox(context, isSubscribed: widget.isSubscribed, isDark: isDark),
              const SizedBox(width: 12),
              // Notes Box
              _buildNotesBox(context, isSubscribed: widget.isSubscribed, isDark: isDark),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Subject Title Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                'Inclusions',
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
              _buildInclusionItem('Ensure your Student ID is visible in your profile name.', textColor, iconColor),
              const SizedBox(height: 12),
              _buildInclusionItem('Mute your microphone upon entry to avoid echo in the OR.', textColor, iconColor),
              const SizedBox(height: 12),
              _buildInclusionItem('Q&A session will follow the primary procedure.', textColor, iconColor),
              const SizedBox(height: 12),
              _buildInclusionItem('Recording will be available 24 hours after the session', textColor, iconColor),
            ],
          ),
        ),
      ],
    );
  }

  // Subscribed content - Same layout as guest, just different box text
  Widget _buildSubscribedContent(bool isDark, Color textColor, Color secondaryTextColor, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Two Gradient Boxes Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Lecture Box
              _buildLectureBox(context, isSubscribed: true, isDark: isDark),
              const SizedBox(width: 12),
              // Notes Box
              _buildNotesBox(context, isSubscribed: true, isDark: isDark),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Subject Title Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
              _buildInclusionItem('Ensure your Student ID is visible in your profile name.', textColor, iconColor),
              const SizedBox(height: 12),
              _buildInclusionItem('Mute your microphone upon entry to avoid echo in the OR.', textColor, iconColor),
              const SizedBox(height: 12),
              _buildInclusionItem('Q&A session will follow the primary procedure.', textColor, iconColor),
              const SizedBox(height: 12),
              _buildInclusionItem('Recording will be available 24 hours after the session', textColor, iconColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLectureBox(BuildContext context, {required bool isSubscribed, required bool isDark}) {
    final titleText = isSubscribed ? 'Watch Lecture\nVideo' : 'Free Sample\nLecture';
    final buttonText = isSubscribed ? 'Watch' : 'Check Out';
    final buttonBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final buttonTextColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);

    return Expanded(
      child: Container(
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
                titleText,
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
            // 3.png Image
            Positioned(
              bottom: -65,
              left: 0,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/illustrations/3.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(width: 250, height: 250);
                  },
                ),
              ),
            ),
            // Button
            Positioned(
              top: 84,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  // Navigate to lecture video for subscribed, sample lecture for guests
                  if (isSubscribed) {
                    context.push('/lecture/1?subscribed=true');
                  } else {
                    context.push('/lecture/sample');
                  }
                },
                child: Container(
                  width: 92,
                  height: 27,
                  decoration: BoxDecoration(
                    color: buttonBgColor,
                    borderRadius: BorderRadius.circular(10.87),
                  ),
                  child: Center(
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 16.73 / 14,
                        letterSpacing: -0.42,
                        color: buttonTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesBox(BuildContext context, {required bool isSubscribed, required bool isDark}) {
    final titleText = isSubscribed ? 'View\nNotes' : 'Free Sample\nNotes';
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Navigate to available notes for both subscribed and guests
          if (isSubscribed) {
            context.push('/available-notes/1');
          } else {
            context.push('/available-notes/sample');
          }
        },
        child: Container(
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
                              color: iconColor,
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
                  titleText,
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
      ),
    );
  }

  Widget _buildInclusionItem(String text, Color textColor, Color iconColor) {
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
