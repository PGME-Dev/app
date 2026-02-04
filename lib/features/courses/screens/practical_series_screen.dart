import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/models/series_model.dart';
import 'package:pgme/features/home/providers/dashboard_provider.dart';
import 'package:intl/intl.dart';

class PracticalSeriesScreen extends StatefulWidget {
  final bool isSubscribed;
  final String? packageId;

  const PracticalSeriesScreen({
    super.key,
    this.isSubscribed = false,
    this.packageId,
  });

  @override
  State<PracticalSeriesScreen> createState() => _PracticalSeriesScreenState();
}

class _PracticalSeriesScreenState extends State<PracticalSeriesScreen> {
  final DashboardService _dashboardService = DashboardService();
  List<SeriesModel> _series = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      String packageId = widget.packageId ?? '';

      // If no packageId provided, fetch the Practical package for user's subject
      if (packageId.isEmpty) {
        // Get user's primary subject from provider
        final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
        final primarySubjectId = dashboardProvider.primarySubject?.subjectId;

        // Fetch packages filtered by subject and type
        final packages = await _dashboardService.getPackages(
          subjectId: primarySubjectId,
          packageType: 'Practical',
        );

        if (packages.isEmpty) {
          throw Exception('No practical packages found for your subject');
        }

        // Find the Practical package
        final practicalPackage = packages.firstWhere(
          (pkg) => pkg.name.toLowerCase().contains('practical'),
          orElse: () => packages.first,
        );

        packageId = practicalPackage.packageId;
        debugPrint('Found Practical package: ${practicalPackage.name} ($packageId)');
      }

      final series = await _dashboardService.getPackageSeries(packageId);

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
                  'Unlock all practical series and get access to hands-on training materials.',
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
                      _buildFeatureItem('${_series.length} Complete Practical Series', isDark, textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureItem('Hands-on Video Demonstrations', isDark, textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureItem('Expert Faculty Guidance', isDark, textColor, iconColor),
                      const SizedBox(height: 8),
                      _buildFeatureItem('3 Months Access', isDark, textColor, iconColor),
                      const SizedBox(height: 16),
                      // Price
                      Row(
                        children: [
                          Text(
                            '₹6,999',
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
    final hasPracticalSubscription = dashboardProvider.hasPracticalSubscription;
    // Use DashboardProvider subscription status, fallback to URL param if provider hasn't loaded yet
    final isSubscribed = hasPracticalSubscription || widget.isSubscribed;

    debugPrint('PracticalSeriesScreen: hasPracticalSubscription=$hasPracticalSubscription, widget.isSubscribed=${widget.isSubscribed}, effective isSubscribed=$isSubscribed');

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
          // Back Arrow
          Positioned(
            top: topPadding + 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                context.pop();
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

          // Title
          Positioned(
            top: topPadding + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Practical Series',
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
                          hintText: 'Search through practical series...',
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

          // Series Cards List
          Positioned(
            top: topPadding + 116,
            left: 0,
            right: 0,
            bottom: 0,
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
                    : _series.isEmpty
                        ? Center(
                            child: Text(
                              'No practical series available',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: secondaryTextColor,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadSeries,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              itemCount: _series.length,
                              itemBuilder: (context, index) {
                                final series = _series[index];
                                final isItemLocked = isSubscribed ? false : index > 0;

                                return GestureDetector(
                                  onTap: () {
                                    if (isItemLocked) {
                                      _showEnrollmentPopup();
                                    } else {
                                      // Navigate to series detail screen with seriesId and packageType
                                      if (series.seriesId.isNotEmpty) {
                                        debugPrint('Navigating to: /series-detail/${series.seriesId}?packageType=Practical');
                                        context.push('/series-detail/${series.seriesId}?subscribed=$isSubscribed&packageType=Practical');
                                      } else {
                                        debugPrint('Error: Series ID is empty');
                                      }
                                    }
                                  },
                                  child: _buildSeriesCard(
                                    context,
                                    series.title,
                                    series.description ?? 'Hands-on practical training with step-by-step demonstrations.',
                                    '${series.totalLectures ?? 0} Videos',
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
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesCard(
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
                    color: textColor,
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return isoDate;
    }
  }
}
