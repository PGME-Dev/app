import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/models/package_model.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/features/home/providers/dashboard_provider.dart';

class AllPackagesScreen extends StatefulWidget {
  const AllPackagesScreen({super.key});

  @override
  State<AllPackagesScreen> createState() => _AllPackagesScreenState();
}

class _AllPackagesScreenState extends State<AllPackagesScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<PackageModel> _packages = [];
  String? _error;
  final DashboardService _dashboardService = DashboardService();

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get the user's selected subject from provider
      final dashboardProvider = context.read<DashboardProvider>();
      final subjectId = dashboardProvider.primarySubject?.subjectId;

      // Load packages for the selected subject
      final allPackages = await _dashboardService.getPackages(
        subjectId: subjectId,
        forceRefresh: true,
      );

      // Filter to only show Theory and Practical packages
      final filteredPackages = allPackages.where((pkg) {
        final type = pkg.type?.toLowerCase();
        return type == 'theory' || type == 'practical';
      }).toList();

      if (mounted) {
        setState(() {
          _packages = filteredPackages;
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

  String _formatPrice(int price) {
    return '₹${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _formatDuration(int? days) {
    if (days == null) return '';
    if (days >= 365) {
      final years = days ~/ 365;
      return '$years ${years == 1 ? 'year' : 'years'}';
    } else if (days >= 30) {
      final months = days ~/ 30;
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else {
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
  }

  int _calculateDiscount(int price, int? originalPrice) {
    if (originalPrice == null || originalPrice <= price) return 0;
    return ((originalPrice - price) * 100 / originalPrice).round();
  }

  List<Color> _getGradientColors(String? type, bool isDark) {
    if (type == 'Practical') {
      return isDark
          ? [const Color(0xFF3D2A6B), const Color(0xFF6B4EAF)]
          : [const Color(0xFF6B4EAF), const Color(0xFF9D7FD9)];
    }
    // Theory or default
    return isDark
        ? [const Color(0xFF0D2A5C), const Color(0xFF1A5A9E)]
        : [const Color(0xFF1847A2), const Color(0xFF5B9BD5)];
  }

  IconData _getPackageIcon(String? type) {
    if (type == 'Practical') {
      return Icons.science_outlined;
    }
    return Icons.menu_book_outlined;
  }

  void _selectPackage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _enrollPackage(PackageModel package) {
    context.pop();
    // Navigate to payment with selected package
    context.push('/purchase?packageId=${package.packageId}');
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : const Color(0xFFF5F7FA);
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final cardBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final borderColor = isDark ? AppColors.darkDivider : Colors.transparent;
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);
    final priceColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: priceColor),
        ),
      );
    }

    if (_error != null || _packages.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: secondaryTextColor),
              const SizedBox(height: 16),
              Text(
                _error != null ? 'Failed to load packages' : 'No packages available',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPackages,
                style: ElevatedButton.styleFrom(backgroundColor: priceColor),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(top: topPadding + 16, left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
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
                Expanded(
                  child: Text(
                    'Choose Your Package',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Package List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: bottomPadding + 100),
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                final package = _packages[index];
                final isSelected = _selectedIndex == index;
                return _buildPackageCard(package, index, isSelected, isDark, textColor, secondaryTextColor, cardBgColor, borderColor);
              },
            ),
          ),
        ],
      ),

      // Bottom Enroll Button
      bottomSheet: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: bottomPadding + 16),
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
            // Selected package info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _packages[_selectedIndex].name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatPrice(_packages[_selectedIndex].isOnSale && _packages[_selectedIndex].salePrice != null
                        ? _packages[_selectedIndex].salePrice!
                        : _packages[_selectedIndex].price),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: priceColor,
                    ),
                  ),
                ],
              ),
            ),
            // Enroll Button
            GestureDetector(
              onTap: () => _enrollPackage(_packages[_selectedIndex]),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(PackageModel package, int index, bool isSelected, bool isDark, Color textColor, Color secondaryTextColor, Color cardBgColor, Color borderColor) {
    final selectedBorderColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2);
    final featureTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF333333);
    final dividerColor = isDark ? AppColors.darkDivider : const Color(0xFFEEEEEE);
    final gradientColors = _getGradientColors(package.type, isDark);
    final displayPrice = package.isOnSale && package.salePrice != null ? package.salePrice! : package.price;
    final discount = _calculateDiscount(displayPrice, package.originalPrice);

    return GestureDetector(
      onTap: () => _selectPackage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedBorderColor : borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? selectedBorderColor.withValues(alpha: 0.15)
                  : (isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05)),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        _getPackageIcon(package.type),
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          package.type ?? 'Package',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badges
                  if (index == 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'POPULAR',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: gradientColors[0],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Features
                  if (package.features != null && package.features!.isNotEmpty)
                    ...package.features!.take(4).map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: gradientColors[0].withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: isDark ? gradientColors[1] : gradientColors[0],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: featureTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                  else
                    ..._getDefaultFeatures(package.type).map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: gradientColors[0].withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: isDark ? gradientColors[1] : gradientColors[0],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: featureTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                  const SizedBox(height: 10),
                  Divider(color: dividerColor, height: 1),
                  const SizedBox(height: 16),

                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice(displayPrice),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: isDark ? gradientColors[1] : gradientColors[0],
                        ),
                      ),
                      if (package.originalPrice != null && package.originalPrice! > displayPrice) ...[
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            _formatPrice(package.originalPrice!),
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
                      if (discount > 0) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (package.durationDays != null)
                        Text(
                          '/ ${_formatDuration(package.durationDays)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),

                  // Selection indicator
                  if (isSelected) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2)).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Selected Package',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF00BEFA) : const Color(0xFF1847A2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getDefaultFeatures(String? type) {
    if (type == 'Practical') {
      return [
        'Practical Demonstrations',
        'Live Sessions',
        'Lab Techniques',
        'Expert Support',
      ];
    }
    return [
      'Video Lectures',
      'Comprehensive Notes',
      'Live Doubt Sessions',
      'Practice MCQs',
    ];
  }
}
