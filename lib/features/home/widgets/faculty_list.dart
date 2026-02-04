import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pgme/core/models/faculty_model.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class FacultyList extends StatelessWidget {
  final List<FacultyModel> faculty;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const FacultyList({
    super.key,
    required this.faculty,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  void _showFacultyDetails(BuildContext context, FacultyModel member, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => _FacultyDetailSheet(
        faculty: member,
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFFFFFFF);

    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Faculty',
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

        // Faculty Cards
        SizedBox(
          height: 160,
          child: faculty.isEmpty
              ? Center(
                  child: Text(
                    'No faculty members available',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: faculty.length,
                  itemBuilder: (context, index) {
                    final member = faculty[index];
                    return GestureDetector(
                      onTap: () => _showFacultyDetails(context, member, isDark),
                      child: _buildFacultyCard(
                        member,
                        isDark,
                        textColor,
                        cardBgColor,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFacultyCard(
    FacultyModel member,
    bool isDark,
    Color textColor,
    Color cardBgColor,
  ) {
    return Container(
      width: 140,
      height: 148,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : const Color(0xFF000080),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),

          // Faculty Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: member.photoUrl != null && member.photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: member.photoUrl!,
                    width: 88,
                    height: 81,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 88,
                      height: 81,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFE0E0E0),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 88,
                      height: 81,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFE0E0E0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : const Color(0xFF999999),
                      ),
                    ),
                  )
                : Image.asset(
                    'assets/illustrations/doc.png',
                    width: 88,
                    height: 81,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 88,
                        height: 81,
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.darkSurface : const Color(0xFFE0E0E0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : const Color(0xFF999999),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 8),

          // Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              member.name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FacultyDetailSheet extends StatelessWidget {
  final FacultyModel faculty;
  final bool isDark;

  const _FacultyDetailSheet({
    required this.faculty,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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

          // Header with close button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Faculty Profile',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: secondaryTextColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 16,
            color: secondaryTextColor.withValues(alpha: 0.2),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  // Faculty Photo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: faculty.photoUrl != null && faculty.photoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: faculty.photoUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: isDark ? AppColors.darkSurface : const Color(0xFFE0E0E0),
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: isDark ? AppColors.darkSurface : const Color(0xFFE0E0E0),
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: isDark ? AppColors.darkTextTertiary : const Color(0xFF999999),
                                ),
                              ),
                            )
                          : Container(
                              color: isDark ? AppColors.darkSurface : const Color(0xFFE0E0E0),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: isDark ? AppColors.darkTextTertiary : const Color(0xFF999999),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name
                  Text(
                    faculty.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // Specialization
                  Text(
                    faculty.specialization,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Info Cards Row
                  Row(
                    children: [
                      // Experience
                      if (faculty.experienceYears != null)
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.work_outline,
                            label: 'Experience',
                            value: '${faculty.experienceYears} years',
                            isDark: isDark,
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                          ),
                        ),
                      if (faculty.experienceYears != null && faculty.qualifications != null)
                        const SizedBox(width: 12),
                      // Qualifications
                      if (faculty.qualifications != null)
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.school_outlined,
                            label: 'Qualification',
                            value: faculty.qualifications!,
                            isDark: isDark,
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                          ),
                        ),
                    ],
                  ),

                  // Bio Section
                  if (faculty.bio != null && faculty.bio!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'About',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        faculty.bio!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: secondaryTextColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
