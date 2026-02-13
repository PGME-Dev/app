import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/models/series_model.dart';
import 'package:pgme/core/models/module_model.dart';
import 'package:pgme/core/widgets/shimmer_widgets.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

class LectureVideoScreen extends StatefulWidget {
  final String courseId; // This is actually seriesId from route
  final bool isSubscribed;
  final String packageType; // 'Theory' or 'Practical'
  final String? packageId;

  const LectureVideoScreen({
    super.key,
    required this.courseId,
    this.isSubscribed = false,
    this.packageType = 'Theory',
    this.packageId,
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
    final isTablet = ResponsiveHelper.isTablet(context);

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF718BA9);
    final cardBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);
    final lessonAccessibleBg = isDark ? const Color(0xFF1A3A5C) : const Color(0xFFE4F4FF);
    final lessonLockedBg = isDark ? AppColors.darkCardBackground : const Color(0xFFEFEFF8);

    // Responsive sizes
    final hPadding = isTablet ? 24.0 : 16.0;
    final headerIconSize = isTablet ? 30.0 : 24.0;
    final titleFontSize = isTablet ? 24.0 : 20.0;
    final bannerHeight = isTablet ? 320.0 : 242.0;
    final videoTitleSize = isTablet ? 22.0 : 18.0;
    final descFontSize = isTablet ? 17.0 : 14.0;
    final enrollBtnHeight = isTablet ? 68.0 : 54.0;
    final enrollFontSize = isTablet ? 19.0 : 16.0;
    final enrollBtnRadius = isTablet ? 28.0 : 22.0;
    final moduleGap = isTablet ? 12.0 : 7.0;
    final sectionGap = isTablet ? 28.0 : 23.0;

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (mounted) context.pop();
        return true;
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && mounted) context.pop();
        },
        child: Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? ResponsiveHelper.maxContentWidth : double.infinity,
                  ),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.only(top: topPadding + (isTablet ? 16 : 12), left: hPadding, right: hPadding),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: SizedBox(
                            width: headerIconSize,
                            height: headerIconSize,
                            child: Icon(
                              Icons.arrow_back,
                              size: headerIconSize,
                              color: textColor,
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Expanded(
                          child: Text(
                            _series?.title ?? 'Course',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              fontSize: titleFontSize,
                              height: 1.0,
                              letterSpacing: -0.5,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // More options
                          },
                          child: SizedBox(
                            width: headerIconSize,
                            height: headerIconSize,
                            child: Icon(
                              Icons.more_horiz,
                              size: headerIconSize,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: sectionGap),

                  // Course Banner Image
                  ClipRRect(
                    borderRadius: isTablet ? BorderRadius.circular(16) : BorderRadius.zero,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? hPadding : 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: bannerHeight,
                        child: ClipRRect(
                          borderRadius: isTablet ? BorderRadius.circular(16) : BorderRadius.zero,
                          child: Image.asset(
                            'assets/illustrations/course.png',
                            width: double.infinity,
                            height: bannerHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: bannerHeight,
                                color: isDark ? AppColors.darkSurface : const Color(0xFFE0E0E0),
                                child: Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: isTablet ? 80 : 60,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: sectionGap),

                  // Video Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? hPadding + 4 : 17),
                    child: Text(
                      _getFirstVideoTitle() ?? _series?.title ?? 'Video Title',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: videoTitleSize,
                        height: 1.0,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? 16 : 13),

                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? hPadding + 4 : 17),
                    child: Text(
                      _series?.description ?? 'Course description',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: descFontSize,
                        height: 1.43,
                        letterSpacing: -0.5,
                        color: secondaryTextColor,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: isTablet ? 24 : 16),

                  // Dynamic Modules List
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.all(hPadding),
                      child: Column(
                        children: List.generate(4, (index) => ShimmerWidgets.listItemShimmer(isDark: isDark)),
                      ),
                    )
                  else if (_error != null)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 48.0 : 32.0),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: isTablet ? 60 : 48, color: secondaryTextColor),
                            SizedBox(height: isTablet ? 20 : 16),
                            Text('Failed to load modules', style: TextStyle(
                              color: textColor,
                              fontSize: isTablet ? 18 : 14,
                              fontFamily: 'Poppins',
                            )),
                            SizedBox(height: isTablet ? 20 : 16),
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
                        padding: EdgeInsets.all(isTablet ? 48.0 : 32.0),
                        child: Text('No modules available', style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: isTablet ? 18 : 14,
                          fontFamily: 'Poppins',
                        )),
                      ),
                    )
                  else
                    ..._modules.asMap().entries.map((entry) {
                      final index = entry.key;
                      final module = entry.value;
                      final isExpanded = _expandedModules[module.moduleId] ?? false;

                      return Padding(
                        padding: EdgeInsets.only(left: hPadding, right: hPadding, bottom: index < _modules.length - 1 ? moduleGap : 0),
                        child: _buildModuleCard(
                          module: module,
                          isExpanded: isExpanded,
                          isDark: isDark,
                          isTablet: isTablet,
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

                  SizedBox(height: isTablet ? 32 : 24),

                  // Enroll Now Button - Only show for unsubscribed users
                  if (!widget.isSubscribed)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPadding),
                      child: SizedBox(
                        width: double.infinity,
                        height: enrollBtnHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            final params = <String>['packageType=${widget.packageType}'];
                            if (widget.packageId != null) params.add('packageId=${widget.packageId}');
                            context.push('/purchase?${params.join('&')}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(enrollBtnRadius),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Enroll Now',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: enrollFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: isTablet ? 120 : 100), // Space for nav bar
                ],
              ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }

  Widget _buildLessonItem({
    required bool isAccessible,
    required String title,
    required String duration,
    required String instructor,
    required bool isDark,
    required bool isTablet,
    required Color textColor,
    required Color iconColor,
    required Color lessonAccessibleBg,
    required Color lessonLockedBg,
    VoidCallback? onTap,
  }) {
    final secondaryColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final lockBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFDCEAF7);

    final lessonHeight = isTablet ? 72.0 : 56.0;
    final iconContainerSize = isTablet ? 36.0 : 28.0;
    final checkSize = isTablet ? 20.0 : 16.0;
    final lockSize = isTablet ? 18.0 : 14.0;
    final titleSize = isTablet ? 15.0 : 12.0;
    final metaSize = isTablet ? 13.0 : 10.0;
    final clockSize = isTablet ? 15.0 : 12.0;
    final avatarSize = isTablet ? 22.0 : 16.0;
    final itemRadius = isTablet ? 16.0 : 12.0;
    final itemHPadding = isTablet ? 16.0 : 12.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: lessonHeight,
        decoration: BoxDecoration(
          color: isAccessible ? lessonAccessibleBg : lessonLockedBg,
          borderRadius: BorderRadius.circular(itemRadius),
        ),
        child: Row(
          children: [
            SizedBox(width: itemHPadding),
            // Icon - Checkmark for accessible, Lock for locked
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAccessible ? iconColor : lockBgColor,
              ),
              child: Center(
                child: isAccessible
                    ? Icon(
                        Icons.check,
                        size: checkSize,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.lock,
                        size: lockSize,
                        color: iconColor,
                      ),
              ),
            ),
            SizedBox(width: itemHPadding),
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
                      fontSize: titleSize,
                      height: 1.0,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 8 : 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: clockSize,
                        color: secondaryColor,
                      ),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: metaSize,
                          color: secondaryColor,
                        ),
                      ),
                      SizedBox(width: isTablet ? 10 : 8),
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: metaSize,
                          color: secondaryColor,
                        ),
                      ),
                      SizedBox(width: isTablet ? 10 : 8),
                      // Doctor avatar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(avatarSize / 2),
                        child: Image.asset(
                          'assets/illustrations/doc.png',
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        instructor,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: metaSize,
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
    );
  }

  Widget _buildModuleCard({
    required ModuleModel module,
    required bool isExpanded,
    required VoidCallback onTap,
    required bool isDark,
    required bool isTablet,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardBgColor,
    required Color iconColor,
    required Color lessonAccessibleBg,
    required Color lessonLockedBg,
  }) {
    final videoCount = module.videos.length;
    final completedCount = module.completedLessons;

    final cardRadius = isTablet ? 16.0 : 12.0;
    final headerPadding = isTablet ? 20.0 : 16.0;
    final moduleNameSize = isTablet ? 15.0 : 12.0;
    final moduleMetaSize = isTablet ? 14.0 : 11.0;
    final arrowSize = isTablet ? 30.0 : 24.0;
    final lessonPaddingH = isTablet ? 18.0 : 14.0;
    final lessonGap = isTablet ? 10.0 : 8.0;
    final lessonBottomPad = isTablet ? 20.0 : 16.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: isTablet ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0x4D000000),
                  blurRadius: isTablet ? 4 : 3,
                  offset: const Offset(0, 1),
                ),
                BoxShadow(
                  color: const Color(0x26000000),
                  blurRadius: isTablet ? 12 : 8,
                  spreadRadius: isTablet ? 4 : 3,
                  offset: const Offset(0, 4),
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
                padding: EdgeInsets.symmetric(horizontal: headerPadding, vertical: headerPadding),
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
                              fontSize: moduleNameSize,
                              height: 1.0,
                              letterSpacing: -0.3,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: isTablet ? 8 : 6),
                          Text(
                            '$videoCount ${videoCount == 1 ? 'lesson' : 'lessons'}  •  $completedCount/$videoCount complete',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: moduleMetaSize,
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
                        size: arrowSize,
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
                        left: lessonPaddingH,
                        right: lessonPaddingH,
                        bottom: index < module.videos.length - 1 ? lessonGap : lessonBottomPad,
                      ),
                      child: _buildLessonItem(
                        isAccessible: isAccessible,
                        title: video.title,
                        duration: video.formattedDuration,
                        instructor: video.facultyName,
                        isDark: isDark,
                        isTablet: isTablet,
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
    bool isTablet = false,
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
                      isTablet: isTablet,
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
                      isTablet: isTablet,
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
                      isTablet: isTablet,
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
