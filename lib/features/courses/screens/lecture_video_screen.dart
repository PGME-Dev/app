import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class LectureVideoScreen extends StatefulWidget {
  final String courseId;
  final bool isSubscribed;

  const LectureVideoScreen({
    super.key,
    required this.courseId,
    this.isSubscribed = false,
  });

  @override
  State<LectureVideoScreen> createState() => _LectureVideoScreenState();
}

class _LectureVideoScreenState extends State<LectureVideoScreen> with TickerProviderStateMixin {
  bool _module1Expanded = true;
  bool _module2Expanded = false;
  bool _module3Expanded = false;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF718BA9);
    final cardBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);
    final notesBoxColor = isDark ? const Color(0xFF1A5A9E) : const Color(0xFF8EC6FF);
    final lessonAccessibleBg = isDark ? const Color(0xFF1A3A5C) : const Color(0xFFE4F4FF);
    final lessonLockedBg = isDark ? AppColors.darkCardBackground : const Color(0xFFEFEFF8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.only(top: topPadding + 12, left: 16, right: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
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
                        const SizedBox(width: 87),
                        SizedBox(
                          width: 139,
                          height: 20,
                          child: Text(
                            'Anatomy Course',
                            textAlign: TextAlign.center,
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
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // More options
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 23),

                  // Course Banner Image
                  SizedBox(
                    width: double.infinity,
                    height: 242,
                    child: Image.asset(
                      'assets/illustrations/course.png',
                      width: double.infinity,
                      height: 242,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 242,
                          color: isDark ? AppColors.darkSurface : const Color(0xFFE0E0E0),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 60,
                              color: secondaryTextColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 23),

                  // Video Title
                  Padding(
                    padding: const EdgeInsets.only(left: 17),
                    child: SizedBox(
                      width: 90,
                      height: 20,
                      child: Text(
                        'Video Title',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          height: 1.0,
                          letterSpacing: -0.5,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  // Description
                  Padding(
                    padding: const EdgeInsets.only(left: 17),
                    child: SizedBox(
                      width: 360,
                      child: Text(
                        'aliqua dolor proident exercitation cillum exercitation laboris voluptate ea reprehenderit eu consequat pariatur qui eu aliqua dolor proident exercitation cillum exercitation laboris voluptate ea reprehenderit eu consequat pariatur qui eu',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.43,
                          letterSpacing: -0.5,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  // Notes for this chapter
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: SizedBox(
                      width: 163,
                      height: 20,
                      child: Text(
                        'Notes for this chapter',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.0,
                          letterSpacing: -0.5,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Blue Notes Box
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      width: 359,
                      height: 87,
                      decoration: BoxDecoration(
                        color: notesBoxColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          // White inner box
                          Container(
                            width: 62,
                            height: 51,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Note content
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Human Heart',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 1.0,
                                  color: isDark ? Colors.white : const Color(0xFF000000),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 250,
                                child: Text(
                                  'aliqua dolor proident exercitation cillum exercitation laboris voluptate ea reprehenderit',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.3,
                                    color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF000000).withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 11),

                  // Module 1 Container (Expanded)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      width: 361,
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
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
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Column(
                          children: [
                            // Module Header
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _module1Expanded = !_module1Expanded;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'MODULE 1: FOUNDATIONAL ANATOMY',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              height: 1.0,
                                              letterSpacing: -0.3,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '3 lessons  •  1/3 complete',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 11,
                                              height: 1.0,
                                              color: textColor.withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: _module1Expanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 24,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Lesson items (expanded)
                            AnimatedCrossFade(
                              firstChild: Column(
                                children: [
                                  // Lesson 1 - Always accessible (sample/completed)
                                  _buildLessonItem(
                                    isAccessible: true,
                                    title: 'Introduction to Valvular Structures',
                                    duration: '5:20',
                                    instructor: 'Dr. Aviraj',
                                    isDark: isDark,
                                    textColor: textColor,
                                    iconColor: iconColor,
                                    lessonAccessibleBg: lessonAccessibleBg,
                                    lessonLockedBg: lessonLockedBg,
                                    onTap: () {
                                      context.push('/video/1');
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  // Lesson 2 - Unlocked for subscribed, locked for guests
                                  _buildLessonItem(
                                    isAccessible: widget.isSubscribed,
                                    title: 'Introduction to Valvular Structures',
                                    duration: '12:45',
                                    instructor: 'Dr. Aviraj',
                                    isDark: isDark,
                                    textColor: textColor,
                                    iconColor: iconColor,
                                    lessonAccessibleBg: lessonAccessibleBg,
                                    lessonLockedBg: lessonLockedBg,
                                    onTap: widget.isSubscribed ? () => context.push('/video/2') : null,
                                  ),
                                  const SizedBox(height: 8),
                                  // Lesson 3 - Unlocked for subscribed, locked for guests
                                  _buildLessonItem(
                                    isAccessible: widget.isSubscribed,
                                    title: 'Introduction to Valvular Structures',
                                    duration: '12:45',
                                    instructor: 'Dr. Aviraj',
                                    isDark: isDark,
                                    textColor: textColor,
                                    iconColor: iconColor,
                                    lessonAccessibleBg: lessonAccessibleBg,
                                    lessonLockedBg: lessonLockedBg,
                                    onTap: widget.isSubscribed ? () => context.push('/video/3') : null,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                              secondChild: const SizedBox.shrink(),
                              crossFadeState: _module1Expanded
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              duration: const Duration(milliseconds: 300),
                              sizeCurve: Curves.easeInOut,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  // Module 2 - Locked for unsubscribed, unlocked for subscribed
                  _buildModule(
                    title: 'MODULE 2: PATHOLOGICAL SOMETHING',
                    lessons: '3 lessons',
                    progress: '1/3 complete',
                    isExpanded: _module2Expanded,
                    isLocked: !widget.isSubscribed,
                    isDark: isDark,
                    textColor: textColor,
                    cardBgColor: cardBgColor,
                    iconColor: iconColor,
                    secondaryTextColor: secondaryTextColor,
                    lessonAccessibleBg: lessonAccessibleBg,
                    lessonLockedBg: lessonLockedBg,
                    onTap: () {
                      setState(() {
                        _module2Expanded = !_module2Expanded;
                      });
                    },
                  ),

                  const SizedBox(height: 7),

                  // Module 3 - Locked for unsubscribed, unlocked for subscribed
                  _buildModule(
                    title: 'MODULE 3: PATHOLOGICAL SOMETHING',
                    lessons: '3 lessons',
                    progress: '1/3 complete',
                    isExpanded: _module3Expanded,
                    isLocked: !widget.isSubscribed,
                    isDark: isDark,
                    textColor: textColor,
                    cardBgColor: cardBgColor,
                    iconColor: iconColor,
                    secondaryTextColor: secondaryTextColor,
                    lessonAccessibleBg: lessonAccessibleBg,
                    lessonLockedBg: lessonLockedBg,
                    onTap: () {
                      setState(() {
                        _module3Expanded = !_module3Expanded;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Enroll Now Button - Only show for unsubscribed users
                  if (!widget.isSubscribed)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/purchase');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Enroll Now',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 100), // Space for nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem({
    required bool isAccessible,
    required String title,
    required String duration,
    required String instructor,
    required bool isDark,
    required Color textColor,
    required Color iconColor,
    required Color lessonAccessibleBg,
    required Color lessonLockedBg,
    VoidCallback? onTap,
  }) {
    final secondaryColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final lockBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFDCEAF7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 332,
          height: 56,
          decoration: BoxDecoration(
            color: isAccessible ? lessonAccessibleBg : lessonLockedBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              // Icon - Checkmark for accessible, Lock for locked
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isAccessible ? iconColor : lockBgColor,
                ),
                child: Center(
                  child: isAccessible
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.lock,
                          size: 14,
                          color: iconColor,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Lesson details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 1.0,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 10,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Doctor avatar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/illustrations/doc.png',
                            width: 16,
                            height: 16,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          instructor,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: secondaryColor,
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
    );
  }

  Widget _buildModule({
    required String title,
    required String lessons,
    required String progress,
    required bool isExpanded,
    required VoidCallback onTap,
    required bool isLocked,
    required bool isDark,
    required Color textColor,
    required Color cardBgColor,
    required Color iconColor,
    required Color secondaryTextColor,
    required Color lessonAccessibleBg,
    required Color lessonLockedBg,
  }) {
    final lockBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFDCEAF7);

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Container(
        width: 361,
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
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
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              GestureDetector(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      // Lock/Unlock icon based on state
                      if (isLocked)
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: lockBgColor,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.lock,
                              size: 14,
                              color: iconColor,
                            ),
                          ),
                        ),
                      if (isLocked) const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                height: 1.0,
                                letterSpacing: -0.3,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$lessons   •   $progress',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                                height: 1.0,
                                color: textColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 24,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Show lessons when expanded with animation
              AnimatedCrossFade(
                firstChild: Column(
                  children: [
                    _buildLessonItem(
                      isAccessible: !isLocked,
                      title: 'Introduction to Valvular Structures',
                      duration: '12:45',
                      instructor: 'Dr. Aviraj',
                      isDark: isDark,
                      textColor: textColor,
                      iconColor: iconColor,
                      lessonAccessibleBg: lessonAccessibleBg,
                      lessonLockedBg: lessonLockedBg,
                      onTap: isLocked ? null : () => context.push('/video/2'),
                    ),
                    const SizedBox(height: 8),
                    _buildLessonItem(
                      isAccessible: !isLocked,
                      title: 'Introduction to Valvular Structures',
                      duration: '12:45',
                      instructor: 'Dr. Aviraj',
                      isDark: isDark,
                      textColor: textColor,
                      iconColor: iconColor,
                      lessonAccessibleBg: lessonAccessibleBg,
                      lessonLockedBg: lessonLockedBg,
                      onTap: isLocked ? null : () => context.push('/video/3'),
                    ),
                    const SizedBox(height: 8),
                    _buildLessonItem(
                      isAccessible: !isLocked,
                      title: 'Introduction to Valvular Structures',
                      duration: '12:45',
                      instructor: 'Dr. Aviraj',
                      isDark: isDark,
                      textColor: textColor,
                      iconColor: iconColor,
                      lessonAccessibleBg: lessonAccessibleBg,
                      lessonLockedBg: lessonLockedBg,
                      onTap: isLocked ? null : () => context.push('/video/4'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 300),
                sizeCurve: Curves.easeInOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
