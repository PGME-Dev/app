import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/models/video_model.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

class ForYouSection extends StatelessWidget {
  final VideoModel? lastWatched;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final bool hasTheorySubscription;
  final bool hasPracticalSubscription;

  const ForYouSection({
    super.key,
    this.lastWatched,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.hasTheorySubscription = false,
    this.hasPracticalSubscription = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final isTablet = ResponsiveHelper.isTablet(context);

    final sectionTitleSize = isTablet ? 24.0 : 20.0;
    final hPadding = isTablet ? ResponsiveHelper.horizontalPadding(context) : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? ResponsiveHelper.maxContentWidth : double.infinity,
              ),
              child: Text(
                'For You',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: sectionTitleSize,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Content - Responsive layout
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? ResponsiveHelper.maxContentWidth : double.infinity,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  const gap = 9.0;
                  // Left card takes ~49% of available width, right column takes ~51%
                  final resumeCardWidth = (availableWidth - gap) * 0.49;
                  final rightColumnWidth = (availableWidth - gap) * 0.51;

                  final resumeCardHeight = ResponsiveHelper.forYouCardHeight(context);
                  final smallCardHeight = isTablet ? 164.0 : 137.0;
                  final smallCardHeight2 = isTablet ? 162.0 : 135.0;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resume Card (Left - Tall)
                      _buildResumeCard(isDark, textColor, lastWatched, resumeCardWidth, resumeCardHeight, isTablet),
                      const SizedBox(width: gap),

                      // Right Column - Theory and Practical
                      SizedBox(
                        width: rightColumnWidth,
                        child: Column(
                          children: [
                            _buildTheoryCard(context, isDark, textColor, rightColumnWidth, smallCardHeight, isTablet),
                            const SizedBox(height: 9),
                            _buildPracticalCard(context, isDark, textColor, rightColumnWidth, smallCardHeight2, isTablet),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResumeCard(bool isDark, Color textColor, VideoModel? video, double cardWidth, double cardHeight, bool isTablet) {
    final labelSize = isTablet ? 14.0 : 12.0;
    final titleSize = isTablet ? 20.0 : 18.0;
    final subtitleSize = isTablet ? 16.0 : 14.0;
    final timeSize = isTablet ? 16.0 : 14.0;
    final playBtnSize = isTablet ? 38.0 : 32.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
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
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESUME',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: labelSize,
                    color:
                        isDark ? AppColors.darkTextSecondary : const Color(0xFF666666),
                  ),
                ),
                SizedBox(height: isTablet ? 20 : 16),
                Text(
                  'Continue where\nyou left off',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: titleSize,
                    height: 1.3,
                    color: isDark ? Colors.white : const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  video?.title ?? 'No recent videos',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: subtitleSize,
                    height: 1.3,
                    color: isDark ? const Color(0xFF00BEFA) : AppColors.primaryBlue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Play button and time
          Positioned(
            bottom: isTablet ? 20 : 16,
            left: isTablet ? 20 : 16,
            child: Text(
              video != null ? '${video.remainingMinutes} Min Left' : '--',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: timeSize,
                color: isDark ? Colors.white : const Color(0xFF000000),
              ),
            ),
          ),
          Positioned(
            bottom: isTablet ? 16 : 12,
            right: isTablet ? 20 : 16,
            child: _buildPlayButton(isDark, playBtnSize),
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryCard(BuildContext context, bool isDark, Color textColor, double cardWidth, double cardHeight, bool isTablet) {
    final isLocked = !hasTheorySubscription;
    final labelSize = isTablet ? 14.0 : 12.0;
    final titleSize = isTablet ? 18.0 : 16.0;
    final imageWidth = isTablet ? 120.0 : 101.0;
    final imageHeight = isTablet ? 92.0 : 78.0;
    final btnSize = isTablet ? 38.0 : 32.0;

    return GestureDetector(
      onTap: () {
        // Navigate to theory/revision series with actual subscription status
        context.push('/revision-series?subscribed=$hasTheorySubscription');
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
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
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(width: imageWidth, height: imageHeight);
                  },
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THEORY',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: labelSize,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: isTablet ? 10 : 8),
                  Text(
                    'View Classes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: titleSize,
                      color: isDark ? Colors.white : const Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),
            // Play button or lock button based on subscription
            Positioned(
              bottom: isTablet ? 16 : 12,
              right: isTablet ? 16 : 12,
              child: isLocked ? _buildLockButton(isDark, btnSize) : _buildPlayButton(isDark, btnSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticalCard(BuildContext context, bool isDark, Color textColor, double cardWidth, double cardHeight, bool isTablet) {
    final isLocked = !hasPracticalSubscription;
    final labelSize = isTablet ? 14.0 : 12.0;
    final titleSize = isTablet ? 18.0 : 16.0;
    final imageWidth = isTablet ? 145.0 : 123.0;
    final imageHeight = isTablet ? 100.0 : 85.0;
    final btnSize = isTablet ? 38.0 : 32.0;

    return GestureDetector(
      onTap: () {
        // Navigate to practical series with actual subscription status
        context.push('/practical-series?subscribed=$hasPracticalSubscription');
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
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
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(width: imageWidth, height: imageHeight);
                  },
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRACTICAL',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: labelSize,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: isTablet ? 10 : 8),
                  Text(
                    'View Classes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: titleSize,
                      color: isDark ? Colors.white : const Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),
            // Play button or lock button based on subscription
            Positioned(
              bottom: isTablet ? 16 : 12,
              right: isTablet ? 16 : 12,
              child: isLocked ? _buildLockButton(isDark, btnSize) : _buildPlayButton(isDark, btnSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(bool isDark, double size) {
    return Container(
      width: size,
      height: size,
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
          size: size * 0.56,
          color: isDark ? Colors.white : const Color(0xFF000000),
        ),
      ),
    );
  }

  Widget _buildLockButton(bool isDark, double size) {
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    return Container(
      width: size,
      height: size,
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
          Icons.lock,
          size: size * 0.5,
          color: iconColor,
        ),
      ),
    );
  }
}
