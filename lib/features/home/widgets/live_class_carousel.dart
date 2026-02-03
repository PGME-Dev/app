import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pgme/core/models/live_session_model.dart';
import 'package:pgme/features/home/widgets/live_class_banner.dart';

class LiveClassCarousel extends StatefulWidget {
  final List<LiveSessionModel> sessions;

  const LiveClassCarousel({
    super.key,
    required this.sessions,
  });

  @override
  State<LiveClassCarousel> createState() => _LiveClassCarouselState();
}

class _LiveClassCarouselState extends State<LiveClassCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Start auto-slide if there are multiple sessions
    if (widget.sessions.length > 1) {
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
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.sessions.length;
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

  @override
  Widget build(BuildContext context) {
    if (widget.sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.sessions.length == 1) {
      // Single session - no carousel needed
      return LiveClassBanner(session: widget.sessions.first);
    }

    // Multiple sessions - show carousel
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.sessions.length,
            itemBuilder: (context, index) {
              return LiveClassBanner(session: widget.sessions[index]);
            },
          ),
        ),
        const SizedBox(height: 12),

        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.sessions.length,
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
