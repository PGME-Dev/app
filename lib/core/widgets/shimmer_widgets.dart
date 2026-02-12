import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      child: shimmer(
        isDark: isDark,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: shimmer(
        isDark: isDark,
        child: Row(
          children: [
            // Icon/Image placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // Text placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
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
  }) {
    return shimmer(
      isDark: isDark,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Profile shimmer
  static Widget profileShimmer({required bool isDark}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top profile card shimmer
          Container(
            padding: const EdgeInsets.all(20),
            child: shimmer(
              isDark: isDark,
              child: Row(
                children: [
                  // Profile picture
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Package cards shimmer
          SizedBox(
            height: 115,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 2,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(right: index == 1 ? 0 : 12),
                child: container(
                  width: 240,
                  height: 115,
                  borderRadius: 14,
                  isDark: isDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Info cards shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: container(
              width: double.infinity,
              height: 200,
              borderRadius: 12,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  /// Package grid shimmer
  static Widget packageGridShimmer({required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => gridItemShimmer(isDark: isDark),
      ),
    );
  }

  /// Series list shimmer
  static Widget seriesListShimmer({required bool isDark}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) => cardShimmer(isDark: isDark),
    );
  }

  /// Live session card shimmer
  static Widget sessionCardShimmer({required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: shimmer(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Container(
              width: double.infinity,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Purchases tab shimmer
  static Widget purchasesTabShimmer({required bool isDark}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: shimmer(
          isDark: isDark,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 100,
                            height: 12,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: 150,
                  height: 12,
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
  static Widget dashboardShimmer({required bool isDark}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Live session card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: container(
              width: double.infinity,
              height: 200,
              borderRadius: 16,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 24),
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: container(
              width: 150,
              height: 20,
              borderRadius: 4,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          // Horizontal scrolling cards
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(right: index == 2 ? 0 : 12),
                child: container(
                  width: 280,
                  height: 140,
                  borderRadius: 12,
                  isDark: isDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Another section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: container(
              width: 150,
              height: 20,
              borderRadius: 4,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          // List items
          ...List.generate(
            3,
            (index) => listItemShimmer(isDark: isDark),
          ),
        ],
      ),
    );
  }
}
