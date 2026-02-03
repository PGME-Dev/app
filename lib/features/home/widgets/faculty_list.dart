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
                    return _buildFacultyCard(
                      member,
                      isDark,
                      textColor,
                      cardBgColor,
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
