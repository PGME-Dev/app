import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/models/series_document_model.dart';
import 'package:pgme/core/models/series_model.dart';
import 'package:pgme/core/models/package_model.dart';

class AvailableNotesScreen extends StatefulWidget {
  final String seriesId;

  const AvailableNotesScreen({
    super.key,
    required this.seriesId,
  });

  @override
  State<AvailableNotesScreen> createState() => _AvailableNotesScreenState();
}

class _AvailableNotesScreenState extends State<AvailableNotesScreen> {
  final DashboardService _dashboardService = DashboardService();

  List<SeriesDocumentModel> _documents = [];
  SeriesModel? _series;
  PackageModel? _package;
  bool _isLoading = true;
  String? _error;

  int? _expandedIndex = 0; // First card expanded by default

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
      // Fetch series details and documents in parallel
      final results = await Future.wait([
        _dashboardService.getSeriesDetails(widget.seriesId),
        _dashboardService.getSeriesDocuments(widget.seriesId),
      ]);

      final series = results[0] as SeriesModel;
      final documents = results[1] as List<SeriesDocumentModel>;

      // Fetch packages for the series subject if available
      PackageModel? package;
      if (series.subject?.subjectId != null) {
        try {
          final packages = await _dashboardService.getPackages(
            subjectId: series.subject!.subjectId,
            packageType: 'Theory',
          );
          if (packages.isNotEmpty) {
            package = packages.first;
          }
        } catch (e) {
          debugPrint('Failed to load package: $e');
        }
      }

      if (mounted) {
        setState(() {
          _series = series;
          _documents = documents;
          _package = package;
          _isLoading = false;
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
              _package != null ? 'Get the\n${_package!.name}' : 'Get the Theory\nPackage',
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
                _package?.description ?? 'Access theory modules, recorded lectures, and expert study resources',
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
                    _package?.name ?? 'Theory Package',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(_package?.features?.isNotEmpty == true
                      ? _package!.features!.take(3).map((feature) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildFeatureItem(feature, isDark, textColor, iconColor, featureBgColor),
                          ))
                      : [
                          _buildFeatureItem('Full access to theory content', isDark, textColor, iconColor, featureBgColor),
                          const SizedBox(height: 8),
                          _buildFeatureItem('Downloadable study materials', isDark, textColor, iconColor, featureBgColor),
                          const SizedBox(height: 8),
                          _buildFeatureItem('MCQ practice sets', isDark, textColor, iconColor, featureBgColor),
                        ]),
                  const SizedBox(height: 8),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 16),
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (_package?.isOnSale == true && _package!.salePrice != null) ...[
                        Text(
                          '₹${_package!.originalPrice?.toStringAsFixed(0) ?? _package!.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '₹${_package?.salePrice?.toStringAsFixed(0) ?? _package?.price.toStringAsFixed(0) ?? '4,999'}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 22.57,
                          height: 1.0,
                          letterSpacing: -0.18,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ ${_package?.durationDays != null ? '${(_package!.durationDays! / 30).round()} months' : '3 months'}',
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
                  if (_package?.isOnSale == true)
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

            const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool isDark, Color textColor, Color iconColor, Color featureBgColor) {
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
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: textColor,
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
    final cardBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final imagePlaceholderColor = isDark ? AppColors.darkSurface : const Color(0xFFD9D9D9);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(top: topPadding + 12, left: 16, right: 16),
            child: Row(
              children: [
                // Back arrow
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
                const Spacer(),
                // Title
                SizedBox(
                  width: 149,
                  height: 20,
                  child: Text(
                    'Available notes',
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
                const Spacer(),
                // Three dots menu
                GestureDetector(
                  onTap: () {
                    // Menu options
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

          const SizedBox(height: 22),

          // Image placeholder
          Container(
            width: 408,
            height: 196,
            margin: const EdgeInsets.only(left: 0),
            color: imagePlaceholderColor,
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 60,
                color: secondaryTextColor,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Notes List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: iconColor),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: secondaryTextColor),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load notes',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              style: ElevatedButton.styleFrom(backgroundColor: iconColor),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _documents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.description_outlined, size: 48, color: secondaryTextColor),
                                const SizedBox(height: 16),
                                Text(
                                  'No notes available',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ClipRect(
                            clipBehavior: Clip.none,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 120),
                              clipBehavior: Clip.none,
                              itemCount: _documents.length,
                              itemBuilder: (context, index) {
                                final document = _documents[index];
                                return _buildNoteCard(
                                  context,
                                  document: document,
                                  index: index,
                                  isExpanded: _expandedIndex == index,
                                  isDark: isDark,
                                  textColor: textColor,
                                  cardBgColor: cardBgColor,
                                  iconColor: iconColor,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context, {
    required SeriesDocumentModel document,
    required int index,
    required bool isExpanded,
    required bool isDark,
    required Color textColor,
    required Color cardBgColor,
    required Color iconColor,
  }) {
    final isLocked = !document.isFree;
    final placeholderColor = isDark ? AppColors.darkDivider : const Color(0xFFE8E8E8);
    final lockBadgeBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFDCEAF7);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          _showEnrollmentPopup();
        } else {
          setState(() {
            _expandedIndex = isExpanded ? null : index;
          });
        }
      },
      child: Container(
        width: 359,
        margin: EdgeInsets.only(top: index == 0 ? 4 : 0, bottom: 16),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image placeholder with lock overlay for locked items
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: placeholderColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      if (isLocked)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: lockBadgeBgColor,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.lock,
                                    size: 16,
                                    color: iconColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                document.title,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 1.2,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (isLocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: lockBadgeBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      size: 12,
                                      color: iconColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Locked',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: iconColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          document.description ?? 'No description available',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.4,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Animated buttons section
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: isExpanded
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          // Two buttons row
                          Row(
                            children: [
                              // View sample pdf button
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // View sample pdf action
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    child: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'View sample pdf',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // View full book button
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (isLocked) {
                                        _showEnrollmentPopup();
                                      } else {
                                        _showEnrollmentPopup(); // Show popup even for unlocked to upsell
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    child: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'View full book',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
