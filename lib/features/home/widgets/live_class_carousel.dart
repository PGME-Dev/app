import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pgme/core/models/live_session_model.dart';
import 'package:pgme/core/models/banner_model.dart';
import 'package:pgme/features/home/widgets/live_class_banner.dart';
import 'package:pgme/features/home/widgets/promotional_banner.dart';

class LiveClassCarousel extends StatefulWidget {
  final List<LiveSessionModel> sessions;
  final List<BannerModel> banners;

  const LiveClassCarousel({
    super.key,
    required this.sessions,
    this.banners = const [],
  });

  @override
  State<LiveClassCarousel> createState() => _LiveClassCarouselState();
}

class _LiveClassCarouselState extends State<LiveClassCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  // Get total count of all items (sessions + banners)
  int get _totalItems => widget.sessions.length + widget.banners.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Start auto-slide if there are multiple items
    if (_totalItems > 1) {
      _startAutoSlide();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _totalItems;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Widget _buildCarouselItem(int index) {
    // Show sessions first, then banners
    if (index < widget.sessions.length) {
      return LiveClassBanner(session: widget.sessions[index]);
    } else {
      final bannerIndex = index - widget.sessions.length;
      return PromotionalBanner(banner: widget.banners[bannerIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no items at all, don't show anything
    if (_totalItems == 0) {
      return const SizedBox.shrink();
    }

    // Single item - no carousel needed
    if (_totalItems == 1) {
      return widget.sessions.isNotEmpty
          ? LiveClassBanner(session: widget.sessions.first)
          : PromotionalBanner(banner: widget.banners.first);
    }

    // Multiple items - show carousel
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _totalItems,
            itemBuilder: (context, index) => _buildCarouselItem(index),
          ),
        ),
        const SizedBox(height: 12),

        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _totalItems,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF2470E4)
                    : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
