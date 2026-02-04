import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/models/series_model.dart';
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
  bool _isLoading = true;
  String? _error;
  String? _activePackageId;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadSeries();
  }

  Future<void> _initializeAndLoadSeries() async {
    if (widget.packageId != null) {
      _activePackageId = widget.packageId;
      await _loadSeries();
    } else {
      // No packageId provided - find user's Theory package
      await _findAndLoadTheoryPackage();
    }
  }

  Future<void> _findAndLoadTheoryPackage() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get user's primary subject from provider
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      final primarySubjectId = dashboardProvider.primarySubject?.subjectId;

      // Fetch packages filtered by subject
      final packages = await _dashboardService.getPackages(
        subjectId: primarySubjectId,
      );

      // Find the Theory package
      final theoryPackage = packages.firstWhere(
        (pkg) => pkg.name.toLowerCase().contains('theory'),
        orElse: () => packages.isNotEmpty ? packages.first : throw Exception('No Theory package found'),
      );

      _activePackageId = theoryPackage.packageId;
      debugPrint('Found Theory package: ${theoryPackage.name} (${_activePackageId})');

      // Now load the series for this package
      await _loadSeries();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSeries() async {
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
      context.push('/congratulations');
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
                'Get the Theory Package',
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
                  'Unlock all revision series and get access to comprehensive study materials.',
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
                    color: boxBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureItem('4 Complete Revision Series', isDark, textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureItem('Downloadable PDF Notes', isDark, textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureItem('Expert Faculty Guidance', isDark, textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureItem('3 Months Access', isDark, textColor, iconColor),
                      const SizedBox(height: 16),
                      // Price
                      Row(
                        children: [
                          Text(
                            '₹4,999',
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
                            // Navigate to packages
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
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool isDark, Color textColor, Color iconColor) {
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

    // Get actual subscription status from DashboardProvider
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final hasTheorySubscription = dashboardProvider.hasTheorySubscription;
    // Use DashboardProvider subscription status, fallback to URL param if provider hasn't loaded yet
    final isSubscribed = hasTheorySubscription || widget.isSubscribed;

    debugPrint('RevisionSeriesScreen: hasTheorySubscription=$hasTheorySubscription, widget.isSubscribed=${widget.isSubscribed}, effective isSubscribed=$isSubscribed');

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final cardBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFDCEAF7);
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFF000000);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);

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
                context.go('/home?subscribed=$isSubscribed');
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

          // Title "Theory Packages"
          Positioned(
            top: topPadding + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Theory Packages',
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
            left: 353,
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
            child: Container(
              width: 361,
              height: 48,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor,
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
                          hintText: 'Search through your medical notes...',
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
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: iconColor,
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: textColor.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load series',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error!.replaceAll('Exception: ', ''),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadSeries,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: iconColor,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _series.isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            itemCount: _series.length,
                            itemBuilder: (context, index) {
                              final series = _series[index];
                              // Use the isLocked property from backend - it checks actual purchase status
                              final isItemLocked = series.isLocked;

                              return GestureDetector(
                                onTap: () {
                                  if (isItemLocked) {
                                    _showEnrollmentPopup();
                                  } else {
                                    // Navigate to series detail screen with seriesId
                                    final seriesId = series.seriesId;
                                    if (seriesId.isNotEmpty) {
                                      debugPrint('Navigating to: /series-detail/$seriesId');
                                      context.push('/series-detail/$seriesId?subscribed=$isSubscribed&packageType=Theory');
                                    } else {
                                      debugPrint('Error: Series ID is empty');
                                    }
                                  }
                                },
                                child: _buildPackageCard(
                                  context,
                                  series.title,
                                  series.description ?? 'No description available',
                                  '${series.totalLectures} Lectures',
                                  series.createdAt != null
                                      ? _formatDate(series.createdAt!)
                                      : 'N/A',
                                  isLocked: isItemLocked,
                                  isDark: isDark,
                                  textColor: textColor,
                                  cardBgColor: cardBgColor,
                                  iconColor: iconColor,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open_outlined,
                                    size: 48,
                                    color: textColor.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No series available',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This package does not have any series yet.',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: secondaryTextColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
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
    String pages,
    String date, {
    bool isLocked = false,
    required bool isDark,
    required Color textColor,
    required Color cardBgColor,
    required Color iconColor,
  }) {
    return Container(
      width: 362,
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
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 12),

                // Pages and date row
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: iconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      pages,
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return isoDate;
    }
  }
}
