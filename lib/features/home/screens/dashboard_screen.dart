import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/auth/providers/auth_provider.dart';
import 'package:pgme/features/home/providers/dashboard_provider.dart';
import 'package:pgme/features/home/widgets/live_class_carousel.dart';
import 'package:pgme/features/home/widgets/for_you_section.dart';
import 'package:pgme/features/home/widgets/faculty_list.dart';
import 'package:pgme/features/home/widgets/dashboard_skeleton.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data on init
    Future.microtask(() {
      if (mounted) {
        context.read<DashboardProvider>().loadDashboard();
      }
    });
  }

  Future<void> _openWhatsApp() async {
    const phoneNumber = '+919630000080';
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
          // Show skeleton loader during initial load
          if (dashboardProvider.isInitialLoading) {
            return const DashboardSkeleton();
          }

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
                    padding: EdgeInsets.only(top: topPadding + 16, left: 23, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hello text and subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $userName!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 22,
                                  height: 20 / 22,
                                  letterSpacing: -0.5,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Opacity(
                                opacity: 0.4,
                                child: Text(
                                  'What do you want to learn today?',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    height: 1.05,
                                    letterSpacing: -1,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Get Help Button and Notification
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _openWhatsApp,
                              child: Container(
                                width: 103,
                                height: 31,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: const Color(0xFF138808),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Get Help',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        height: 20 / 14,
                                        letterSpacing: -0.5,
                                        color: Color(0xFF138808),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Image.asset(
                                      'assets/icons/whatsapp_logo.png',
                                      width: 20,
                                      height: 20,
                                      color: const Color(0xFF138808),
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.chat,
                                          size: 18,
                                          color: Color(0xFF138808),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Notification Icon
                            GestureDetector(
                              onTap: () {
                                // Open notifications
                              },
                              child: Icon(
                                Icons.notifications_outlined,
                                size: 24,
                                color: textColor,
                              ),
                            ),
                          ],
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
