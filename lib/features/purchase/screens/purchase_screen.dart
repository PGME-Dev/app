import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool _isProcessing = false;

  void _showPaymentPopup() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    final shouldEnroll = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => _buildEnrollmentDialog(dialogContext, isDark),
    );

    if (shouldEnroll == true && mounted) {
      _processPayment();
    }
  }

  Widget _buildEnrollmentDialog(BuildContext dialogContext, bool isDark) {
    final dialogBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final boxBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);
    final featureBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFE8F4FF);

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
                      color: featureBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 60,
                      color: iconColor,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                'Get the Theory\nPackage',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.1,
                  letterSpacing: -0.18,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Access theory modules, recorded lectures, and expert study resources',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.05,
                    letterSpacing: -0.18,
                    color: secondaryTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Package details box
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: boxBgColor,
                  borderRadius: BorderRadius.circular(10.93),
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theory Package',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPopupFeatureItem('Full access to theory content', isDark, textColor, iconColor, featureBgColor),
                    const SizedBox(height: 8),
                    _buildPopupFeatureItem('150+ recorded video lectures', isDark, textColor, iconColor, featureBgColor),
                    const SizedBox(height: 8),
                    _buildPopupFeatureItem('24/7 doubt resolution support', isDark, textColor, iconColor, featureBgColor),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: borderColor),
                    const SizedBox(height: 16),
                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹4,999',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 24,
                            height: 1.0,
                            letterSpacing: -0.18,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ 3 months',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Limited Time Offer',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
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
                          backgroundColor: buttonColor,
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
                          context.push('/all-packages');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: buttonColor,
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
                            color: buttonColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupFeatureItem(String text, bool isDark, Color textColor, Color iconColor, Color featureBgColor) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: featureBgColor,
          ),
          child: Center(
            child: Icon(
              Icons.check,
              size: 10,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() => _isProcessing = false);
      context.go('/congratulations');
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final cardBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE8EEF4);
    final iconBgColor = isDark ? const Color(0xFF1A3A5C) : const Color(0xFFDCEAF7);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);
    final priceColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Container(
                  padding: EdgeInsets.only(top: topPadding + 16, left: 16, right: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Course Details',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Course Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    height: 180,
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
                        // Background pattern
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Opacity(
                            opacity: 0.1,
                            child: Icon(
                              Icons.school,
                              size: 180,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'THEORY PACKAGE',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Complete Medical\nEducation Course',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const Spacer(),
                              const Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Colors.white70),
                                  SizedBox(width: 6),
                                  Text(
                                    '3 Months Access',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Icon(Icons.play_circle_outline, size: 16, color: Colors.white70),
                                  SizedBox(width: 6),
                                  Text(
                                    '150+ Videos',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: Colors.white70,
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

                // Course Overview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Course Overview',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Master your medical education with our comprehensive theory package. This course covers all essential topics with expert faculty guidance and structured learning paths.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: secondaryTextColor,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // What's Included
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'What\'s Included',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Feature Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildFeatureCard(
                        icon: Icons.video_library_outlined,
                        title: 'Recorded Lectures',
                        subtitle: '150+ high-quality video lectures',
                        isDark: isDark,
                        textColor: textColor,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        iconBgColor: iconBgColor,
                        iconColor: iconColor,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.live_tv_outlined,
                        title: 'Live Sessions',
                        subtitle: 'Weekly live doubt clearing sessions',
                        isDark: isDark,
                        textColor: textColor,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        iconBgColor: iconBgColor,
                        iconColor: iconColor,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.menu_book_outlined,
                        title: 'Study Materials',
                        subtitle: 'Comprehensive notes & PDFs',
                        isDark: isDark,
                        textColor: textColor,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        iconBgColor: iconBgColor,
                        iconColor: iconColor,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.quiz_outlined,
                        title: 'Practice Tests',
                        subtitle: 'Topic-wise MCQs & mock tests',
                        isDark: isDark,
                        textColor: textColor,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        iconBgColor: iconBgColor,
                        iconColor: iconColor,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.support_agent_outlined,
                        title: 'Expert Support',
                        subtitle: '24/7 doubt resolution via chat',
                        isDark: isDark,
                        textColor: textColor,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        iconBgColor: iconBgColor,
                        iconColor: iconColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Faculty Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Course Faculty',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final names = ['Dr. Sharma', 'Dr. Patel', 'Dr. Gupta', 'Dr. Singh'];
                      final specialties = ['Anatomy', 'Physiology', 'Biochemistry', 'Pathology'];
                      return Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: iconBgColor,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/illustrations/doc.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 28,
                                      color: iconColor,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              names[index],
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              specialties[index],
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                color: textColor.withValues(alpha: 0.5),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Reviews Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Student Reviews',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 18, color: Color(0xFFFFB800)),
                          const SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(2.5k)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Review Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildReviewCard(
                        name: 'Rahul M.',
                        review: 'Excellent course! The faculty explains concepts very clearly. Highly recommended for PG aspirants.',
                        rating: 5,
                        isDark: isDark,
                        textColor: textColor,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        iconBgColor: iconBgColor,
                        iconColor: iconColor,
                      ),
                      const SizedBox(height: 12),
                      _buildReviewCard(
                        name: 'Priya S.',
                        review: 'Very comprehensive content. The live sessions are super helpful for clearing doubts.',
                        rating: 5,
                        isDark: isDark,
                        textColor: textColor,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        iconBgColor: iconBgColor,
                        iconColor: iconColor,
                      ),
                    ],
                  ),
                ),

                // Space for bottom button
                SizedBox(height: bottomPadding + 120),
              ],
            ),
          ),

          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),

          // Bottom Buy Section
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: bottomPadding + 16,
              ),
              decoration: BoxDecoration(
                color: surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹4,999',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              color: priceColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '₹9,999',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: textColor.withValues(alpha: 0.4),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '50% OFF',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Buy Button
                  GestureDetector(
                    onTap: _isProcessing ? null : _showPaymentPopup,
                    child: Container(
                      width: 160,
                      height: 54,
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: buttonColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Buy Now',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color textColor,
    required Color cardBgColor,
    required Color borderColor,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: textColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            size: 22,
            color: Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String review,
    required int rating,
    required bool isDark,
    required Color textColor,
    required Color cardBgColor,
    required Color borderColor,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name[0],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: const Color(0xFFFFB800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textColor.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
