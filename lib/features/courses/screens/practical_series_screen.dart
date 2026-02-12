import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/models/series_model.dart';
import 'package:pgme/core/models/package_model.dart';
import 'package:pgme/core/models/live_session_model.dart';
import 'package:pgme/features/home/providers/dashboard_provider.dart';

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

  List<PackageModel> _packages = [];
  List<LiveSessionModel> _liveSessions = [];
  List<SeriesModel> _series = [];
  PackageModel? _selectedPackage;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      final primarySubjectId = dashboardProvider.primarySubject?.subjectId;

      // Fetch packages and live sessions in parallel
      final results = await Future.wait([
        _dashboardService.getPackages(
          subjectId: primarySubjectId,
          packageType: 'Practical',
        ),
        _dashboardService.getLiveSessions(
          subjectId: primarySubjectId,
          upcomingOnly: true,
          limit: 5,
        ),
      ]);

      final packages = results[0] as List<PackageModel>;
      final sessions = results[1] as List<LiveSessionModel>;

      setState(() {
        _packages = packages;
        _liveSessions = sessions;
        _isLoading = false;
      });

      // If a specific packageId was passed, go directly to that package's series
      if (widget.packageId != null) {
        final target = packages.where((p) => p.packageId == widget.packageId).firstOrNull;
        if (target != null) {
          _selectPackage(target);
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectPackage(PackageModel pkg) async {
    setState(() {
      _selectedPackage = pkg;
      _isLoading = true;
      _error = null;
    });

    try {
      final series = await _dashboardService.getPackageSeries(pkg.packageId);
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

  void _goBackToPackages() {
    setState(() {
      _selectedPackage = null;
      _series = [];
      _error = null;
    });
  }

  void _showEnrollmentPopup(PackageModel pkg) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    final shouldEnroll = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => _buildEnrollmentDialog(dialogContext, isDark, pkg),
    );

    if (shouldEnroll == true && mounted) {
      context.push('/purchase?packageId=${pkg.packageId}&packageType=Practical');
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final hasPracticalSubscription = dashboardProvider.hasPracticalSubscription;
    final isSubscribed = hasPracticalSubscription || widget.isSubscribed;

    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final cardBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFDCEAF7);

    final isOnLanding = _selectedPackage == null;
    final title = isOnLanding ? 'Practical Packages' : _selectedPackage!.name;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !isOnLanding) {
          _goBackToPackages();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            // App bar
            Padding(
              padding: EdgeInsets.only(top: topPadding + 12, left: 16, right: 16, bottom: 12),
              child: Row(
                children: [
                  if (!isOnLanding)
                    GestureDetector(
                      onTap: _goBackToPackages,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_back_rounded, size: 24, color: textColor),
                      ),
                    ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                          : _buildSeriesView(isDark, textColor, secondaryTextColor, iconColor, cardBgColor, isSubscribed),
            ),
          ],
        ),
      ),
    );
  }

  // ── Landing View (Sessions + Packages) ───────────────────────────────

  Widget _buildLandingView(
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
    Color cardBgColor,
    bool isSubscribed,
  ) {
    if (_packages.isEmpty && _liveSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, size: 48, color: textColor.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'No practical packages available',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new practical packages.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section 1: Upcoming Sessions ──
          if (_liveSessions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Upcoming Sessions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _liveSessions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: index < _liveSessions.length - 1 ? 12 : 0),
                    child: _buildSessionCard(
                      _liveSessions[index],
                      isDark: isDark,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      iconColor: iconColor,
                      cardBgColor: cardBgColor,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Section 2: Practical Packages ──
          if (_packages.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Practical Packages',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _packages.map((pkg) {
                  return _buildPackageCard(pkg, isDark, textColor, secondaryTextColor, iconColor, cardBgColor, isSubscribed);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Session Card (matches dashboard LiveClassBanner style) ──────────

  Widget _buildSessionCard(
    LiveSessionModel session, {
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
    required Color cardBgColor,
  }) {
    final isLive = session.status == 'live';

    return GestureDetector(
      onTap: () => context.push('/session/${session.sessionId}'),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: const Alignment(-0.85, 0),
            end: const Alignment(0.85, 0),
            colors: isDark
                ? [const Color(0xFF0D2A5C), const Color(0xFF2D5A9E)]
                : [const Color(0xFF1847A2), const Color(0xFF8EC6FF)],
            stops: const [0.35, 0.71],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Background illustration
              Positioned(
                right: -5,
                bottom: 5,
                child: Image.asset(
                  'assets/illustrations/home.png',
                  width: 130,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(width: 130, height: 70),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLive
                            ? Colors.red.withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        isLive ? 'LIVE NOW' : 'LIVE CLASS',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Title
                    SizedBox(
                      width: 160,
                      child: Text(
                        session.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Timing
                    Text(
                      isLive ? 'Live Now' : _formatSessionDateTime(session.scheduledStartTime),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),

                    const Spacer(),

                    // View Details button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Color(0xFF1847A2),
                        ),
                      ),
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

  Widget _buildPackageCard(
    PackageModel pkg,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
    Color cardBgColor,
    bool isSubscribed,
  ) {
    final isPurchased = pkg.isPurchased;
    final gradientStart = isDark ? const Color(0xFF1A3A5C) : const Color(0xFFCDE5FF);
    final gradientEnd = isDark ? const Color(0xFF2D5A9E) : const Color(0xFF8FC6FF);

    return GestureDetector(
      onTap: () => _selectPackage(pkg),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: title + status badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pkg.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: isDark ? Colors.white : const Color(0xFF000000),
                      ),
                    ),
                  ),
                  if (isPurchased)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              if (pkg.description != null && pkg.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  pkg.description!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.4,
                    color: (isDark ? Colors.white : const Color(0xFF000000)).withValues(alpha: 0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              // Features chips
              if (pkg.features != null && pkg.features!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: pkg.features!.take(3).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: isDark ? Colors.white : const Color(0xFF333333),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              // Price + action row
              Row(
                children: [
                  if (!isPurchased) ...[
                    if (pkg.isOnSale && pkg.salePrice != null) ...[
                      Text(
                        '₹${pkg.salePrice}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: isDark ? Colors.white : const Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${pkg.price}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                          color: (isDark ? Colors.white : const Color(0xFF000000)).withValues(alpha: 0.4),
                        ),
                      ),
                    ] else
                      Text(
                        '₹${pkg.price}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: isDark ? Colors.white : const Color(0xFF000000),
                        ),
                      ),
                    if (pkg.durationDays != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '/ ${_formatDuration(pkg.durationDays!)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: (isDark ? Colors.white : const Color(0xFF000000)).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isPurchased ? 'View' : 'Explore',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 16, color: iconColor),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Series View (after selecting a package) ───────────────────────────

  Widget _buildSeriesView(
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
              _showEnrollmentPopup(_selectedPackage!);
            } else if (series.seriesId.isNotEmpty) {
              context.push('/series-detail/${series.seriesId}?subscribed=$isSubscribed&packageType=Practical&packageId=${_selectedPackage!.packageId}');
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.play_circle_outline_rounded, size: 22, color: iconColor),
              ),
            ),
            const SizedBox(width: 14),
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
                    '${series.totalLectures ?? 0} Lectures${series.formattedDuration != 'N/A' ? ' · ${series.formattedDuration}' : ''}',
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
              onPressed: _selectedPackage != null ? () => _selectPackage(_selectedPackage!) : _loadPackages,
              style: ElevatedButton.styleFrom(backgroundColor: iconColor),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Enrollment Dialog ─────────────────────────────────────────────────

  Widget _buildEnrollmentDialog(BuildContext dialogContext, bool isDark, PackageModel pkg) {
    final dialogBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final boxBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFF5F5F5);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);

    final displayPrice = pkg.isOnSale && pkg.salePrice != null ? pkg.salePrice! : pkg.price;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        width: 356,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 80),
        decoration: BoxDecoration(color: dialogBgColor, borderRadius: BorderRadius.circular(20.8)),
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
                width: 180, height: 120, fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 180, height: 120,
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
                'Get ${pkg.name}',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20, color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  pkg.description ?? 'Unlock all series and get access to hands-on training materials.',
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
                      if (pkg.features != null)
                        ...pkg.features!.map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, size: 18, color: iconColor),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(f, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 13, color: textColor))),
                                ],
                              ),
                            )),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('₹$displayPrice', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 24, color: textColor)),
                          if (pkg.durationDays != null) ...[
                            const SizedBox(width: 8),
                            Text('/ ${_formatDuration(pkg.durationDays!)}', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 12, color: secondaryTextColor)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity, height: 40,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  String _formatSessionDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final time = '$hour:$minute $period';

      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Today, $time';
      }

      final tomorrow = now.add(const Duration(days: 1));
      if (dt.year == tomorrow.year && dt.month == tomorrow.month && dt.day == tomorrow.day) {
        return 'Tomorrow, $time';
      }

      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, $time';
    } catch (_) {
      return 'Upcoming';
    }
  }

  String _formatDuration(int days) {
    if (days >= 365) {
      final years = days ~/ 365;
      return '$years year${years > 1 ? 's' : ''}';
    } else if (days >= 30) {
      final months = days ~/ 30;
      return '$months month${months > 1 ? 's' : ''}';
    }
    return '$days days';
  }
}
