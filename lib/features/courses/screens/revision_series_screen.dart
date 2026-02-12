import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/models/series_model.dart';
import 'package:pgme/core/models/package_model.dart';
import 'package:pgme/features/home/providers/dashboard_provider.dart';

class RevisionSeriesScreen extends StatefulWidget {
  final bool isSubscribed;
  final String? packageId;

  const RevisionSeriesScreen({
    super.key,
    this.isSubscribed = false,
    this.packageId,
  });

  @override
  State<RevisionSeriesScreen> createState() => _RevisionSeriesScreenState();
}

class _RevisionSeriesScreenState extends State<RevisionSeriesScreen> {
  final DashboardService _dashboardService = DashboardService();
  List<SeriesModel> _series = [];
  PackageModel? _theoryPackage;
  bool _isLoading = true;
  String? _error;
  String? _activePackageId;

  // null = landing page, 'lectures' or 'documents' = series list
  String? _contentMode;

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    if (widget.packageId != null) {
      _activePackageId = widget.packageId;
      await _loadData();
    } else {
      await _findAndLoadTheoryPackage();
    }
  }

  Future<void> _findAndLoadTheoryPackage() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      final primarySubjectId = dashboardProvider.primarySubject?.subjectId;

      final packages = await _dashboardService.getPackages(
        subjectId: primarySubjectId,
      );

      final theoryPackage = packages.firstWhere(
        (pkg) => pkg.name.toLowerCase().contains('theory'),
        orElse: () => packages.isNotEmpty ? packages.first : throw Exception('No Theory package found'),
      );

      _activePackageId = theoryPackage.packageId;
      _theoryPackage = theoryPackage;

      await _loadData();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (_activePackageId == null) {
      setState(() {
        _error = 'No package ID available';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Also try to find the package model from DashboardProvider if we don't have it
      if (_theoryPackage == null) {
        final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
        final pkgs = dashboardProvider.packages;
        try {
          _theoryPackage = pkgs.firstWhere(
            (p) => p.packageId == _activePackageId,
          );
        } catch (_) {
          // Not found in provider, that's ok
        }
      }

      final series = await _dashboardService.getPackageSeries(_activePackageId!);

      setState(() {
        _series = series;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showEnrollmentPopup() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    final shouldEnroll = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => _buildEnrollmentDialog(dialogContext, isDark),
    );

    if (shouldEnroll == true && mounted) {
      context.push('/purchase?packageId=$_activePackageId&packageType=Theory');
    }
  }

  Widget _buildEnrollmentDialog(BuildContext dialogContext, bool isDark) {
    final dialogBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final boxBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFF5F5F5);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);

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
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(false),
                    child: Icon(Icons.close, size: 24, color: secondaryTextColor),
                  ),
                ),
              ),
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
                    child: Icon(Icons.school_outlined, size: 60, color: iconColor),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Get the Theory Package',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20, color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Unlock all revision series and get access to comprehensive study materials.',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 14, height: 1.4, color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: boxBgColor, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureCheckItem('4 Complete Revision Series', textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureCheckItem('Downloadable PDF Notes', textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureCheckItem('Expert Faculty Guidance', textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureCheckItem('3 Months Access', textColor, iconColor),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('₹4,999', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 24, color: textColor)),
                          const SizedBox(width: 8),
                          Text('/ 3 months', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 12, color: secondaryTextColor)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            elevation: 0,
                          ),
                          child: const Text('Enroll Now', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: buttonColor, width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          child: Text('See All Packages', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 16, color: buttonColor)),
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

  Widget _buildFeatureCheckItem(String text, Color textColor, Color iconColor) {
    return Row(
      children: [
        Icon(Icons.check_circle, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 13, color: textColor)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final hasTheorySubscription = dashboardProvider.hasTheorySubscription;
    final isSubscribed = hasTheorySubscription || widget.isSubscribed;

    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final cardBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFDCEAF7);

    final isOnLanding = _contentMode == null;
    final title = isOnLanding
        ? 'Theory Packages'
        : _contentMode == 'lectures'
            ? 'Video Lectures'
            : 'Study Documents';

    return PopScope(
      canPop: isOnLanding,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(() => _contentMode = null);
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            // App bar area
            Padding(
              padding: EdgeInsets.only(top: topPadding + 12, left: 16, right: 16, bottom: 12),
              child: Row(
                children: [
                  // Back arrow (only when in series list mode)
                  if (!isOnLanding)
                    GestureDetector(
                      onTap: () => setState(() => _contentMode = null),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_back_rounded, size: 24, color: textColor),
                      ),
                    ),
                  // Title
                  Expanded(
                    child: Text(
                      title,
                      textAlign: isOnLanding ? TextAlign.center : TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        letterSpacing: -0.3,
                        color: textColor,
                      ),
                    ),
                  ),
                  // Menu icon (only on landing)
                  if (isOnLanding)
                    GestureDetector(
                      onTap: () {},
                      child: Icon(Icons.more_horiz, size: 24, color: textColor),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: iconColor))
                  : _error != null
                      ? _buildErrorView(textColor, secondaryTextColor, iconColor)
                      : isOnLanding
                          ? _buildLandingView(isDark, textColor, secondaryTextColor, iconColor, cardBgColor, isSubscribed)
                          : _buildSeriesListView(isDark, textColor, secondaryTextColor, iconColor, cardBgColor, isSubscribed),
            ),
          ],
        ),
      ),
    );
  }

  // ── Landing View ──────────────────────────────────────────────────────

  Widget _buildLandingView(
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
    Color cardBgColor,
    bool isSubscribed,
  ) {
    final gradientStart = isDark ? const Color(0xFF1A3A5C) : const Color(0xFFCDE5FF);
    final gradientEnd = isDark ? const Color(0xFF2D5A9E) : const Color(0xFF8FC6FF);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Two option cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    title: 'Watch\nVideo Lectures',
                    subtitle: '${_getTotalLectures()} Lectures',
                    icon: Icons.play_circle_outline_rounded,
                    imagePath: 'assets/illustrations/1.png',
                    isDark: isDark,
                    gradientStart: gradientStart,
                    gradientEnd: gradientEnd,
                    onTap: () => setState(() => _contentMode = 'lectures'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildOptionCard(
                    title: 'Read\nDocuments',
                    subtitle: '${_getTotalDocuments()} Documents',
                    icon: Icons.description_outlined,
                    imagePath: 'assets/illustrations/2.png',
                    isDark: isDark,
                    gradientStart: gradientStart,
                    gradientEnd: gradientEnd,
                    onTap: () => setState(() => _contentMode = 'documents'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Package info section
          _buildPackageInfoSection(isDark, textColor, secondaryTextColor, iconColor, cardBgColor, isSubscribed),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String imagePath,
    required bool isDark,
    required Color gradientStart,
    required Color gradientEnd,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: const Alignment(-0.5, -0.5),
            end: const Alignment(0.5, 0.5),
            colors: [gradientStart, gradientEnd],
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
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF000000),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Illustration
            Positioned(
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                child: Image.asset(
                  imagePath,
                  width: 110,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 110,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardBackground : const Color(0xFFDCEAF7),
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                      ),
                      child: Icon(
                        icon,
                        size: 36,
                        color: isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageInfoSection(
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
    Color cardBgColor,
    bool isSubscribed,
  ) {
    final pkg = _theoryPackage;
    final totalLectures = _getTotalLectures();
    final totalDocs = _getTotalDocuments();
    final totalDuration = _getTotalDuration();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package name
          Text(
            pkg?.name ?? 'Theory Package',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: textColor,
            ),
          ),
          if (pkg?.description != null && pkg!.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              pkg.description!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.5,
                color: secondaryTextColor,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Stats row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildStatItem(
                  icon: Icons.folder_outlined,
                  value: '${_series.length}',
                  label: 'Series',
                  iconColor: iconColor,
                  textColor: textColor,
                  secondaryColor: secondaryTextColor,
                ),
                _buildStatDivider(isDark),
                _buildStatItem(
                  icon: Icons.play_circle_outline,
                  value: '$totalLectures',
                  label: 'Lectures',
                  iconColor: iconColor,
                  textColor: textColor,
                  secondaryColor: secondaryTextColor,
                ),
                _buildStatDivider(isDark),
                _buildStatItem(
                  icon: Icons.description_outlined,
                  value: '$totalDocs',
                  label: 'Documents',
                  iconColor: iconColor,
                  textColor: textColor,
                  secondaryColor: secondaryTextColor,
                ),
                if (totalDuration.isNotEmpty) ...[
                  _buildStatDivider(isDark),
                  _buildStatItem(
                    icon: Icons.access_time_rounded,
                    value: totalDuration,
                    label: 'Duration',
                    iconColor: iconColor,
                    textColor: textColor,
                    secondaryColor: secondaryTextColor,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // What's included / Features
          if (pkg?.features != null && pkg!.features!.isNotEmpty) ...[
            Text(
              "What's Included",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ...pkg.features!.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 18, color: iconColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 1.4,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Series overview
          Text(
            'Series',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ..._series.map((s) => _buildSeriesPreviewTile(s, isDark, textColor, secondaryTextColor, iconColor)),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 11,
              color: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
    );
  }

  Widget _buildSeriesPreviewTile(
    SeriesModel series,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBackground : const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(Icons.menu_book_rounded, size: 18, color: iconColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  series.title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${series.totalLectures ?? 0} lectures · ${series.totalDocuments ?? 0} docs',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          if (series.isLocked)
            Icon(Icons.lock_rounded, size: 16, color: secondaryTextColor)
          else
            Icon(Icons.chevron_right_rounded, size: 20, color: secondaryTextColor),
        ],
      ),
    );
  }

  // ── Series List View ──────────────────────────────────────────────────

  Widget _buildSeriesListView(
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
    Color cardBgColor,
    bool isSubscribed,
  ) {
    if (_series.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 48, color: textColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No series available',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'This package does not have any series yet.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 100),
      itemCount: _series.length,
      itemBuilder: (context, index) {
        final series = _series[index];
        final isItemLocked = series.isLocked;

        return GestureDetector(
          onTap: () {
            if (isItemLocked) {
              _showEnrollmentPopup();
            } else {
              final seriesId = series.seriesId;
              if (seriesId.isEmpty) return;

              if (_contentMode == 'lectures') {
                context.push('/lecture/$seriesId?subscribed=$isSubscribed&packageType=Theory&packageId=$_activePackageId');
              } else {
                context.push('/available-notes?seriesId=$seriesId&subscribed=$isSubscribed');
              }
            }
          },
          child: _buildSeriesCard(
            series,
            isDark: isDark,
            textColor: textColor,
            cardBgColor: cardBgColor,
            iconColor: iconColor,
            isLocked: isItemLocked,
          ),
        );
      },
    );
  }

  Widget _buildSeriesCard(
    SeriesModel series, {
    required bool isDark,
    required Color textColor,
    required Color cardBgColor,
    required Color iconColor,
    required bool isLocked,
  }) {
    final isLectureMode = _contentMode == 'lectures';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  isLectureMode ? Icons.play_circle_outline_rounded : Icons.description_outlined,
                  size: 22,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.3,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLectureMode
                        ? '${series.totalLectures ?? 0} Lectures${series.formattedDuration != 'N/A' ? ' · ${series.formattedDuration}' : ''}'
                        : '${series.totalDocuments ?? 0} Documents',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Lock or arrow
            if (isLocked)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkSurface : Colors.white,
                ),
                child: Center(child: Icon(Icons.lock_rounded, size: 16, color: iconColor)),
              )
            else
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textColor.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  // ── Error View ────────────────────────────────────────────────────────

  Widget _buildErrorView(Color textColor, Color secondaryTextColor, Color iconColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: textColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Failed to load data',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              _error!.replaceAll('Exception: ', ''),
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: iconColor),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  int _getTotalLectures() {
    int total = 0;
    for (final s in _series) {
      total += s.totalLectures ?? 0;
    }
    return total;
  }

  int _getTotalDocuments() {
    int total = 0;
    for (final s in _series) {
      total += s.totalDocuments ?? 0;
    }
    return total;
  }

  String _getTotalDuration() {
    int totalMinutes = 0;
    for (final s in _series) {
      totalMinutes += s.totalDurationMinutes ?? 0;
    }
    if (totalMinutes == 0) return '';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0) return '${hours}h${mins > 0 ? ' ${mins}m' : ''}';
    return '${mins}m';
  }

}
