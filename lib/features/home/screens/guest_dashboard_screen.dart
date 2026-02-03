import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/home/providers/dashboard_provider.dart';
import 'package:pgme/features/home/widgets/live_class_carousel.dart';
import 'package:pgme/features/home/widgets/faculty_list.dart';

class GuestDashboardScreen extends StatefulWidget {
  const GuestDashboardScreen({super.key});

  @override
  State<GuestDashboardScreen> createState() => _GuestDashboardScreenState();
}

class _GuestDashboardScreenState extends State<GuestDashboardScreen> {
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
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.refresh,
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
                                'Hello, ${provider.userName ?? 'User'}!',
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
                        // Notification and WhatsApp Icons
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Notification Icon
                            GestureDetector(
                              onTap: () {
                                // Open notifications
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCardBackground : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.notifications_outlined,
                                  size: 24,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // WhatsApp Icon
                            GestureDetector(
                              onTap: _openWhatsApp,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/icons/whatsapp_logo.png',
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.chat,
                                        size: 20,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Live Class Carousel (auto-sliding with multiple sessions)
                  if (provider.upcomingSessions.isNotEmpty)
                    LiveClassCarousel(sessions: provider.upcomingSessions),

                  if (provider.upcomingSessions.isNotEmpty) const SizedBox(height: 24),

                  // Subject Section (if available)
                  if (provider.primarySubject != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subject',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                'Browse All',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCardBackground
                                  : const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                provider.primarySubject!.subjectName,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (provider.primarySubject != null) const SizedBox(height: 24),

                  // What We Offer Section (guest users - no purchase)
                  if (provider.hasActivePurchase == false && provider.packages.isNotEmpty)
                    _buildWhatWeOfferSection(context, provider, isDark, textColor),

                  if (provider.hasActivePurchase == false && provider.packages.isNotEmpty)
                    const SizedBox(height: 24),

                  // Faculty List
                  FacultyList(
                    faculty: provider.facultyList,
                    isLoading: provider.isLoadingFaculty,
                    error: provider.facultyError,
                    onRetry: provider.retryFaculty,
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

  Widget _buildWhatWeOfferSection(
    BuildContext context,
    DashboardProvider provider,
    bool isDark,
    Color textColor,
  ) {
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'What We Offer',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: textColor,
                ),
              ),
              Text(
                'Browse All',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Package Cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: provider.packages
                .take(2)
                .map((package) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 180,
                        child: _buildPackageCard(package, isDark, textColor),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(package, bool isDark, Color textColor) {
    return Container(
      height: 376,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? const Color(0xFF1A3A5C)
            : const Color(0xFFDCEAF7),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play Icon
          Container(
            width: 150,
            height: 244,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 36,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Package Name
          Text(
            '${package.type ?? 'Package'} Package',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF000000),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Enroll Now Button
          GestureDetector(
            onTap: () {
              // Navigate to purchase screen
              context.push('/purchase');
            },
            child: Container(
              width: double.infinity,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Enroll Now',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // View Package Button
          GestureDetector(
            onTap: () {
              // Navigate to package details based on type
              if (package.type == 'Theory') {
                context.push('/revision-series?subscribed=false&packageId=${package.packageId}');
              } else if (package.type == 'Practical') {
                context.push('/practical-series?subscribed=false&packageId=${package.packageId}');
              }
            },
            child: Container(
              width: double.infinity,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'View Package',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
