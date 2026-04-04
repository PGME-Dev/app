import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pgme/core_android/theme/app_theme.dart';
import 'package:pgme/core_android/constants/api_constants.dart';
import 'package:pgme/core_android/services/api_service.dart';
import 'package:pgme/core_android/utils/responsive_helper.dart';
import 'package:pgme/core_android/widgets/app_dialog.dart';

enum TutorialType { video, pdf }

class TutorialItem {
  final String title;
  final String url;
  final TutorialType type;

  const TutorialItem({
    required this.title,
    required this.url,
    required this.type,
  });

  factory TutorialItem.fromJson(Map<String, dynamic> json) {
    return TutorialItem(
      title: (json['title'] as String?) ?? 'Untitled',
      url: (json['url'] as String?) ?? '',
      type: json['type'] == 'pdf' ? TutorialType.pdf : TutorialType.video,
    );
  }
}

class TutorialSectionWidget extends StatefulWidget {
  const TutorialSectionWidget({super.key});

  @override
  State<TutorialSectionWidget> createState() => _TutorialSectionWidgetState();
}

class _TutorialSectionWidgetState extends State<TutorialSectionWidget> {
  List<TutorialItem> _tutorials = [];

  @override
  void initState() {
    super.initState();
    _loadTutorials();
  }

  Future<void> _loadTutorials() async {
    try {
      final response = await ApiService().dio.get(ApiConstants.tutorials);
      final data = response.data?['data'];
      if (data is Map<String, dynamic> && data['tutorials'] is List) {
        final List<dynamic> list = data['tutorials'];
        final parsed = list
            .whereType<Map<String, dynamic>>()
            .map((json) => TutorialItem.fromJson(json))
            .where((t) => t.url.isNotEmpty)
            .toList();
        if (mounted) {
          setState(() => _tutorials = parsed);
        }
      }
    } catch (e) {
      debugPrint('Error loading tutorials: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tutorials.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveHelper.isTablet(context);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.only(
            top: isTablet ? 32 : 24,
            bottom: isTablet ? 16 : 12,
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 44 : 36,
                height: isTablet ? 44 : 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                ),
                child: Icon(
                  Icons.school_rounded,
                  size: isTablet ? 24 : 20,
                  color: const Color(0xFFFF6B35),
                ),
              ),
              SizedBox(width: isTablet ? 14 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free Tutorials',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 22 : 18,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Free videos & PDFs for all subjects',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: isTablet ? 14 : 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Tutorial cards
        ..._tutorials.map((tutorial) => _buildTutorialCard(
              tutorial: tutorial,
              isDark: isDark,
              isTablet: isTablet,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            )),
      ],
    );
  }

  Widget _buildTutorialCard({
    required TutorialItem tutorial,
    required bool isDark,
    required bool isTablet,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final isVideo = tutorial.type == TutorialType.video;
    final typeColor = isVideo ? const Color(0xFFE53935) : const Color(0xFF1E88E5);
    final typeBgColor = typeColor.withValues(alpha: 0.1);
    final cardBg = isDark ? AppColors.darkCardBackground : Colors.white;
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 12 : 10),
      child: GestureDetector(
        onTap: () => _showExternalLinkDialog(tutorial),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 18 : 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 48 : 40,
                height: isTablet ? 48 : 40,
                decoration: BoxDecoration(
                  color: typeBgColor,
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                ),
                child: Icon(
                  isVideo ? Icons.play_circle_outline_rounded : Icons.picture_as_pdf_rounded,
                  size: isTablet ? 26 : 22,
                  color: typeColor,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: isTablet ? 16 : 14,
                        height: 1.3,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isVideo ? 'VIDEO' : 'PDF',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 11 : 10,
                              color: typeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'FREE',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 11 : 10,
                            color: AppColors.success,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: isTablet ? 22 : 18,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExternalLinkDialog(TutorialItem tutorial) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.open_in_new_rounded,
                    color: AppColors.primaryBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'External Link',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You are about to leave this app and be redirected to an external website. PGME is not responsible for the content of external sites.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.blueGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      side: BorderSide(
                        color: isDark ? AppColors.darkDivider : AppColors.divider,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final uri = Uri.parse(tutorial.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else if (mounted) {
          showAppDialog(context, message: 'Unable to open this link', type: AppDialogType.info);
        }
      } catch (e) {
        if (mounted) {
          showAppDialog(context, message: 'Unable to open this link', type: AppDialogType.info);
        }
      }
    }
  }
}
