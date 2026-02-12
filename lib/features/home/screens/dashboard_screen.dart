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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer2<AuthProvider, DashboardProvider>(
        builder: (context, authProvider, dashboardProvider, _) {
          final userName = _getDisplayName(authProvider);

          return RefreshIndicator(
            onRefresh: dashboardProvider.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Padding(
                    padding: EdgeInsets.only(top: topPadding + 20, left: 20, right: 20),
                    child: Row(
                      children: [
                        // Profile Avatar
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            width: 44,
                            height: 44,
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
                                      size: 24,
                                      color: isDark ? AppColors.darkTextTertiary : const Color(0xFFAAAAAA),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person_rounded,
                                      size: 24,
                                      color: isDark ? AppColors.darkTextTertiary : const Color(0xFFAAAAAA),
                                    ),
                                  )
                                : Icon(
                                    Icons.person_rounded,
                                    size: 24,
                                    color: isDark ? AppColors.darkTextTertiary : const Color(0xFFAAAAAA),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
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
                                  fontSize: 20,
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
                                  fontSize: 13,
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
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/icons/whatsapp_logo.png',
                                width: 20,
                                height: 20,
                                color: const Color(0xFF25D366),
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.chat_rounded,
                                    size: 20,
                                    color: Color(0xFF25D366),
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
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.notifications_outlined,
                                size: 22,
                                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF555555),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Live Class Carousel (auto-sliding with multiple sessions)
                  if (dashboardProvider.upcomingSessions.isNotEmpty)
                    LiveClassCarousel(sessions: dashboardProvider.upcomingSessions),

                  if (dashboardProvider.upcomingSessions.isNotEmpty) const SizedBox(height: 24),

                  // Subject Section (if available)
                  if (dashboardProvider.primarySubject != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardBackground
                              : const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          dashboardProvider.primarySubject!.subjectName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),

                  if (dashboardProvider.primarySubject != null) const SizedBox(height: 24),

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

                  if (dashboardProvider.hasActivePurchase == true) const SizedBox(height: 24),

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
          );
        },
      ),
    );
  }
}
