import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:pgme/core/models/live_session_model.dart';
import 'package:pgme/core/models/session_purchase_model.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/services/session_purchase_service.dart';
import 'package:pgme/core/theme/app_theme.dart';

class SessionDetailsScreen extends StatefulWidget {
  final String sessionId;

  const SessionDetailsScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  final DashboardService _dashboardService = DashboardService();
  final SessionPurchaseService _purchaseService = SessionPurchaseService();

  LiveSessionModel? _session;
  SessionAccessStatus? _accessStatus;
  bool _isLoading = true;
  bool _isCheckingAccess = false;
  bool _isPurchasing = false;
  String? _error;

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    _loadSessionDetails();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadSessionDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final session = await _dashboardService.getSessionDetails(widget.sessionId);

      // Debug: Log session pricing info
      debugPrint('=== Session Details Loaded ===');
      debugPrint('Title: ${session.title}');
      debugPrint('isFree: ${session.isFree}');
      debugPrint('price: ${session.price}');

      if (mounted) {
        setState(() {
          _session = session;
          _isLoading = false;
        });

        // Check access status after loading session
        _checkAccessStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAccessStatus() async {
    if (_session == null) return;

    debugPrint('=== Checking Access Status ===');
    debugPrint('Session isFree: ${_session!.isFree}');

    // If session is free, no need to check access
    if (_session!.isFree) {
      debugPrint('Session is FREE - granting access');
      setState(() {
        _accessStatus = SessionAccessStatus(
          hasAccess: true,
          isFree: true,
          price: 0,
        );
      });
      return;
    }

    debugPrint('Session is PAID - checking purchase status...');

    try {
      setState(() {
        _isCheckingAccess = true;
      });

      final accessStatus = await _purchaseService.checkSessionAccess(widget.sessionId);

      if (mounted) {
        setState(() {
          _accessStatus = accessStatus;
          _isCheckingAccess = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingAccess = false;
        });
        debugPrint('Error checking access: $e');
      }
    }
  }

  Future<void> _initiatePayment() async {
    if (_session == null) return;

    setState(() {
      _isPurchasing = true;
    });

    try {
      // Call test purchase endpoint (bypasses Razorpay, creates real DB record)
      final result = await _purchaseService.createTestPurchase(widget.sessionId);

      if (mounted) {
        setState(() {
          _isPurchasing = false;
          // Grant access based on backend response
          _accessStatus = SessionAccessStatus(
            hasAccess: true,
            isFree: false,
            price: _session!.price,
            purchaseId: result['purchase_id'] as String?,
            purchasedAt: DateTime.now().toIso8601String(),
          );
        });

        final message = result['already_purchased'] == true
            ? 'You already have access to this session.'
            : 'Payment successful! You now have access to this session.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await _purchaseService.verifyPayment(
        sessionId: widget.sessionId,
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! You now have access to this session.'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh access status
        _checkAccessStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isPurchasing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message ?? 'Unknown error'}'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
      ),
    );
  }

