import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/models/series_model.dart';
import 'package:pgme/core/services/series_service.dart';

class EnrolledCourseDetailScreen extends StatefulWidget {
  final String seriesId;

  const EnrolledCourseDetailScreen({
    super.key,
    required this.seriesId,
  });

  @override
  State<EnrolledCourseDetailScreen> createState() =>
      _EnrolledCourseDetailScreenState();
}

class _EnrolledCourseDetailScreenState
    extends State<EnrolledCourseDetailScreen> {
  SeriesModel? _series;
  bool _isLoading = true;
  String? _error;

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
      // TODO: Implement API call to get series details
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
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
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF718BA9);
    final cardGradientStart =
        isDark ? const Color(0xFF1A3A5C) : const Color(0xFFCDE5FF);
    final cardGradientEnd =
        isDark ? const Color(0xFF2D5A9E) : const Color(0xFF8FC6FF);

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
          'My Enrolled Courses',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: textColor),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load course',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSeriesData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Access Cards
                        Row(
                          children: [
                            // Watch Demo Video Card
                            Expanded(
                              child: _buildQuickAccessCard(
                                context,
                                'Watch Demo\nVideo',
                                'Check Out',
                                'assets/illustrations/1.png',
                                isDark,
                                cardGradientStart,
                                cardGradientEnd,
                                onTap: () {
                                  // Navigate to demo video
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Free PDF Card
                            Expanded(
                              child: _buildQuickAccessCard(
                                context,
                                'Free PDF',
                                '',
                                'assets/illustrations/2.png',
                                isDark,
                                cardGradientStart,
                                cardGradientEnd,
                                showButton: false,
                                onTap: () {
                                  // Navigate to PDF viewer
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Subject Title
                        Text(
                          'Subject Title',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description
                        Text(
                          'aliqua dolor proident exercitation cillum exercitation laboris voluptate ea reprehenderit eu consequat pariatur qui eu aliqua dolor proident exercitation cillum exercitation laboris voluptate ea reprehenderit eu consequat pariatur qui eu',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 1.5,
                            color: secondaryTextColor,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Inclusions Section
                        Text(
                          'Inclusions',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Inclusion Items
                        _buildInclusionItem(
                          'Ensure your Student ID is visible in your profile name.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildInclusionItem(
                          'Mute your microphone upon entry to avoid echo in the OR.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildInclusionItem(
                          'Q&A session will follow the primary procedure.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildInclusionItem(
                          'Recording will be available 24 hours after the session',
                          secondaryTextColor,
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    String buttonText,
    String imagePath,
    bool isDark,
    Color gradientStart,
    Color gradientEnd, {
    bool showButton = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: const Alignment(-0.5, -0.5),
            end: const Alignment(0.5, 0.5),
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: Stack(
          children: [
            // Title
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF000000),
                  height: 1.3,
                ),
              ),
            ),

            // Button
            if (showButton)
              Positioned(
                top: 60,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF00BEFA)
                          : const Color(0xFF2470E4),
                    ),
                  ),
                ),
              ),

            // Illustration
            Positioned(
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(12),
                ),
                child: Image.asset(
                  imagePath,
                  width: title.contains('PDF') ? 123 : 101,
                  height: title.contains('PDF') ? 85 : 78,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: title.contains('PDF') ? 123 : 101,
                      height: title.contains('PDF') ? 85 : 78,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCardBackground
                            : const Color(0xFFDCEAF7),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Icon(
                        title.contains('PDF')
                            ? Icons.picture_as_pdf
                            : Icons.play_circle_outline,
                        size: 40,
                        color: isDark
                            ? const Color(0xFF00BEFA)
                            : const Color(0xFF2470E4),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInclusionItem(String text, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(
            Icons.link,
            size: 20,
            color: textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.5,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
