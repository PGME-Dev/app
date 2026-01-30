import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class YourNotesScreen extends StatelessWidget {
  const YourNotesScreen({super.key});

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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
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
                  // Three dots menu
                  GestureDetector(
                    onTap: () {
                      // Menu options
                    },
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.more_horiz,
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
                      child: Opacity(
                        opacity: 0.4,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search through your medical notes...',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 20 / 12,
                              letterSpacing: -0.5,
                              color: textColor,
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
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bookmarked Button
            Padding(
              padding: const EdgeInsets.only(left: 17),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                child: const Text(
                  'Bookmarked',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 20 / 12,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
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
                width: 362,
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

            // Book Cards
            _buildBookCard(
              title: 'Book Name',
              description: 'dolore non sit quis laboris deserunt non duis occaecat anim aute occaecat minim sit esse do exercitation velit',
              pages: '8 Pages',
              date: '21 Jan 2026',
              badge: 'PDF',
              isDark: isDark,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
              cardBgColor: cardBgColor,
              dividerColor: dividerColor,
              badgeColor: badgeColor,
            ),

            const SizedBox(height: 12),

            _buildBookCard(
              title: 'Book Name',
              description: 'dolore non sit quis laboris deserunt non duis occaecat anim aute occaecat minim sit esse do exercitation velit',
              pages: '8 Pages',
              date: '21 Jan 2026',
              badge: 'EPUB',
              isDark: isDark,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
              cardBgColor: cardBgColor,
              dividerColor: dividerColor,
              badgeColor: badgeColor,
            ),

            const SizedBox(height: 12),

            _buildBookCard(
              title: 'Book Name',
              description: 'dolore non sit quis laboris deserunt non duis occaecat anim aute occaecat minim sit esse do exercitation velit',
              pages: '8 Pages',
              date: '21 Jan 2026',
              badge: 'EPUB',
              isDark: isDark,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
              cardBgColor: cardBgColor,
              dividerColor: dividerColor,
              badgeColor: badgeColor,
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard({
    required String title,
    required String description,
    required String pages,
    required String date,
    required String badge,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardBgColor,
    required Color dividerColor,
    required Color badgeColor,
  }) {
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: 362,
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
                    title,
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
                      badge,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              description,
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
                  pages,
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
                  date,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
