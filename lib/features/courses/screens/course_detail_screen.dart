import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/models/series_model.dart';
import 'package:pgme/core/models/module_model.dart';
import 'package:pgme/core/models/series_document_model.dart';

class CourseDetailScreen extends StatefulWidget {
  final String seriesId;

  const CourseDetailScreen({
    super.key,
    required this.seriesId,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final DashboardService _dashboardService = DashboardService();

  SeriesModel? _series;
  List<ModuleModel> _modules = [];
  List<SeriesDocumentModel> _documents = [];

  bool _isLoading = true;
  String? _error;

  // Track which modules are expanded
  Set<String> _expandedModules = {};

  @override
  void initState() {
    super.initState();
    _loadSeriesData();
  }

  Future<void> _loadSeriesData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _dashboardService.getSeriesDetails(widget.seriesId),
        _dashboardService.getSeriesModules(widget.seriesId),
        _dashboardService.getSeriesDocuments(widget.seriesId),
      ]);

      if (mounted) {
        setState(() {
          _series = results[0] as SeriesModel;
          _modules = results[1] as List<ModuleModel>;
          _documents = results[2] as List<SeriesDocumentModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF718BA9);
    final cardColor = isDark ? AppColors.darkSurface : const Color(0xFFF5F9FF);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _series?.title ?? 'Anatomy Course',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: iconColor))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: secondaryTextColor),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load course',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSeriesData,
                        style: ElevatedButton.styleFrom(backgroundColor: iconColor),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Banner
                      _buildVideoBanner(iconColor),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Video Title - Show first video or series title
                            Text(
                              _getFirstVideoTitle() ?? _series?.title ?? 'Video Title',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Description
                            Text(
                              _series?.description ?? 'No description available',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                height: 1.5,
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Notes section
                            if (_documents.isNotEmpty) ...[
                              Text(
                                'Notes for this chapter',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._documents.map((doc) => _buildDocumentCard(
                                    doc,
                                    cardColor,
                                    textColor,
                                    secondaryTextColor,
                                    iconColor,
                                  )),
                              const SizedBox(height: 24),
                            ],

                            // Modules section
                            ..._modules.map((module) => _buildModuleCard(
                                  module,
                                  cardColor,
                                  textColor,
                                  secondaryTextColor,
                                  iconColor,
                                )),

                            // Enroll button
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle enroll action
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: iconColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Enroll Now',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Helper method to get first video title
  String? _getFirstVideoTitle() {
    if (_modules.isEmpty) return null;
    for (var module in _modules) {
      if (module.videos.isNotEmpty) {
        return module.videos.first.title;
      }
    }
    return null;
  }

  // Helper method to get first video
  ModuleVideoModel? _getFirstVideo() {
    if (_modules.isEmpty) return null;
    for (var module in _modules) {
      if (module.videos.isNotEmpty) {
        return module.videos.first;
      }
    }
    return null;
  }

  Widget _buildVideoBanner(Color iconColor) {
    final firstVideo = _getFirstVideo();

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor.withOpacity(0.3),
            iconColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Placeholder for video thumbnail
          const Center(
            child: Icon(
              Icons.play_circle_filled,
              size: 64,
              color: Colors.white,
            ),
          ),
          // Video info overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstVideo?.title ?? _series?.title ?? 'Video Title',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  firstVideo?.facultyName ?? 'Faculty',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    SeriesDocumentModel doc,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // PDF icon placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doc.description ?? '',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    ModuleModel module,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
  ) {
    final isExpanded = _expandedModules.contains(module.moduleId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Module header
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedModules.remove(module.moduleId);
                } else {
                  _expandedModules.add(module.moduleId);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Lock icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.lock, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${module.lessonCount} lessons  •  ${module.completedLessons}/${module.lessonCount} complete',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),

          // Module videos
          if (isExpanded) ...[
            const Divider(height: 1),
            ...module.videos.map((video) => _buildVideoItem(
                  video,
                  textColor,
                  secondaryTextColor,
                  iconColor,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoItem(
    ModuleVideoModel video,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
  ) {
    return InkWell(
      onTap: video.isLocked
          ? null
          : () {
              // Navigate to video player
              context.push('/video/${video.videoId}');
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Completion/Lock status icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: video.isCompleted
                    ? Colors.green.withOpacity(0.1)
                    : video.isLocked
                        ? secondaryTextColor.withOpacity(0.1)
                        : iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                video.isCompleted
                    ? Icons.check
                    : video.isLocked
                        ? Icons.lock
                        : Icons.play_arrow,
                color: video.isCompleted
                    ? Colors.green
                    : video.isLocked
                        ? secondaryTextColor
                        : iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: video.isLocked ? secondaryTextColor : textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: secondaryTextColor),
                      const SizedBox(width: 4),
                      Text(
                        video.formattedDuration,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.person, size: 12, color: secondaryTextColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          video.facultyName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
