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
  Map<String, dynamic>? _selectedSubject;
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
      // Load user profile, subscription status, and selected subject in parallel
      final results = await Future.wait([
        _userService.getProfile(),
        _loadSubscriptionStatus(),
        _loadSelectedSubject(),
      ]);

      setState(() {
        _user = results[0] as UserModel;
        _subscriptionStatus = results[1] as Map<String, dynamic>?;
        _selectedSubject = results[2] as Map<String, dynamic>?;
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

  Future<Map<String, dynamic>?> _loadSelectedSubject() async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.subjectSelection,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final selections = response.data['data'] as List?;
        if (selections != null && selections.isNotEmpty) {
          // Return the primary subject or the first one
          final primary = selections.firstWhere(
            (s) => s['is_primary'] == true,
            orElse: () => selections.first,
          );
          return primary as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error loading selected subject: $e');
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

    // Get active package info - combine all packages with their type
    final theoryPackages = (_subscriptionStatus?['theory_packages'] as List? ?? [])
        .map((p) => {...(p as Map<String, dynamic>), 'type': 'Theory'})
        .toList();
    final practicalPackages = (_subscriptionStatus?['practical_packages'] as List? ?? [])
        .map((p) => {...(p as Map<String, dynamic>), 'type': 'Practical'})
        .toList();

    // Combine all active packages
    final allActivePackages = [...theoryPackages, ...practicalPackages];

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
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile picture on the left
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF555555) : const Color(0xFFCCCCCC),
                              width: 2,
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
                                    size: 36,
                                    color: secondaryTextColor,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        // User details on the right
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Name
                              Text(
                                _user?.name ?? 'User',
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Phone number
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 14,
                                    color: secondaryTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _user?.phoneNumber ?? '',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Subject selection - tappable
                              GestureDetector(
                                onTap: () {
                                  context.push('/subject-selection');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1A1A4D)
                                        : const Color(0xFF0000D1).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF3D3D8C)
                                          : const Color(0xFF0000D1).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.menu_book_outlined,
                                        size: 14,
                                        color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF0000D1),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          _selectedSubject?['subject_name'] ?? 'Select Subject',
                                          style: TextStyle(
                                            fontFamily: 'SF Pro Display',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF0000D1),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 16,
                                        color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF0000D1),
                                      ),
                                    ],
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
                        context.push('/manage-plans');
                      },
                      child: Text(
                        'Manage',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          height: 20 / 12,
                          letterSpacing: -0.5,
                          color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF0000D1),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              // Active Package Cards - Horizontally Scrollable
              if (allActivePackages.isNotEmpty)
                SizedBox(
                  height: 115,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allActivePackages.length,
                    itemBuilder: (context, index) {
                      final package = allActivePackages[index];
                      final isLast = index == allActivePackages.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 12),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _buildActivePackageCard(
                            package: package,
                            isDark: isDark,
                          ),
                        ),
                      );
                    },
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
                        onTap: () => context.push('/help'),
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
                        onTap: () => context.push('/about'),
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

  String _formatExpiryDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildActivePackageCard({
    required Map<String, dynamic> package,
    required bool isDark,
  }) {
    final packageName = package['package_name'] ?? 'Package';
    final packageType = package['type'] ?? '';
    final expiresAt = package['expires_at'];
    final daysRemaining = package['days_remaining'] ?? 0;

    // Use different colors for Theory vs Practical
    final isTheory = packageType == 'Theory';
    final cardColor = isDark
        ? (isTheory ? const Color(0xFF1A1A4D) : const Color(0xFF1A4D4D))
        : (isTheory ? const Color(0xFF0000D1) : const Color(0xFF00897B));

    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row with ACTIVE badge and package type
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w600,
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (packageType.isNotEmpty)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      packageType,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Plan Name
          Text(
            packageName,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.white,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Divider
          Opacity(
            opacity: 0.3,
            child: Container(
              height: 1,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Expires and Days Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Opacity(
                      opacity: 0.6,
                      child: Text(
                        'EXPIRES',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: 8,
                          letterSpacing: 0.5,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      _formatExpiryDate(expiresAt),
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$daysRemaining days',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                    color: cardColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
