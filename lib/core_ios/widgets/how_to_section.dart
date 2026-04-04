import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pgme/core_ios/constants/api_constants.dart';
import 'package:pgme/core_ios/services/api_service.dart';
import 'package:pgme/core_ios/providers/theme_provider.dart';
import 'package:pgme/core_ios/theme/app_theme.dart';
import 'package:pgme/core_ios/utils/responsive_helper.dart';
import 'package:pgme/core_ios/widgets/app_dialog.dart';

class _TutorialItem {
  final String title;
  final String url;
  final _TutorialType type;
  final String? description;
  final String? body;
  final String? thumbnailUrl;
  final String? mediaUrl;

  const _TutorialItem({
    required this.title,
    required this.url,
    required this.type,
    this.description,
    this.body,
    this.thumbnailUrl,
    this.mediaUrl,
  });

  factory _TutorialItem.fromJson(Map<String, dynamic> json) {
    return _TutorialItem(
      title: (json['title'] as String?) ?? 'Untitled',
      url: (json['url'] as String?) ?? '',
      type: json['type'] == 'pdf' ? _TutorialType.pdf : _TutorialType.video,
      description: json['description'] as String?,
      body: json['body'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      mediaUrl: json['media_url'] as String?,
    );
  }

  String get actionUrl => mediaUrl ?? url;
  bool get hasAction => actionUrl.isNotEmpty;
}

enum _TutorialType { video, pdf }

/// A self-contained "How To" tutorials section.
/// Fetches tutorials for the given [screen] from the API and displays them.
/// Drop this widget into any screen's scroll content.
class HowToSection extends StatefulWidget {
  /// Which screen to fetch tutorials for: 'home', 'theory', 'practical', 'notes'
  final String screen;

  const HowToSection({super.key, required this.screen});

  @override
  State<HowToSection> createState() => _HowToSectionState();
}

class _HowToSectionState extends State<HowToSection> {
  List<_TutorialItem> _tutorials = [];

  @override
  void initState() {
    super.initState();
    _loadTutorials();
  }

  Future<void> _loadTutorials() async {
    try {
      final response = await ApiService().dio.get(
        ApiConstants.tutorials,
        queryParameters: {'screen': widget.screen},
      );
      final data = response.data?['data'];
      if (data is Map<String, dynamic> && data['tutorials'] is List) {
        final List<dynamic> list = data['tutorials'];
        final parsed = list
            .whereType<Map<String, dynamic>>()
            .map((json) => _TutorialItem.fromJson(json))
            .toList();
        if (mounted) {
          setState(() => _tutorials = parsed);
        }
      }
    } catch (e) {
      debugPrint('Error loading tutorials for ${widget.screen}: $e');
    }
  }

  void _showDetailSheet(_TutorialItem tutorial) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final hasBody = tutorial.body != null && tutorial.body!.isNotEmpty;
    final hasDesc = tutorial.description != null && tutorial.description!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (sheetCtx, scrollController) => Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  decoration: BoxDecoration(color: textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    // Thumbnail
                    if (tutorial.thumbnailUrl != null && tutorial.thumbnailUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            tutorial.thumbnailUrl!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    if (tutorial.thumbnailUrl != null && tutorial.thumbnailUrl!.isNotEmpty)
                      const SizedBox(height: 12),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        tutorial.title,
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: textPrimary),
                      ),
                    ),
                    if (hasDesc)
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 4),
                        child: Text(
                          tutorial.description!,
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 13, color: textSecondary),
                        ),
                      ),
                    // Body text
                    if (hasBody) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          tutorial.body!,
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 15, height: 1.6, color: textPrimary),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Fixed button at the bottom
              if (tutorial.hasAction)
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: MediaQuery.of(context).padding.bottom + 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border(top: BorderSide(color: textSecondary.withValues(alpha: 0.1))),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: DecoratedBox(
                          decoration: BoxDecoration(gradient: AppColors.blueGradient, borderRadius: BorderRadius.circular(14)),
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _openLink(tutorial);
                            },
                            icon: const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.white),
                            label: Text(
                              tutorial.mediaUrl != null ? 'Open File' : 'Open Link',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                            ),
                            style: TextButton.styleFrom(foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You will be redirected outside this app.',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLink(_TutorialItem tutorial) async {
    try {
      final uri = Uri.parse(tutorial.actionUrl);
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

  @override
  Widget build(BuildContext context) {
    if (_tutorials.isEmpty) return const SizedBox.shrink();

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);
    final scale = ResponsiveHelper.tabletScale(context);
    final hPadding = isTablet ? ResponsiveHelper.horizontalPadding(context) : 16.0;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.only(left: hPadding, right: hPadding, top: isTablet ? 28 : 20, bottom: isTablet ? 14 : 10),
          child: Row(
            children: [
              Container(
                width: isTablet ? 44 : 36,
                height: isTablet ? 44 : 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                ),
                child: Icon(Icons.school_rounded, size: isTablet ? 24 : 20, color: const Color(0xFFFF6B35)),
              ),
              SizedBox(width: isTablet ? 14 : 10),
              Text(
                'How To',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 22 * scale : 18,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),

        // Tutorial Cards
        ...List.generate(_tutorials.length, (index) {
          final tutorial = _tutorials[index];
          return _buildCard(tutorial, isDark, isTablet, textColor, secondaryTextColor, scale, hPadding);
        }),
      ],
    );
  }

  Widget _buildCard(
    _TutorialItem tutorial,
    bool isDark,
    bool isTablet,
    Color textColor,
    Color secondaryTextColor,
    double scale,
    double hPadding,
  ) {
    final isVideo = tutorial.type == _TutorialType.video;
    final typeColor = isVideo ? const Color(0xFFE53935) : const Color(0xFF1E88E5);
    final typeBgColor = typeColor.withValues(alpha: 0.1);
    final cardBg = isDark ? AppColors.darkCardBackground : Colors.white;
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final hasThumbnail = tutorial.thumbnailUrl != null && tutorial.thumbnailUrl!.isNotEmpty;
    final isExternalLink = tutorial.mediaUrl == null && tutorial.url.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(left: isTablet ? hPadding : 15, right: isTablet ? hPadding : 15, bottom: isTablet ? 12 : 10),
      child: GestureDetector(
        onTap: () => _showDetailSheet(tutorial),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 18 * scale : 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 64 : 52,
                height: isTablet ? 64 : 52,
                decoration: BoxDecoration(
                  color: typeBgColor,
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                  image: hasThumbnail
                      ? DecorationImage(image: NetworkImage(tutorial.thumbnailUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: hasThumbnail ? null : Icon(isVideo ? Icons.play_circle_outline_rounded : Icons.picture_as_pdf_rounded, size: isTablet ? 30 : 26, color: typeColor),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial.title,
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: isTablet ? 16 * scale : 14, height: 1.3, color: textColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tutorial.description != null && tutorial.description!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        tutorial.description!,
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: isTablet ? 13 * scale : 12, height: 1.3, color: secondaryTextColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 8, vertical: 2),
                          decoration: BoxDecoration(color: typeBgColor, borderRadius: BorderRadius.circular(4)),
                          child: Text(isVideo ? 'VIDEO' : 'PDF', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: isTablet ? 11 * scale : 10, color: typeColor, letterSpacing: 0.5)),
                        ),
                        const SizedBox(width: 8),
                        Text('FREE', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: isTablet ? 11 * scale : 10, color: AppColors.success, letterSpacing: 0.5)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(isExternalLink ? Icons.open_in_new_rounded : Icons.arrow_forward_ios_rounded, size: isTablet ? 20 : 16, color: secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }
}
