import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/models/series_model.dart';
import 'package:pgme/core/models/module_model.dart';

class LectureVideoScreen extends StatefulWidget {
  final String courseId; // This is actually seriesId from route
  final bool isSubscribed;
  final String packageType; // 'Theory' or 'Practical'

  const LectureVideoScreen({
    super.key,
    required this.courseId,
    this.isSubscribed = false,
    this.packageType = 'Theory',
  });

  @override
  State<LectureVideoScreen> createState() => _LectureVideoScreenState();
}

class _LectureVideoScreenState extends State<LectureVideoScreen> with TickerProviderStateMixin {
  final DashboardService _dashboardService = DashboardService();

  SeriesModel? _series;
  List<ModuleModel> _modules = [];
  bool _isLoading = true;
  String? _error;

  Map<String, bool> _expandedModules = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch series details and modules in parallel
      final results = await Future.wait([
        _dashboardService.getSeriesDetails(widget.courseId),
        _dashboardService.getSeriesModules(widget.courseId),
      ]);

      if (mounted) {
        setState(() {
          _series = results[0] as SeriesModel;
          _modules = results[1] as List<ModuleModel>;
          _isLoading = false;

          // Initialize expanded state - expand first module by default
          if (_modules.isNotEmpty) {
            _expandedModules[_modules[0].moduleId] = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

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
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);
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
                        Expanded(
                          child: Text(
                            _series?.title ?? 'Course',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              height: 1.0,
                              letterSpacing: -0.5,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                    padding: const EdgeInsets.only(left: 17, right: 17),
                    child: Text(
                      _getFirstVideoTitle() ?? _series?.title ?? 'Video Title',
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

                  const SizedBox(height: 13),

                  // Description
                  Padding(
                    padding: const EdgeInsets.only(left: 17, right: 17),
                    child: Text(
                      _series?.description ?? 'Course description',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.43,
                        letterSpacing: -0.5,
                        color: secondaryTextColor,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dynamic Modules List
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_error != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 48, color: secondaryTextColor),
                            const SizedBox(height: 16),
                            Text('Failed to load modules', style: TextStyle(color: textColor)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_modules.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text('No modules available', style: TextStyle(color: secondaryTextColor)),
                      ),
                    )
                  else
                    ..._modules.asMap().entries.map((entry) {
                      final index = entry.key;
                      final module = entry.value;
                      final isExpanded = _expandedModules[module.moduleId] ?? false;

                      return Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, bottom: index < _modules.length - 1 ? 7 : 0),
                        child: _buildModuleCard(
                          module: module,
                          isExpanded: isExpanded,
                          isDark: isDark,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          cardBgColor: cardBgColor,
                          iconColor: iconColor,
                          lessonAccessibleBg: lessonAccessibleBg,
                          lessonLockedBg: lessonLockedBg,
                          onTap: () {
                            setState(() {
                              _expandedModules[module.moduleId] = !isExpanded;
                            });
                          },
                        ),
                      );
                    }).toList(),

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
                            context.push('/purchase?packageType=${widget.packageType}');
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

  Widget _buildModuleCard({
    required ModuleModel module,
    required bool isExpanded,
    required VoidCallback onTap,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardBgColor,
    required Color iconColor,
    required Color lessonAccessibleBg,
    required Color lessonLockedBg,
  }) {
    final videoCount = module.videos.length;
    final completedCount = module.completedLessons;

    return Container(
      width: double.infinity,
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
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.name.toUpperCase(),
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
                            '$videoCount ${videoCount == 1 ? 'lesson' : 'lessons'}  •  $completedCount/$videoCount complete',
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

            // Videos list
            AnimatedCrossFade(
              firstChild: Column(
                children: [
                  ...module.videos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final video = entry.value;
                    // First video is always accessible, others require subscription
                    final isAccessible = index == 0 || widget.isSubscribed;

                    return Padding(
                      padding: EdgeInsets.only(
                        left: 14,
                        right: 14,
                        bottom: index < module.videos.length - 1 ? 8 : 16,
                      ),
                      child: _buildLessonItem(
                        isAccessible: isAccessible,
                        title: video.title,
                        duration: video.formattedDuration,
                        instructor: video.facultyName,
                        isDark: isDark,
                        textColor: textColor,
                        iconColor: iconColor,
                        lessonAccessibleBg: lessonAccessibleBg,
                        lessonLockedBg: lessonLockedBg,
                        onTap: isAccessible ? () => context.push('/video/${video.videoId}') : null,
                      ),
                    );
                  }).toList(),
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

  // Helper method to get first video title
  String? _getFirstVideoTitle() {
    if (_modules.isEmpty) return null;
    for (var module in _modules) {
      if (module.videos.isNotEmpty) {
        return module.videos.first.title;
      }
    }
    return null;
  }
}
