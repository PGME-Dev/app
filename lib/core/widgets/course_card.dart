import 'package:flutter/material.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? instructor;
  final String? imageUrl;
  final double? progress;
  final String? tag;
  final Color? tagColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const CourseCard({
    super.key,
    required this.title,
    this.subtitle,
    this.instructor,
    this.imageUrl,
    this.progress,
    this.tag,
    this.tagColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (imageUrl != null)
              Container(
                height: isTablet ? 180 : 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(isTablet ? 20 : 16)),
                  color: AppColors.primaryBlue.withOpacity(0.1),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: isTablet ? 60 : 48,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    if (tag != null)
                      Positioned(
                        top: isTablet ? 16 : 12,
                        left: isTablet ? 16 : 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : 12,
                            vertical: isTablet ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: tagColor ?? AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                          ),
                          child: Text(
                            tag!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Content Section
            Padding(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: isTablet ? 18 : null,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: isTablet ? 8 : 6),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: isTablet ? 15 : null,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (instructor != null) ...[
                    SizedBox(height: isTablet ? 10 : 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: isTablet ? 20 : 16,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: isTablet ? 6 : 4),
                        Text(
                          instructor!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: isTablet ? 15 : null,
                              ),
                        ),
                      ],
                    ),
                  ],
                  if (progress != null) ...[
                    SizedBox(height: isTablet ? 16 : 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(progress! * 100).toInt()}% Complete',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: isTablet ? 15 : null,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 8 : 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(isTablet ? 5 : 4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryBlue,
                            ),
                            minHeight: isTablet ? 8 : 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (trailing != null) ...[
                    SizedBox(height: isTablet ? 16 : 12),
                    trailing!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
