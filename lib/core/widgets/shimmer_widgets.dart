import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

/// Shimmer loading widgets for various UI components
class ShimmerWidgets {
  /// Base shimmer wrapper
  static Widget shimmer({
    required Widget child,
    required bool isDark,
  }) {
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
      highlightColor: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
      child: child,
    );
  }

  /// Shimmer container
  static Widget container({
    required double width,
    required double height,
    double borderRadius = 8,
    required bool isDark,
  }) {
    return shimmer(
      isDark: isDark,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Card shimmer - for package/series cards
  static Widget cardShimmer({
    required bool isDark,
    double height = 140,
    EdgeInsets? margin,
    BuildContext? context,
  }) {
    final isTablet = context != null ? ResponsiveHelper.isTablet(context) : false;

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: shimmer(
        isDark: isDark,
        child: Container(
          height: isTablet && height == 140 ? 175 : height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
        ),
      ),
    );
  }

  /// List item shimmer
  static Widget listItemShimmer({
    required bool isDark,
    double height = 80,
    EdgeInsets? padding,
    BuildContext? context,
  }) {
    final isTablet = context != null ? ResponsiveHelper.isTablet(context) : false;

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 10 : 8,
      ),
      child: shimmer(
        isDark: isDark,
        child: Row(
          children: [
            // Icon/Image placeholder
            Container(
              width: isTablet ? 76 : 60,
              height: isTablet ? 76 : 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            // Text placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: isTablet ? 20 : 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 5 : 4),
                    ),
                  ),
                  SizedBox(height: isTablet ? 10 : 8),
                  Container(
                    width: isTablet ? 190 : 150,
                    height: isTablet ? 17 : 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 5 : 4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grid item shimmer
  static Widget gridItemShimmer({
    required bool isDark,
    double height = 200,
    BuildContext? context,
  }) {
    final isTablet = context != null ? ResponsiveHelper.isTablet(context) : false;

    return shimmer(
      isDark: isDark,
      child: Container(
        height: isTablet && height == 200 ? 240 : height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
      ),
    );
  }

  /// Profile shimmer
  static Widget profileShimmer({required bool isDark, BuildContext? context}) {
    final isTablet = context != null ? ResponsiveHelper.isTablet(context) : false;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Top profile card shimmer
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: shimmer(
              isDark: isDark,
              child: Row(
                children: [
                  // Profile picture
                  Container(
                    width: isTablet ? 100 : 80,
                    height: isTablet ? 100 : 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: isTablet ? 20 : 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: isTablet ? 22 : 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(isTablet ? 5 : 4),
                          ),
                        ),
                        SizedBox(height: isTablet ? 10 : 8),
                        Container(
                          width: isTablet ? 150 : 120,
                          height: isTablet ? 17 : 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(isTablet ? 5 : 4),
                          ),
                        ),
                        SizedBox(height: isTablet ? 10 : 8),
                        Container(
                          width: isTablet ? 125 : 100,
                          height: isTablet ? 34 : 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          // Package cards shimmer
          SizedBox(
            height: isTablet ? 140 : 115,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
              itemCount: 2,
              itemBuilder: (ctx, index) => Padding(
                padding: EdgeInsets.only(right: index == 1 ? 0 : (isTablet ? 16 : 12)),
                child: container(
                  width: isTablet ? 300 : 240,
                  height: isTablet ? 140 : 115,
                  borderRadius: isTablet ? 18 : 14,
                  isDark: isDark,
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          // Info cards shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
            child: container(
              width: double.infinity,
              height: isTablet ? 240 : 200,
              borderRadius: isTablet ? 16 : 12,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  /// Package grid shimmer
  static Widget packageGridShimmer({required bool isDark, BuildContext? context}) {
    final isTablet = context != null ? ResponsiveHelper.isTablet(context) : false;

    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          crossAxisSpacing: isTablet ? 16 : 12,
          mainAxisSpacing: isTablet ? 16 : 12,
          childAspectRatio: 0.75,
        ),
        itemCount: isTablet ? 6 : 4,
        itemBuilder: (ctx, index) => gridItemShimmer(isDark: isDark, context: context),
      ),
    );
  }

  /// Series list shimmer
  static Widget seriesListShimmer({required bool isDark, BuildContext? context}) {
    final isTablet = context != null ? ResponsiveHelper.isTablet(context) : false;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
      itemCount: 5,
      itemBuilder: (ctx, index) => cardShimmer(isDark: isDark, context: context),
    );
  }

  /// Live session card shimmer
  static Widget sessionCardShimmer({required bool isDark, BuildContext? context}) {
    final isTablet = context != null ? ResponsiveHelper.isTablet(context) : false;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: shimmer(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: double.infinity,
              height: isTablet ? 220 : 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            // Title
            Container(
              width: double.infinity,
              height: isTablet ? 22 : 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 5 : 4),
              ),
            ),
            SizedBox(height: isTablet ? 10 : 8),
            // Subtitle
            Container(
              width: isTablet ? 250 : 200,
              height: isTablet ? 17 : 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 5 : 4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Purchases tab shimmer
  static Widget purchasesTabShimmer({required bool isDark, BuildContext? context}) {
    final isTablet = context != null ? ResponsiveHelper.isTablet(context) : false;

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      itemCount: 5,
      itemBuilder: (ctx, index) => Padding(
        padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
        child: shimmer(
          isDark: isDark,
          child: Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: isTablet ? 56 : 44,
                      height: isTablet ? 56 : 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: isTablet ? 20 : 16,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: isTablet ? 8 : 6),
                          Container(
                            width: isTablet ? 125 : 100,
                            height: isTablet ? 15 : 12,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: isTablet ? 76 : 60,
                      height: isTablet ? 30 : 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Container(
                  width: isTablet ? 190 : 150,
                  height: isTablet ? 15 : 12,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Dashboard shimmer
  static Widget dashboardShimmer({required bool isDark, BuildContext? context}) {
    final isTablet = context != null ? ResponsiveHelper.isTablet(context) : false;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isTablet ? 20 : 16),
          // Live session card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
            child: container(
              width: double.infinity,
              height: isTablet ? 240 : 200,
              borderRadius: isTablet ? 20 : 16,
              isDark: isDark,
            ),
          ),
          SizedBox(height: isTablet ? 30 : 24),
          // Section title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
            child: container(
              width: isTablet ? 190 : 150,
              height: isTablet ? 24 : 20,
              borderRadius: isTablet ? 5 : 4,
              isDark: isDark,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          // Horizontal scrolling cards
          SizedBox(
            height: isTablet ? 175 : 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
              itemCount: 3,
              itemBuilder: (ctx, index) => Padding(
                padding: EdgeInsets.only(right: index == 2 ? 0 : (isTablet ? 16 : 12)),
                child: container(
                  width: isTablet ? 340 : 280,
                  height: isTablet ? 175 : 140,
                  borderRadius: isTablet ? 16 : 12,
                  isDark: isDark,
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 30 : 24),
          // Another section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
            child: container(
              width: isTablet ? 190 : 150,
              height: isTablet ? 24 : 20,
              borderRadius: isTablet ? 5 : 4,
              isDark: isDark,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          // List items
          ...List.generate(
            3,
            (index) => listItemShimmer(isDark: isDark, context: context),
          ),
        ],
      ),
    );
  }
}
