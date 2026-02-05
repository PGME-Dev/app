import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/models/package_model.dart';
import 'package:pgme/core/models/zoho_payment_models.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/widgets/zoho_payment_widget.dart';
import 'package:pgme/features/home/providers/dashboard_provider.dart';

class PurchaseScreen extends StatefulWidget {
  final String? packageId;
  final String? packageType; // 'Theory' or 'Practical'

  const PurchaseScreen({super.key, this.packageId, this.packageType});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool _isProcessing = false;
  bool _isLoading = true;
  PackageModel? _package;
  String? _error;
  final DashboardService _dashboardService = DashboardService();

  @override
  void initState() {
    super.initState();
    _loadPackageData();
  }

  Future<void> _loadPackageData() async {
    if (widget.packageId == null && widget.packageType == null) {
      // If no packageId or packageType provided, try to get the first package from dashboard
      final dashboardProvider = context.read<DashboardProvider>();
      if (dashboardProvider.packages.isNotEmpty) {
        setState(() {
          _package = dashboardProvider.packages.first;
          _isLoading = false;
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load packages and find the one with matching ID or type
      final packages = await _dashboardService.getPackages();

      if (mounted) {
        PackageModel? foundPackage;
        if (widget.packageId != null) {
          // Find by packageId
          foundPackage = packages.firstWhere(
            (p) => p.packageId == widget.packageId,
            orElse: () => packages.isNotEmpty ? packages.first : throw Exception('No packages available'),
          );
        } else if (widget.packageType != null) {
          // Find by packageType (Theory or Practical)
          foundPackage = packages.firstWhere(
            (p) => p.type?.toLowerCase() == widget.packageType!.toLowerCase(),
            orElse: () => packages.isNotEmpty ? packages.first : throw Exception('No packages available'),
          );
        } else if (packages.isNotEmpty) {
          foundPackage = packages.first;
        }

        setState(() {
          _package = foundPackage;
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

  void _showPaymentPopup() async {
    if (_package == null) return;

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

    final package = _package!;
    final displayPrice = package.isOnSale && package.salePrice != null
        ? package.salePrice!
        : package.price;

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
                'Get the ${package.type ?? ''}\nPackage',
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
              if (package.description != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    package.description!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.05,
                      letterSpacing: -0.18,
                      color: secondaryTextColor,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
                      package.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Features
                    if (package.features != null && package.features!.isNotEmpty)
                      ...package.features!.take(4).map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildPopupFeatureItem(feature, isDark, textColor, iconColor, featureBgColor),
                      ))
                    else ...[
                      _buildPopupFeatureItem('Full access to ${package.type?.toLowerCase() ?? ''} content', isDark, textColor, iconColor, featureBgColor),
                      const SizedBox(height: 8),
                      _buildPopupFeatureItem('Expert faculty guidance', isDark, textColor, iconColor, featureBgColor),
                      const SizedBox(height: 8),
                      _buildPopupFeatureItem('24/7 doubt resolution support', isDark, textColor, iconColor, featureBgColor),
                    ],
                    const SizedBox(height: 16),
                    Divider(height: 1, color: borderColor),
                    const SizedBox(height: 16),
                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatPrice(displayPrice),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 24,
                            height: 1.0,
                            letterSpacing: -0.18,
                            color: textColor,
                          ),
                        ),
                        if (package.durationDays != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '/ ${_formatDuration(package.durationDays)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (package.isOnSale) ...[
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
                    ],
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
    if (_package == null) return;

    setState(() => _isProcessing = true);

    try {
      // Step 1: Create Zoho payment session
      final paymentSession = await _dashboardService.createPackagePaymentSession(
        _package!.packageId,
      );

      if (!mounted) return;

      // Step 2: Show Zoho payment widget
      final result = await Navigator.push<ZohoPaymentResponse>(
        context,
        MaterialPageRoute(
          builder: (context) => ZohoPaymentWidget(
            paymentSession: paymentSession,
            onPaymentComplete: (response) {
              Navigator.pop(context, response);
            },
          ),
          fullscreenDialog: true,
        ),
      );

      // Step 3: Handle payment response
      if (result != null && mounted) {
        if (result.isSuccess) {
          // Verify payment with backend
          final verification = await _dashboardService.verifyPackagePayment(
            paymentSessionId: result.paymentSessionId!,
            paymentId: result.paymentId!,
            signature: result.signature,
          );

          if (verification.success && mounted) {
            setState(() => _isProcessing = false);
            // Navigate to congratulations screen with purchase ID
            context.go('/congratulations?purchaseId=${verification.purchaseId}');
          } else if (mounted) {
            _showError('Payment verification failed. Please contact support.');
          }
        } else if (result.isFailed) {
          _showError('Payment failed: ${result.errorMessage ?? "Unknown error"}');
        } else if (result.isCancelled) {
          _showInfo('Payment cancelled');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error processing payment: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceAll('Exception: ', '')),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: iconColor),
        ),
      );
    }

    if (_error != null || _package == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: secondaryTextColor),
              const SizedBox(height: 16),
              Text(
                'Failed to load package',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPackageData,
                style: ElevatedButton.styleFrom(backgroundColor: iconColor),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final package = _package!;
    final displayPrice = package.isOnSale && package.salePrice != null
        ? package.salePrice!
        : package.price;
    final discount = _calculateDiscount(displayPrice, package.originalPrice);

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
                              package.type == 'Practical' ? Icons.science : Icons.school,
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
                                child: Text(
                                  '${package.type?.toUpperCase() ?? 'COURSE'} PACKAGE',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                package.name,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  if (package.durationDays != null) ...[
                                    const Icon(Icons.access_time, size: 16, color: Colors.white70),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_formatDuration(package.durationDays)} Access',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
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
                    package.description ?? 'Master your medical education with our comprehensive ${package.type?.toLowerCase() ?? ''} package. This course covers all essential topics with expert faculty guidance and structured learning paths.',
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

                // Feature Cards from package features
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: _buildFeatureCards(package, isDark, textColor, cardBgColor, borderColor, iconBgColor, iconColor),
                  ),
                ),

                const SizedBox(height: 24),

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
                            _formatPrice(displayPrice),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              color: priceColor,
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
                        ],
                      ),
                      if (discount > 0) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
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

  List<Widget> _buildFeatureCards(
    PackageModel package,
    bool isDark,
    Color textColor,
    Color cardBgColor,
    Color borderColor,
    Color iconBgColor,
    Color iconColor,
  ) {
    final features = package.features;

    if (features != null && features.isNotEmpty) {
      return features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildFeatureCard(
            icon: _getFeatureIcon(feature),
            title: feature,
            subtitle: '',
            isDark: isDark,
            textColor: textColor,
            cardBgColor: cardBgColor,
            borderColor: borderColor,
            iconBgColor: iconBgColor,
            iconColor: iconColor,
          ),
        );
      }).toList();
    }

