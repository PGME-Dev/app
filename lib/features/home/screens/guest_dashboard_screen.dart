import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/auth/providers/auth_provider.dart';
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

  /// Get display name (first name only) from AuthProvider
  String _getDisplayName(AuthProvider authProvider) {
    final fullName = authProvider.user?.name;
    if (fullName == null || fullName.isEmpty) {
      return 'User';
    }
    // Return first name only
    final firstName = fullName.split(' ').first;
    return firstName.isNotEmpty ? firstName : 'User';
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

  Future<void> _showSubjectPicker() async {
    final provider = context.read<DashboardProvider>();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    // Fetch subjects if not already loaded
    await provider.fetchAllSubjects();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SubjectPickerSheet(
        isDark: isDark,
        provider: provider,
      ),
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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer2<AuthProvider, DashboardProvider>(
        builder: (context, authProvider, provider, _) {
          final userName = _getDisplayName(authProvider);

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
                              GestureDetector(
                                onTap: _showSubjectPicker,
                                child: Text(
                                  'Browse All',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
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
              // Navigate to purchase screen with package data
              context.push('/purchase?packageId=${package.packageId}');
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

class _SubjectPickerSheet extends StatefulWidget {
  final bool isDark;
  final DashboardProvider provider;

  const _SubjectPickerSheet({
    required this.isDark,
    required this.provider,
  });

  @override
  State<_SubjectPickerSheet> createState() => _SubjectPickerSheetState();
}

class _SubjectPickerSheetState extends State<_SubjectPickerSheet> {
  String? _selectedSubjectId;

  Future<void> _onSubjectTap(subject) async {
    final isCurrentlySelected = widget.provider.primarySubject?.subjectId == subject.subjectId;
    if (isCurrentlySelected) return;

    setState(() {
      _selectedSubjectId = subject.subjectId;
    });

    final success = await widget.provider.changePrimarySubject(subject);

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subject changed to ${subject.name}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change subject'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final provider = widget.provider;
    final backgroundColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: secondaryTextColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Subject',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
                GestureDetector(
                  onTap: _selectedSubjectId != null ? null : () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: _selectedSubjectId != null
                        ? secondaryTextColor.withValues(alpha: 0.3)
                        : secondaryTextColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: secondaryTextColor.withValues(alpha: 0.2),
          ),

          // Content
          Flexible(
            child: ListenableBuilder(
              listenable: provider,
              builder: (context, _) {
                if (provider.isLoadingAllSubjects) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (provider.allSubjects.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 48,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No subjects available',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: provider.allSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = provider.allSubjects[index];
                    final isCurrentlySelected = provider.primarySubject?.subjectId == subject.subjectId;
                    final isBeingSelected = _selectedSubjectId == subject.subjectId;
                    final isDisabled = _selectedSubjectId != null && !isBeingSelected;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (_selectedSubjectId != null || isCurrentlySelected)
                            ? null
                            : () => _onSubjectTap(subject),
                        splashColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                        highlightColor: AppColors.primaryBlue.withValues(alpha: 0.05),
                        child: Opacity(
                          opacity: isDisabled ? 0.4 : 1.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                // Icon container
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isCurrentlySelected || isBeingSelected
                                        ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                        : (isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isBeingSelected
                                        ? Border.all(color: AppColors.primaryBlue, width: 2)
                                        : null,
                                  ),
                                  child: subject.iconUrl != null && subject.iconUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            subject.iconUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.school_outlined,
                                              color: isCurrentlySelected || isBeingSelected
                                                  ? AppColors.primaryBlue
                                                  : secondaryTextColor,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.school_outlined,
                                          color: isCurrentlySelected || isBeingSelected
                                              ? AppColors.primaryBlue
                                              : secondaryTextColor,
                                        ),
                                ),
                                const SizedBox(width: 16),

                                // Subject name
                                Expanded(
                                  child: Text(
                                    subject.name,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: isCurrentlySelected || isBeingSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      fontSize: 16,
                                      color: isCurrentlySelected || isBeingSelected
                                          ? AppColors.primaryBlue
                                          : textColor,
                                    ),
                                  ),
                                ),

                                // Trailing indicator
                                if (isBeingSelected)
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                                    ),
                                  )
                                else if (isCurrentlySelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primaryBlue,
                                    size: 24,
                                  )
                                else
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: secondaryTextColor.withValues(alpha: 0.5),
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
