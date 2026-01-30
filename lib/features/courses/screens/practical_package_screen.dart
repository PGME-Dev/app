import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class PracticalPackageScreen extends StatefulWidget {
  final bool isSubscribed;

  const PracticalPackageScreen({super.key, this.isSubscribed = false});

  @override
  State<PracticalPackageScreen> createState() => _PracticalPackageScreenState();
}

class _PracticalPackageScreenState extends State<PracticalPackageScreen> {
  void _showEnrollmentPopup() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    final shouldEnroll = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => _buildEnrollmentDialog(dialogContext, isDark),
    );

    if (shouldEnroll == true && mounted) {
      context.push('/congratulations');
    }
  }

  Widget _buildEnrollmentDialog(BuildContext dialogContext, bool isDark) {
    final dialogBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final cardBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFF5F5F5);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final buttonBgColor = isDark ? const Color(0xFF1A1A4D) : const Color(0xFF0000D1);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        width: 356,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 80,
        ),
        decoration: BoxDecoration(
          color: dialogBgColor,
          borderRadius: BorderRadius.circular(20.8),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(false),
                    child: Icon(
                      Icons.close,
                      size: 24,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ),

              // Illustration
              Image.asset(
                'assets/illustrations/enroll.png',
                width: 180,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 180,
                    height: 120,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardBackground : const Color(0xFFDCEAF7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      size: 60,
                      color: iconColor,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                'Get the Practical Package',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Unlock all practical series and get access to comprehensive study materials.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.4,
                    color: secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // Package details box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureItem('4 Complete Practical Series', textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureItem('Hands-on Video Tutorials', textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureItem('Expert Faculty Guidance', textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureItem('3 Months Access', textColor, iconColor),
                      const SizedBox(height: 16),
                      // Price
                      Row(
                        children: [
                          Text(
                            '₹5,999',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ 3 months',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Enroll Now button
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text(
                            'Enroll Now',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              letterSpacing: -0.18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // See All Packages button
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: buttonBgColor,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: Text(
                            'See All Packages',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              letterSpacing: -0.18,
                              color: buttonBgColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, Color textColor, Color iconColor) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 18,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final cardBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFDCEAF7);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final searchBarColor = isDark ? AppColors.darkSurface : Colors.white;
    final searchBarBorderColor = isDark ? AppColors.darkDivider : const Color(0xFF000000);
    final dividerColor = isDark ? AppColors.darkDivider : const Color(0xFF000000);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Header
          // Back Arrow - navigates to home
          Positioned(
            top: topPadding + 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
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
          ),

          // Title "Practical Packages"
          Positioned(
            top: topPadding + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Practical Packages',
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

          // Three dots menu
          Positioned(
            top: topPadding + 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                // Show menu options
              },
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  Icons.more_horiz,
                  size: 24,
                  color: textColor,
                ),
              ),
            ),
          ),

          // Search Bar
          Positioned(
            top: topPadding + 52,
            left: 16,
            right: 16,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: searchBarColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: searchBarBorderColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search,
                    size: 24,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Opacity(
                      opacity: 0.4,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search through practical courses...',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 20 / 12,
                            letterSpacing: -0.5,
                            color: textColor,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.5,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Package Cards List
          Positioned(
            top: topPadding + 116,
            left: 0,
            right: 0,
            bottom: 100,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: 4,
              itemBuilder: (context, index) {
                // If subscribed, all items are unlocked. Otherwise only first item is unlocked
                final isLocked = widget.isSubscribed ? false : index > 0;

                return GestureDetector(
                  onTap: () {
                    if (isLocked) {
                      _showEnrollmentPopup();
                    } else {
                      // Navigate to course detail screen
                      context.push('/course/practical-${index + 1}');
                    }
                  },
                  child: _buildPackageCard(
                    context,
                    'Practical Series ${_romanNumeral(index + 1)}',
                    'Hands-on practical training with step-by-step video demonstrations and expert guidance.',
                    '12 Videos',
                    '21 Jan 2026',
                    isLocked: isLocked,
                    isDark: isDark,
                    textColor: textColor,
                    cardBgColor: cardBgColor,
                    iconColor: iconColor,
                    dividerColor: dividerColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    String title,
    String description,
    String videos,
    String date, {
    bool isLocked = false,
    required bool isDark,
    required Color textColor,
    required Color cardBgColor,
    required Color iconColor,
    required Color dividerColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with lock icon
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.43,
                          letterSpacing: 0,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (isLocked)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkSurface : Colors.white,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.lock,
                            size: 14,
                            color: iconColor,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Description
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      height: 1.5,
                      letterSpacing: 0,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 12),

                // Divider line
                Opacity(
                  opacity: 0.3,
                  child: Container(
                    width: double.infinity,
                    height: 1,
                    color: dividerColor,
                  ),
                ),

                const SizedBox(height: 12),

                // Videos and date row
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 16,
                      color: iconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      videos,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        height: 1.0,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: iconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        height: 1.0,
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
    );
  }

  String _romanNumeral(int number) {
    switch (number) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'IV';
      default:
        return '$number';
    }
  }
}
