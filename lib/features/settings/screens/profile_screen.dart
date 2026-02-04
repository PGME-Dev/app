import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/user_model.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/services/api_service.dart';
import 'package:pgme/core/services/auth_service.dart';
import 'package:pgme/core/services/user_service.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/settings/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  UserModel? _user;
  Map<String, dynamic>? _subscriptionStatus;
  bool _isLoading = true;
  String? _error;

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
      // Load user profile and subscription status in parallel
      final results = await Future.wait([
        _userService.getProfile(),
        _loadSubscriptionStatus(),
      ]);

      setState(() {
        _user = results[0] as UserModel;
        _subscriptionStatus = results[1] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _loadSubscriptionStatus() async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.subscriptionStatus,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error loading subscription status: $e');
      return null;
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authService.logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final cardColor = isDark ? AppColors.darkCardBackground : const Color(0xFFE4F4FF);
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF888888);
    final iconBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final iconColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final dividerColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final borderColor = isDark ? AppColors.darkDivider : const Color(0x5C000080);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: secondaryTextColor),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(fontSize: 14, color: secondaryTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Get active package info
    final theoryPackages = _subscriptionStatus?['theory_packages'] as List? ?? [];
    final practicalPackages = _subscriptionStatus?['practical_packages'] as List? ?? [];
    final hasTheory = _subscriptionStatus?['has_theory'] == true;
    final hasPractical = _subscriptionStatus?['has_practical'] == true;

    // Get the first active package for display
    Map<String, dynamic>? activePackage;
    if (theoryPackages.isNotEmpty) {
      activePackage = theoryPackages.first as Map<String, dynamic>;
    } else if (practicalPackages.isNotEmpty) {
      activePackage = practicalPackages.first as Map<String, dynamic>;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top curved box with profile info
              Container(
                width: double.infinity,
                height: 276,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 71),
                    // Profile picture circle
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: secondaryTextColor,
                          width: 3,
                        ),
                        color: Colors.transparent,
                        image: _user?.photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_user!.photoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _user?.photoUrl == null
                          ? Center(
                              child: Icon(
                                Icons.person_outline,
                                size: 40,
                                color: secondaryTextColor,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 31),
                    // Name
                    Text(
                      _user?.name ?? 'User',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        height: 20 / 18,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    // Phone number as subtitle
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                        _user?.phoneNumber ?? '',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 20 / 14,
                          letterSpacing: -0.5,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Active Packages Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Packages',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 20 / 16,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to packages
                      },
                      child: Opacity(
                        opacity: 0.4,
                        child: Text(
                          'Browse',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 20 / 12,
                            letterSpacing: -0.5,
                            color: textColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              // Active Package Box
              if (activePackage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    height: 182,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A4D) : const Color(0xFF0000D1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 9),
                        // Current Plan Badge
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Text(
                              'CURRENT PLAN',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                height: 20 / 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Plan Name
                        Padding(
                          padding: const EdgeInsets.only(left: 17),
                          child: Text(
                            activePackage['package_name'] ?? 'Active Package',
                            style: const TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              height: 20 / 14,
                              letterSpacing: 0.07,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Show both subscriptions if applicable
                        if (hasTheory && hasPractical)
                          Padding(
                            padding: const EdgeInsets.only(left: 17, top: 4),
                            child: Row(
                              children: [
                                _buildSubscriptionBadge('Theory', true),
                                const SizedBox(width: 8),
                                _buildSubscriptionBadge('Practical', true),
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(left: 17, top: 4),
                            child: Row(
                              children: [
                                if (hasTheory) _buildSubscriptionBadge('Theory', true),
                                if (hasPractical) _buildSubscriptionBadge('Practical', true),
                              ],
                            ),
                          ),
                        const Spacer(),
                        // Divider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Opacity(
                            opacity: 0.4,
                            child: Container(
                              height: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        // Expires and Manage Row
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 26, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Expires info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Opacity(
                                    opacity: 0.5,
                                    child: Text(
                                      'EXPIRES ON',
                                      style: TextStyle(
                                        fontFamily: 'SF Pro Display',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                        height: 20 / 10,
                                        letterSpacing: 0.05,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatExpiryDate(activePackage['expires_at']),
                                    style: const TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                      height: 20 / 10,
                                      letterSpacing: 0.05,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              // Manage Button
                              GestureDetector(
                                onTap: () {
                                  context.push('/manage-plans');
                                },
                                child: Container(
                                  width: 97,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Manage',
                                      style: TextStyle(
                                        fontFamily: 'SF Pro Display',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        height: 20 / 14,
                                        letterSpacing: 0.07,
                                        color: isDark ? const Color(0xFF1A1A4D) : const Color(0xFF0000D1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // No active package
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.card_membership_outlined, size: 48, color: secondaryTextColor),
                        const SizedBox(height: 12),
                        Text(
                          'No Active Packages',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse our packages to start learning',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Basic Information Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Basic Information',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 20 / 16,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to edit profile
                      },
                      child: Opacity(
                        opacity: 0.4,
                        child: Text(
                          'Edit',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 20 / 12,
                            letterSpacing: -0.5,
                            color: textColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 9),

              // Basic Information Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Full Name
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'FULL NAME',
                        value: _user?.name ?? 'Not set',
                        showDivider: true,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconBgColor: iconBgColor,
                        iconColor: iconColor,
                        dividerColor: dividerColor,
                      ),
                      // Email
                      _buildInfoRow(
                        icon: Icons.mail_outline,
                        label: 'EMAIL',
                        value: _user?.email ?? 'Not set',
                        showDivider: true,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconBgColor: iconBgColor,
                        iconColor: iconColor,
                        dividerColor: dividerColor,
                      ),
                      // Phone Number
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'PHONE NUMBER',
                        value: _user?.phoneNumber ?? 'Not set',
                        showDivider: true,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconBgColor: iconBgColor,
                        iconColor: iconColor,
                        dividerColor: dividerColor,
                      ),
                      // Gender
                      _buildInfoRow(
                        icon: Icons.wc_outlined,
                        label: 'GENDER',
                        value: _user?.gender ?? 'Not set',
                        showDivider: false,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconBgColor: iconBgColor,
                        iconColor: iconColor,
                        dividerColor: dividerColor,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Address Section (only if address exists)
              if (_user?.address != null && _user!.address!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Address',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 20 / 16,
                          letterSpacing: -0.5,
                          color: textColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to edit address
                        },
                        child: Opacity(
                          opacity: 0.4,
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              height: 20 / 12,
                              letterSpacing: -0.5,
                              color: textColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 9),

                // Address Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location icon circle
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconBgColor,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: iconColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Address text
                        Expanded(
                          child: Text(
                            _user!.address!,
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              height: 1.4,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],

              // Quick Actions Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 20 / 16,
                    letterSpacing: -0.5,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Quick Actions Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // My Orders
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.shopping_bag_outlined,
                        label: 'My Orders',
                        subtitle: 'Track orders',
                        onTap: () => context.push('/book-orders'),
                        cardColor: cardColor,
                        iconBgColor: isDark ? const Color(0xFF1A4D1A) : const Color(0xFFE8F5E9),
                        iconColor: Colors.green,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Settings
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        subtitle: 'Preferences',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        cardColor: cardColor,
                        iconBgColor: isDark ? const Color(0xFF1A1A4D) : const Color(0xFFE3F2FD),
                        iconColor: isDark ? const Color(0xFF90CAF9) : const Color(0xFF1976D2),
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Help & About Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Help & Support
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.help_outline,
                        label: 'Help',
                        subtitle: 'Get support',
                        onTap: () {
                          // Navigate to help
                        },
                        cardColor: cardColor,
                        iconBgColor: isDark ? const Color(0xFF4D4D1A) : const Color(0xFFFFF8E1),
                        iconColor: Colors.orange,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // About
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.info_outline,
                        label: 'About',
                        subtitle: 'App info',
                        onTap: () {
                          // Navigate to about
                        },
                        cardColor: cardColor,
                        iconBgColor: isDark ? const Color(0xFF4D1A4D) : const Color(0xFFF3E5F5),
                        iconColor: isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2),
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Log Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _handleLogout,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF4D1A1A) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF8B3A3A) : const Color(0xFFEF9A9A),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: isDark ? const Color(0xFFEF9A9A) : const Color(0xFFD32F2F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? const Color(0xFFEF9A9A) : const Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 120), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionBadge(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  String _formatExpiryDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildInfoRow({
    required IconData? icon,
    required String label,
    required String value,
    required bool showDivider,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconBgColor,
    required Color iconColor,
    required Color dividerColor,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBgColor,
                ),
                child: icon != null
                    ? Center(
                        child: Icon(
                          icon,
                          size: 22,
                          color: iconColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Label and Value
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        height: 1.5,
                        color: secondaryTextColor,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.4,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: dividerColor,
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required Color cardColor,
    required Color iconBgColor,
    required Color iconColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
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
    );
  }
}
