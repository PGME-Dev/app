import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pgme/features/auth/providers/auth_provider.dart';
import 'package:pgme/features/home/providers/dashboard_provider.dart';
import 'package:pgme/features/home/widgets/live_class_carousel.dart';
import 'package:pgme/features/home/widgets/for_you_section.dart';
import 'package:pgme/features/home/widgets/faculty_list.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _openWhatsApp() async {
    const phoneNumber = '+918074220727';
    const message = 'Hi, I need help with PGME app';
    final whatsappUrl = 'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}';

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open WhatsApp: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Get display name (first name only)
  String _getDisplayName(AuthProvider authProvider) {
    final fullName = authProvider.user?.name;
    if (fullName == null || fullName.isEmpty) {
      return 'User';
    }
    // Return first name only
    final firstName = fullName.split(' ').first;
    return firstName.isNotEmpty ? firstName : 'User';
  }

  /// Build Order Physical Book Card
  Widget _buildOrderBookCard(bool isDark, Color textColor, bool isTablet) {
    final cardHeight = ResponsiveHelper.orderBookCardHeight(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? ResponsiveHelper.horizontalPadding(context) : 15,
      ),
      child: GestureDetector(
        onTap: () => context.push('/order-physical-books'),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? ResponsiveHelper.maxContentWidth : double.infinity,
            ),
            child: Container(
              width: double.infinity,
              height: cardHeight,
              clipBehavior: Clip.none,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isTablet ? 24 : 14),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: isDark
                      ? [const Color(0xFF0D2A5C), const Color(0xFF1A3A5C)]
                      : [const Color(0xFF0047CF), const Color(0xFFE4F4FF)],
                  stops: const [0.3654, 1.0],
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Text
                  Positioned(
                    top: isTablet ? 28 : 13,
                    left: isTablet ? 28 : 12,
                    child: Opacity(
                      opacity: 0.9,
                      child: SizedBox(
                        width: isTablet ? 260 : 139,
                        child: Text(
                          'Order Physical\nCopies',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: isTablet ? 28 : 18,
                            height: 20 / 18,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Image
                  Positioned(
                    right: -130,
                    top: isTablet ? -150 : -120,
                    child: Transform.flip(
                      flipX: true,
                      child: Image.asset(
                        'assets/illustrations/4.png',
                        width: isTablet ? 420 : 350,
                        height: isTablet ? 420 : 350,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 350,
                            height: 350,
                            color: Colors.transparent,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);
    final isLandscape = ResponsiveHelper.isLandscape(context);

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);

    // Responsive sizes
    final avatarSize = ResponsiveHelper.profileAvatarSize(context);
    final actionBtnSize = ResponsiveHelper.actionButtonSize(context);
    final greetingFontSize = isTablet ? 30.0 : 20.0;
    final subtitleFontSize = isTablet ? 18.0 : 13.0;
    final hPadding = isTablet ? ResponsiveHelper.horizontalPadding(context) : 20.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer2<AuthProvider, DashboardProvider>(
        builder: (context, authProvider, dashboardProvider, _) {
          final userName = _getDisplayName(authProvider);

          return RefreshIndicator(
            onRefresh: dashboardProvider.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet && isLandscape ? 900 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Padding(
                        padding: EdgeInsets.only(top: topPadding + 20, left: hPadding, right: hPadding),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? ResponsiveHelper.maxContentWidth : double.infinity,
                            ),
                            child: Row(
                              children: [
                                // Profile Avatar
                                GestureDetector(
                                  onTap: () => context.push('/profile'),
                                  child: Container(
                                    width: avatarSize,
                                    height: avatarSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? AppColors.darkSurface : const Color(0xFFF0F0F0),
                                      border: Border.all(
                                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                                        width: 1.5,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: authProvider.user?.photoUrl != null && authProvider.user!.photoUrl!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: authProvider.user!.photoUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Icon(
                                              Icons.person_rounded,
                                              size: isTablet ? 40 : 24,
                                              color: isDark ? AppColors.darkTextTertiary : const Color(0xFFAAAAAA),
                                            ),
                                            errorWidget: (context, url, error) => Icon(
                                              Icons.person_rounded,
                                              size: isTablet ? 40 : 24,
                                              color: isDark ? AppColors.darkTextTertiary : const Color(0xFFAAAAAA),
                                            ),
                                          )
                                        : Icon(
                                            Icons.person_rounded,
                                            size: isTablet ? 40 : 24,
                                            color: isDark ? AppColors.darkTextTertiary : const Color(0xFFAAAAAA),
                                          ),
                                  ),
                                ),
                                SizedBox(width: isTablet ? 22 : 14),
                                // Greeting
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hello, $userName!',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          fontSize: greetingFontSize,
                                          height: 1.2,
                                          letterSpacing: -0.3,
                                          color: textColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'What do you want to learn today?',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: subtitleFontSize,
                                          height: 1.3,
                                          color: isDark ? AppColors.darkTextTertiary : const Color(0xFF999999),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Action buttons
                                GestureDetector(
                                  onTap: _openWhatsApp,
                                  child: Container(
                                    width: actionBtnSize,
                                    height: actionBtnSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/icons/whatsapp_logo.png',
                                        width: isTablet ? 32 : 20,
                                        height: isTablet ? 32 : 20,
                                        color: const Color(0xFF25D366),
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.chat_rounded,
                                            size: isTablet ? 32 : 20,
                                            color: const Color(0xFF25D366),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => context.push('/notifications'),
                                  child: Container(
                                    width: actionBtnSize,
                                    height: actionBtnSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.notifications_outlined,
                                        size: isTablet ? 34 : 22,
                                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF555555),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 40 : 25),

                      // Live Class Carousel (auto-sliding with multiple sessions and banners)
                      if (dashboardProvider.upcomingSessions.isNotEmpty || dashboardProvider.banners.isNotEmpty)
                        LiveClassCarousel(
                          sessions: dashboardProvider.upcomingSessions,
                          banners: dashboardProvider.banners,
                        ),

                      if (dashboardProvider.upcomingSessions.isNotEmpty || dashboardProvider.banners.isNotEmpty)
                        SizedBox(height: isTablet ? 36 : 24),

                      // Subject Section (if available)
                      if (dashboardProvider.primarySubject != null)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? ResponsiveHelper.horizontalPadding(context) : 16,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isTablet ? ResponsiveHelper.maxContentWidth : double.infinity,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 28 : 16,
                                  vertical: isTablet ? 14 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCardBackground
                                      : const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(isTablet ? 28 : 20),
                                ),
                                child: Text(
                                  dashboardProvider.primarySubject!.subjectName,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: isTablet ? 22 : 14,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (dashboardProvider.primarySubject != null) SizedBox(height: isTablet ? 36 : 24),

                      // For You Section (enrolled users)
                      if (dashboardProvider.hasActivePurchase == true)
                        ForYouSection(
                          lastWatched: dashboardProvider.lastWatchedVideo,
                          isLoading: dashboardProvider.isLoadingContent,
                          error: dashboardProvider.contentError,
                          onRetry: dashboardProvider.retryContent,
                          hasTheorySubscription: dashboardProvider.hasTheorySubscription,
                          hasPracticalSubscription: dashboardProvider.hasPracticalSubscription,
                        ),

                      if (dashboardProvider.hasActivePurchase == true) SizedBox(height: isTablet ? 36 : 24),

                      // Order Physical Book Card
                      _buildOrderBookCard(isDark, textColor, isTablet),

                      SizedBox(height: isTablet ? 36 : 24),

                      // Faculty List
                      FacultyList(
                        faculty: dashboardProvider.facultyList,
                        isLoading: dashboardProvider.isLoadingFaculty,
                        error: dashboardProvider.facultyError,
                        onRetry: dashboardProvider.retryFaculty,
                      ),

                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
