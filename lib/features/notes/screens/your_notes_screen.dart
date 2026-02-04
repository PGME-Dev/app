import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/models/library_item_model.dart';
import 'package:pgme/core/services/dashboard_service.dart';

class YourNotesScreen extends StatefulWidget {
  const YourNotesScreen({super.key});

  @override
  State<YourNotesScreen> createState() => _YourNotesScreenState();
}

class _YourNotesScreenState extends State<YourNotesScreen> {
  final DashboardService _dashboardService = DashboardService();
  List<LibraryItemModel> _libraryItems = [];
  bool _isLoading = true;
  String? _error;
  bool _showBookmarkedOnly = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLibrary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _dashboardService.getUserLibrary(
        isBookmarked: _showBookmarkedOnly ? true : null,
      );

      if (mounted) {
        setState(() {
          _libraryItems = items;
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

  List<LibraryItemModel> get _filteredItems {
    if (_searchQuery.isEmpty) return _libraryItems;
    return _libraryItems.where((item) {
      final titleMatch = item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final descMatch = item.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      return titleMatch || descMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final cardBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFE4F4FF);
    final searchBarColor = isDark ? AppColors.darkSurface : Colors.white;
    final searchBarBorderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final dividerColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final badgeColor = isDark ? const Color(0xFF1A1A4D) : const Color(0xFF000080);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(top: topPadding + 16, left: 16, right: 16),
            child: Row(
              children: [
                // Back Arrow
                GestureDetector(
                  onTap: () {
                    context.go('/home?subscribed=true');
                  },
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: textColor,
                    ),
                  ),
                ),
                const Spacer(),
                // Title
                Text(
                  'Your Notes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    height: 1.0,
                    letterSpacing: -0.5,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                // Refresh button
                GestureDetector(
                  onTap: _loadLibrary,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.refresh,
                      size: 24,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: searchBarColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: searchBarBorderColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search,
                    size: 24,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search through your medical notes...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 20 / 12,
                          letterSpacing: -0.5,
                          color: textColor.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filter Buttons
          Padding(
            padding: const EdgeInsets.only(left: 17),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showBookmarkedOnly = true;
                    });
                    _loadLibrary();
                  },
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: _showBookmarkedOnly ? badgeColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: _showBookmarkedOnly ? null : Border.all(color: badgeColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    child: Text(
                      'Bookmarked',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 20 / 12,
                        letterSpacing: -0.5,
                        color: _showBookmarkedOnly ? Colors.white : badgeColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showBookmarkedOnly = false;
                    });
                    _loadLibrary();
                  },
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: !_showBookmarkedOnly ? badgeColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: !_showBookmarkedOnly ? null : Border.all(color: badgeColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    child: Text(
                      'All Notes',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 20 / 12,
                        letterSpacing: -0.5,
                        color: !_showBookmarkedOnly ? Colors.white : badgeColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Order Physical Copies Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GestureDetector(
              onTap: () {
                context.push('/order-physical-books');
              },
              child: Container(
                width: double.infinity,
                height: 100,
                clipBehavior: Clip.none,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: isDark
                        ? [const Color(0xFF0D2A5C), const Color(0xFF1A3A5C)]
                        : [const Color(0xFF0047CF), const Color(0xFFE4F4FF)],
                    stops: const [0.3654, 1.0],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Text
                    const Positioned(
                      top: 13,
                      left: 12,
                      child: Opacity(
                        opacity: 0.9,
                        child: SizedBox(
                          width: 139,
                          child: Text(
                            'Order Physical\nCopies',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              height: 20 / 18,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Image
                    Positioned(
                      right: -130,
                      top: -120,
                      child: Transform.flip(
                        flipX: true,
                        child: Image.asset(
                          'assets/illustrations/4.png',
                          width: 350,
                          height: 350,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 350,
                              height: 350,
                              color: Colors.transparent,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: iconColor),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: secondaryTextColor),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load notes',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!.replaceAll('Exception: ', ''),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadLibrary,
                              style: ElevatedButton.styleFrom(backgroundColor: iconColor),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book_outlined,
                                  size: 64,
                                  color: secondaryTextColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _showBookmarkedOnly
                                      ? 'No bookmarked notes yet'
                                      : 'No notes in your library',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add documents to your library from series',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadLibrary,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildBookCard(
                                    item: item,
                                    isDark: isDark,
                                    textColor: textColor,
                                    secondaryTextColor: secondaryTextColor,
                                    cardBgColor: cardBgColor,
                                    dividerColor: dividerColor,
                                    badgeColor: badgeColor,
                                    iconColor: iconColor,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard({
    required LibraryItemModel item,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardBgColor,
    required Color dividerColor,
    required Color badgeColor,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: () {
          // Navigate to document viewer or handle document opening
          if (item.fileUrl != null) {
            // TODO: Navigate to PDF viewer
            debugPrint('Opening document: ${item.fileUrl}');
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row with Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.2,
                        color: textColor,
                      ),
                    ),
                  ),
                  // Badge
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        item.fileExtension,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (item.isBookmarked) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.bookmark,
                      size: 20,
                      color: iconColor,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // Description
              if (item.description != null && item.description!.isNotEmpty)
                Text(
                  item.description!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.4,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Divider
              Container(
                width: double.infinity,
                height: 1,
                color: dividerColor,
              ),

              const SizedBox(height: 12),

              // Pages and Date Row
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 16,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.pageCountText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.formattedAddedDate,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                  if (item.fileSizeMb != null) ...[
                    const SizedBox(width: 24),
                    Icon(
                      Icons.storage_outlined,
                      size: 16,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.formattedFileSize,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