  Future<void> _launchMeeting() async {
    if (_session?.meetingLink == null || _session!.meetingLink!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting link not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if user has access before launching
    if (_accessStatus?.hasAccess != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please purchase this session to join'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Call join session API
      await _purchaseService.joinSession(widget.sessionId);

      final uri = Uri.parse(_session!.meetingLink!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch meeting');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join meeting: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatPlatformName(String platform) {
    switch (platform.toLowerCase()) {
      case 'zoom':
        return 'Zoom';
      case 'teams':
        return 'Microsoft Teams';
      case 'google_meet':
        return 'Google Meet';
      default:
        return platform;
    }
  }

  String _getStatusText() {
    if (_session == null) return '';
    switch (_session!.status.toLowerCase()) {
      case 'live':
        return 'LIVE NOW';
      case 'scheduled':
        return 'UPCOMING';
      case 'completed':
        return 'COMPLETED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return _session!.status.toUpperCase();
    }
  }

  Color _getStatusColor(bool isDark) {
    if (_session == null) return Colors.grey;
    switch (_session!.status.toLowerCase()) {
      case 'live':
        return Colors.red;
      case 'scheduled':
        return isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatPrice(int price) {
    return '₹${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
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
    final cardBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFE4F4FF);
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final buttonColor = isDark ? const Color(0xFF0047CF) : const Color(0xFF0000D1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState(textColor, iconColor)
              : _buildContent(
                  topPadding,
                  isDark,
                  backgroundColor,
                  textColor,
                  secondaryTextColor,
                  cardBgColor,
                  surfaceColor,
                  iconColor,
                  buttonColor,
                ),
    );
  }

  Widget _buildErrorState(Color textColor, Color iconColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: iconColor),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Failed to load session',
            style: TextStyle(color: textColor, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSessionDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    double topPadding,
    bool isDark,
    Color backgroundColor,
    Color textColor,
    Color secondaryTextColor,
    Color cardBgColor,
    Color surfaceColor,
    Color iconColor,
    Color buttonColor,
  ) {
    final hasAccess = _accessStatus?.hasAccess ?? _session?.isFree ?? true;
    final isFree = _session?.isFree ?? true;
    final price = _session?.price ?? 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          SizedBox(height: topPadding),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Stack(
              children: [
                // Back Arrow
                Positioned(
                  left: 16,
                  child: GestureDetector(
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
                ),
                // Title
                Center(
                  child: Text(
                    'Session Details',
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
              ],
            ),
          ),

          const SizedBox(height: 17),

          // Session Info Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Session Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _session?.thumbnailUrl != null
                          ? Image.network(
                              _session!.thumbnailUrl!,
                              width: 203,
                              height: 125,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildThumbnailPlaceholder(surfaceColor, iconColor);
                              },
                            )
                          : _buildThumbnailPlaceholder(surfaceColor, iconColor),
                    ),
                    const SizedBox(height: 8),

                    // LIVE SESSION label
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                        'LIVE SESSION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          letterSpacing: 0.05,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Session Title
                    Text(
                      _session?.title ?? 'Loading...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        height: 1.2,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 9),

                    // Faculty Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Faculty Avatar
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0),
                          ),
                          child: ClipOval(
                            child: _session?.facultyPhotoUrl != null
                                ? Image.network(
                                    _session!.facultyPhotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 16,
                                        color: secondaryTextColor,
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 16,
                                    color: secondaryTextColor,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _session?.facultyName ?? 'Faculty',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Badges Row
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(isDark),
                            borderRadius: BorderRadius.circular(41),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getStatusText(),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Duration Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: iconColor,
                            borderRadius: BorderRadius.circular(41),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_session?.durationMinutes ?? 0} MINUTES',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Price Badge (only if not free)
                        if (!isFree)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: hasAccess ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(41),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasAccess ? Icons.check_circle : Icons.lock,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  hasAccess ? 'PURCHASED' : _formatPrice(price),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Meeting Access Title
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              'Meeting Access',
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

          const SizedBox(height: 12),

          // Meeting Access Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0x4D000000),
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 10,
                          spreadRadius: 4,
                          offset: Offset(0, 6),
                        ),
                      ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Platform
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                        'PLATFORM',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPlatformName(_session?.platform ?? ''),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Opacity(
                      opacity: 0.5,
                      child: Container(
                        width: double.infinity,
                        height: 1,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Meeting Link or Purchase Required
                    if (hasAccess) ...[
                      Opacity(
                        opacity: 0.5,
                        child: Text(
                          'MEETING LINK',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _session?.meetingLink ?? 'Link will be available before session',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: iconColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      // Purchase required message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline, color: Colors.orange, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Purchase Required',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Get access to this session for ${_formatPrice(price)}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Action Button (Launch Meeting or Buy Now)
                    Center(
                      child: GestureDetector(
                        onTap: _isCheckingAccess || _isPurchasing
                            ? null
                            : (hasAccess ? _launchMeeting : _initiatePayment),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isCheckingAccess || _isPurchasing
                                ? Colors.grey
                                : (hasAccess
                                    ? (_session?.meetingLink != null ? buttonColor : Colors.grey)
                                    : Colors.orange),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Center(
                            child: _isCheckingAccess || _isPurchasing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!hasAccess) ...[
                                        const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        hasAccess
                                            ? 'LAUNCH MEETING'
                                            : 'BUY NOW - ${_formatPrice(price)}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          height: 1.11,
                                          letterSpacing: 0.09,
                                          color: Colors.white,
                                        ),
                                      ),
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
          ),

          const SizedBox(height: 24),

          // Session Description (if available)
          if (_session?.description != null && _session!.description!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'About This Session',
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
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _session!.description!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.5,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Meeting Instructions Title
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              'Meeting Instructions',
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

          const SizedBox(height: 12),

          // Meeting Instructions Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInstructionItem(
                      'Ensure your Student ID is visible in your profile name.',
                      textColor,
                      iconColor,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      'Mute your microphone upon entry to avoid echo.',
                      textColor,
                      iconColor,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      'Q&A session will follow the primary content.',
                      textColor,
                      iconColor,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      'Recording will be available 24 hours after the session.',
                      textColor,
                      iconColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 120), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildThumbnailPlaceholder(Color surfaceColor, Color iconColor) {
    return Container(
      width: 203,
      height: 125,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.play_circle_outline,
        size: 50,
        color: iconColor,
      ),
    );
  }

  Widget _buildInstructionItem(String text, Color textColor, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 20,
          color: iconColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Opacity(
            opacity: 0.7,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.43,
                letterSpacing: -0.5,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
