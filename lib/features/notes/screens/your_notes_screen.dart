import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/models/library_item_model.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

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
    final isTablet = ResponsiveHelper.isTablet(context);

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

    final hPadding = isTablet ? ResponsiveHelper.horizontalPadding(context) : 16.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxContentWidth(context)),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(top: topPadding + (isTablet ? 21 : 16), left: hPadding, right: hPadding),
            child: Row(
              children: [
                // Title
                Text(
                  'Your Notes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 25 : 20,
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
                    width: isTablet ? 30 : 24,
                    height: isTablet ? 30 : 24,
                    child: Icon(
                      Icons.refresh,
                      size: isTablet ? 30 : 24,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 21 : 16),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            child: Container(
              width: double.infinity,
              height: isTablet ? 56 : 48,
              decoration: BoxDecoration(
                color: searchBarColor,
                borderRadius: BorderRadius.circular(isTablet ? 23 : 18),
                border: Border.all(
                  color: searchBarBorderColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: isTablet ? 20 : 16),
                  Icon(
                    Icons.search,
                    size: isTablet ? 30 : 24,
                    color: secondaryTextColor,
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
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
                          fontSize: isTablet ? 15 : 12,
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
                        fontSize: isTablet ? 15 : 12,
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

          SizedBox(height: isTablet ? 21 : 16),

          // Filter Buttons
          Padding(
            padding: EdgeInsets.only(left: isTablet ? hPadding : 17),
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
                    height: isTablet ? 42 : 36,
                    decoration: BoxDecoration(
                      color: _showBookmarkedOnly ? badgeColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                      border: _showBookmarkedOnly ? null : Border.all(color: badgeColor),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 15 : 11, vertical: isTablet ? 10 : 8),
                    child: Text(
                      'Bookmarked',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: isTablet ? 15 : 12,
                        height: 20 / 12,
                        letterSpacing: -0.5,
                        color: _showBookmarkedOnly ? Colors.white : badgeColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 13 : 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showBookmarkedOnly = false;
                    });
                    _loadLibrary();
                  },
                  child: Container(
                    height: isTablet ? 42 : 36,
                    decoration: BoxDecoration(
                      color: !_showBookmarkedOnly ? badgeColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                      border: !_showBookmarkedOnly ? null : Border.all(color: badgeColor),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 15 : 11, vertical: isTablet ? 10 : 8),
                    child: Text(
                      'All Notes',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: isTablet ? 15 : 12,
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

          SizedBox(height: isTablet ? 23 : 18),

          // Order Physical Copies Banner
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? hPadding : 15),
            child: GestureDetector(
              onTap: () {
                context.push('/order-physical-books');
              },
              child: Container(
                width: double.infinity,
                height: isTablet ? 150 : 100,
                clipBehavior: Clip.none,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 14),
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
                    Positioned(
                      top: isTablet ? 24 : 13,
                      left: isTablet ? 24 : 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Opacity(
                            opacity: 0.9,
                            child: Text(
                              'Order Physical\nCopies',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 26 : 18,
                                height: isTablet ? 1.2 : 20 / 18,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (isTablet) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  'Get printed study materials',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Image
                    Positioned(
                      right: isTablet ? -80 : -130,
                      top: isTablet ? -120 : -120,
                      child: Transform.flip(
                        flipX: true,
                        child: Image.asset(
                          'assets/illustrations/4.png',
                          width: isTablet ? 400 : 350,
                          height: isTablet ? 400 : 350,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: isTablet ? 400 : 350,
                              height: isTablet ? 400 : 350,
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

          SizedBox(height: isTablet ? 21 : 16),

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
                            Icon(Icons.error_outline, size: isTablet ? 64 : 48, color: secondaryTextColor),
                            SizedBox(height: isTablet ? 21 : 16),
                            Text(
                              'Failed to load notes',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: isTablet ? 20 : 16,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: isTablet ? 10 : 8),
                            Text(
                              _error!.replaceAll('Exception: ', ''),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: isTablet ? 15 : 12,
                                color: secondaryTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isTablet ? 21 : 16),
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
                                  size: isTablet ? 80 : 64,
                                  color: secondaryTextColor,
                                ),
                                SizedBox(height: isTablet ? 21 : 16),
                                Text(
                                  _showBookmarkedOnly
                                      ? 'No bookmarked notes yet'
                                      : 'No notes in your library',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: isTablet ? 20 : 16,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                                SizedBox(height: isTablet ? 10 : 8),
                                Text(
                                  'Add documents to your library from series',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: isTablet ? 17 : 14,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadLibrary,
                            child: isTablet
                              ? GridView.builder(
                                  padding: EdgeInsets.only(
                                    left: hPadding,
                                    right: hPadding,
                                    bottom: 130,
                                  ),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.4,
                                  ),
                                  itemCount: _filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _filteredItems[index];
                                    return _buildBookCard(
                                      item: item,
                                      isDark: isDark,
                                      isTablet: isTablet,
                                      textColor: textColor,
                                      secondaryTextColor: secondaryTextColor,
                                      cardBgColor: cardBgColor,
                                      dividerColor: dividerColor,
                                      badgeColor: badgeColor,
                                      iconColor: iconColor,
                                      hPadding: 0,
                                    );
                                  },
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 100),
                                  itemCount: _filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _filteredItems[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildBookCard(
                                        item: item,
                                        isDark: isDark,
                                        isTablet: isTablet,
                                        textColor: textColor,
                                        secondaryTextColor: secondaryTextColor,
                                        cardBgColor: cardBgColor,
                                        dividerColor: dividerColor,
                                        badgeColor: badgeColor,
                                        iconColor: iconColor,
                                        hPadding: hPadding,
                                      ),
                                    );
                                  },
                                ),
                          ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildBookCard({
    required LibraryItemModel item,
    required bool isDark,
    required bool isTablet,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardBgColor,
    required Color dividerColor,
    required Color badgeColor,
    required Color iconColor,
    required double hPadding,
  }) {
    final inGrid = isTablet && hPadding == 0;
    final cardPad = isTablet ? 18.0 : 16.0;
    final titleSize = isTablet ? 17.0 : 16.0;
    final descSize = isTablet ? 13.0 : 12.0;
    final metaSize = isTablet ? 13.0 : 12.0;
    final metaIconSize = isTablet ? 16.0 : 16.0;
    final badgeHeight = isTablet ? 22.0 : 20.0;
    final badgeFontSize = isTablet ? 11.0 : 10.0;
    final bookmarkSize = isTablet ? 22.0 : 20.0;
    final cardRadius = isTablet ? 22.0 : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: inGrid ? 0 : (isTablet ? hPadding : 15)),
      child: GestureDetector(
        onTap: () {
          context.pushNamed(
            'pdf-viewer',
            queryParameters: {
              'documentId': item.documentId,
              'title': item.title,
            },
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(cardPad),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: inGrid ? MainAxisSize.max : MainAxisSize.min,
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
                        fontSize: titleSize,
                        height: 1.2,
                        color: textColor,
                      ),
                      maxLines: inGrid ? 2 : null,
                      overflow: inGrid ? TextOverflow.ellipsis : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badge
                  Container(
                    height: badgeHeight,
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 10),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(isTablet ? 6 : 5),
                    ),
                    child: Center(
                      child: Text(
                        item.fileExtension,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: badgeFontSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (item.isBookmarked) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.bookmark,
                      size: bookmarkSize,
                      color: iconColor,
                    ),
                  ],
                ],
              ),

              SizedBox(height: isTablet ? 8 : 8),

              // Description
              if (item.description != null && item.description!.isNotEmpty)
                Flexible(
                  flex: inGrid ? 1 : 0,
                  fit: inGrid ? FlexFit.tight : FlexFit.loose,
                  child: Text(
                    item.description!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: descSize,
                      height: 1.4,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                    maxLines: inGrid ? 2 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (item.description == null || item.description!.isEmpty)
                if (inGrid) const Spacer(),

              SizedBox(height: isTablet ? 10 : 12),

              // Divider
              Container(
                width: double.infinity,
                height: 1,
                color: dividerColor,
              ),

              SizedBox(height: isTablet ? 10 : 12),

              // Pages and Date Row
              Wrap(
                spacing: inGrid ? 12 : (isTablet ? 24 : 24),
                runSpacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: metaIconSize,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.pageCountText,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: metaSize,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: metaIconSize,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.formattedAddedDate,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: metaSize,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  if (item.fileSizeMb != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.storage_outlined,
                          size: metaIconSize,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.formattedFileSize,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: metaSize,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