    // Default features if none provided
    final defaultFeatures = package.type == 'Practical'
        ? [
            {'icon': Icons.science_outlined, 'title': 'Practical Demonstrations', 'subtitle': 'Hands-on learning experience'},
            {'icon': Icons.live_tv_outlined, 'title': 'Live Sessions', 'subtitle': 'Interactive live classes'},
            {'icon': Icons.support_agent_outlined, 'title': 'Expert Support', 'subtitle': '24/7 doubt resolution'},
          ]
        : [
            {'icon': Icons.video_library_outlined, 'title': 'Video Lectures', 'subtitle': 'High-quality recorded content'},
            {'icon': Icons.menu_book_outlined, 'title': 'Study Materials', 'subtitle': 'Comprehensive notes & PDFs'},
            {'icon': Icons.support_agent_outlined, 'title': 'Expert Support', 'subtitle': '24/7 doubt resolution'},
          ];

    return defaultFeatures.map((f) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildFeatureCard(
          icon: f['icon'] as IconData,
          title: f['title'] as String,
          subtitle: f['subtitle'] as String,
          isDark: isDark,
          textColor: textColor,
          cardBgColor: cardBgColor,
          borderColor: borderColor,
          iconBgColor: iconBgColor,
          iconColor: iconColor,
        ),
      );
    }).toList();
  }

  IconData _getFeatureIcon(String feature) {
    final lowerFeature = feature.toLowerCase();
    if (lowerFeature.contains('video') || lowerFeature.contains('lecture')) {
      return Icons.video_library_outlined;
    } else if (lowerFeature.contains('live') || lowerFeature.contains('session')) {
      return Icons.live_tv_outlined;
    } else if (lowerFeature.contains('note') || lowerFeature.contains('material') || lowerFeature.contains('pdf')) {
      return Icons.menu_book_outlined;
    } else if (lowerFeature.contains('test') || lowerFeature.contains('quiz') || lowerFeature.contains('mcq')) {
      return Icons.quiz_outlined;
    } else if (lowerFeature.contains('support') || lowerFeature.contains('doubt')) {
      return Icons.support_agent_outlined;
    } else if (lowerFeature.contains('practical') || lowerFeature.contains('lab')) {
      return Icons.science_outlined;
    } else {
      return Icons.check_circle_outline;
    }
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
                if (subtitle.isNotEmpty) ...[
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
}
