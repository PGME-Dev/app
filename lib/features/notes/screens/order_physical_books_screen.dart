import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

class OrderPhysicalBooksScreen extends StatelessWidget {
  const OrderPhysicalBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF000000);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF666666);
    final cardBgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);
    final iconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF2470E4);
    final buttonColor = isDark ? const Color(0xFF1A1A4D) : const Color(0xFF000080);
    final cardFooterBgColor = isDark ? AppColors.darkCardBackground : const Color(0xFFE4F4FF);

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
                      context.pop();
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
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.3),
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
                            hintText: 'Search the book you want...',
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

            // Books Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 170 / 284,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return _buildBookCard(
                    isDark: isDark,
                    textColor: textColor,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    cardFooterBgColor: cardFooterBgColor,
                    buttonColor: buttonColor,
                  );
                },
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard({
    required bool isDark,
    required Color textColor,
    required Color cardBgColor,
    required Color borderColor,
    required Color cardFooterBgColor,
    required Color buttonColor,
  }) {
    final placeholderColor = isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0);

    return Container(
      width: 170,
      height: 284,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Upper part - with image placeholder
          Container(
            width: 170,
            height: 163,
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Center(
              child: Container(
                width: 71,
                height: 68,
                color: placeholderColor,
              ),
            ),
          ),
          // Lower part - with details
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardFooterBgColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Name
                  Text(
                    'Book Name',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.2,
                      color: textColor,
                    ),
                  ),
                  // Author Name
                  Text(
                    'Author Name',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      height: 1.2,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Text(
                    '₹4500',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.2,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  // Order Now Button
                  GestureDetector(
                    onTap: () {
                      // Order action
                    },
                    child: Container(
                      width: 149,
                      height: 27,
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: const Center(
                        child: Text(
                          'Order Now',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
