import 'package:flutter/material.dart';
import 'package:pgme/core/widgets/shimmer_skeleton.dart';

/// Skeleton loading widget for the dashboard
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton
          _buildHeaderSkeleton(topPadding),

          const SizedBox(height: 25),

          // Live Class Banner Skeleton
          _buildLiveClassSkeleton(),

          const SizedBox(height: 24),

          // Subject Badge Skeleton
          _buildSubjectBadgeSkeleton(),

          const SizedBox(height: 24),

          // For You Section Skeleton
          _buildForYouSkeleton(),

          const SizedBox(height: 24),

          // Faculty Section Skeleton
          _buildFacultySkeleton(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton(double topPadding) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding + 16, left: 23, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hello text and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerSkeleton(
                  width: 180,
                  height: 24,
                  borderRadius: 6,
                ),
                const SizedBox(height: 8),
                const ShimmerSkeleton(
                  width: 220,
                  height: 16,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
          // Get Help Button and Notification
          Row(
            children: [
              const ShimmerSkeleton(
                width: 103,
                height: 31,
                borderRadius: 30,
              ),
              const SizedBox(width: 12),
              const ShimmerSkeleton.circle(size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveClassSkeleton() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const ShimmerSkeleton(
            width: double.infinity,
            height: 140,
            borderRadius: 16,
          ),
        ),
        const SizedBox(height: 12),
        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ShimmerSkeleton(
                width: index == 0 ? 24 : 8,
                height: 8,
                borderRadius: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectBadgeSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const ShimmerSkeleton(
        width: 120,
        height: 36,
        borderRadius: 20,
      ),
    );
  }

  Widget _buildForYouSkeleton() {
    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ShimmerSkeleton(
                width: 80,
                height: 24,
                borderRadius: 6,
              ),
              const ShimmerSkeleton(
                width: 70,
                height: 16,
                borderRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Content Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              const gap = 9.0;
              final resumeCardWidth = (availableWidth - gap) * 0.49;
              final rightColumnWidth = (availableWidth - gap) * 0.51;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resume Card (Left - Tall)
                  ShimmerSkeleton(
                    width: resumeCardWidth,
                    height: 281,
                    borderRadius: 18,
                  ),
                  const SizedBox(width: gap),

                  // Right Column
                  SizedBox(
                    width: rightColumnWidth,
                    child: Column(
                      children: [
                        ShimmerSkeleton(
                          width: rightColumnWidth,
                          height: 136,
                          borderRadius: 18,
                        ),
                        const SizedBox(height: 9),
                        ShimmerSkeleton(
                          width: rightColumnWidth,
                          height: 136,
                          borderRadius: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFacultySkeleton() {
    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ShimmerSkeleton(
                width: 120,
                height: 24,
                borderRadius: 6,
              ),
              const ShimmerSkeleton(
                width: 70,
                height: 16,
                borderRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Faculty Cards - using Row instead of ListView
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    const ShimmerSkeleton(
                      width: 100,
                      height: 100,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 8),
                    const ShimmerSkeleton(
                      width: 80,
                      height: 14,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 4),
                    const ShimmerSkeleton(
                      width: 60,
                      height: 12,
                      borderRadius: 4,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
