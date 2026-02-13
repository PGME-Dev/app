import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/models/video_model.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'For You',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Content - Responsive layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              const gap = 9.0;
              // Left card takes ~49% of available width, right column takes ~51%
              final resumeCardWidth = (availableWidth - gap) * 0.49;
              final rightColumnWidth = (availableWidth - gap) * 0.51;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resume Card (Left - Tall)
                  _buildResumeCard(isDark, textColor, lastWatched, resumeCardWidth),
                  const SizedBox(width: gap),

                  // Right Column - Theory and Practical
                  SizedBox(
                    width: rightColumnWidth,
                    child: Column(
                      children: [
                        _buildTheoryCard(context, isDark, textColor, rightColumnWidth),
                        const SizedBox(height: 9),
                        _buildPracticalCard(context, isDark, textColor, rightColumnWidth),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResumeCard(bool isDark, Color textColor, VideoModel? video, double cardWidth) {
    return Container(
      width: cardWidth,
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
                    color:
                        isDark ? AppColors.darkTextSecondary : const Color(0xFF666666),
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
                  video?.title ?? 'No recent videos',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
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
            bottom: 16,
            left: 16,
            child: Text(
              video != null ? '${video.remainingMinutes} Min Left' : '--',
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

  Widget _buildTheoryCard(BuildContext context, bool isDark, Color textColor, double cardWidth) {
    final isLocked = !hasTheorySubscription;

    return GestureDetector(
      onTap: () {
        // Navigate to theory/revision series with actual subscription status
        context.push('/revision-series?subscribed=$hasTheorySubscription');
      },
      child: Container(
        width: cardWidth,
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
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF666666),
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
            // Play button or lock button based on subscription
            Positioned(
              bottom: 12,
              right: 12,
              child: isLocked ? _buildLockButton(isDark) : _buildPlayButton(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticalCard(BuildContext context, bool isDark, Color textColor, double cardWidth) {
    final isLocked = !hasPracticalSubscription;

    return GestureDetector(
      onTap: () {
        // Navigate to practical series with actual subscription status
        context.push('/practical-series?subscribed=$hasPracticalSubscription');
      },
      child: Container(
        width: cardWidth,
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
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF666666),
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
            // Play button or lock button based on subscription
            Positioned(
              bottom: 12,
              right: 12,
              child: isLocked ? _buildLockButton(isDark) : _buildPlayButton(isDark),
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

  Widget _buildLockButton(bool isDark) {
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
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
          Icons.lock,
          size: 16,
          color: iconColor,
        ),
      ),
    );
  }
}
