import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pgme/core/theme/app_theme.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String videoId;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.black,
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 80,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Video Player Placeholder',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
