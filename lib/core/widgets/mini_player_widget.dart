import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/mini_player_provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';

/// A floating mini video player bar positioned at the bottom of the screen.
///
/// IMPORTANT: This widget must be wrapped in a [Positioned] by the parent
/// [Stack]. Never return [Positioned] from inside a [Consumer] — Flutter's
/// render tree won't apply the parent data correctly.
///
/// Usage inside a Stack:
/// ```dart
/// Positioned(
///   left: 0, right: 0,
///   bottom: bottomPadding + 90,
///   child: const MiniPlayerWidget(),
/// )
/// ```
class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer is INSIDE Positioned (set by the parent), never the reverse.
    return Consumer<MiniPlayerProvider>(
      builder: (context, provider, _) {
        if (!provider.isMinimized || provider.controller == null) {
          return const SizedBox.shrink();
        }

        final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

        return _MiniPlayerBar(
          provider: provider,
          isDark: isDark,
        );
      },
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  final MiniPlayerProvider provider;
  final bool isDark;

  const _MiniPlayerBar({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const ValueKey('mini-player'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => provider.close(),
      child: GestureDetector(
        onTap: () {
          context.push('/video/${provider.videoId}');
        },
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Thumbnail area — static icon (audio keeps playing from
              // the controller; only one BetterPlayer widget may exist
              // at a time to avoid platform view conflicts).
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                ),
                child: const Icon(
                  Icons.ondemand_video_rounded,
                  color: Colors.white38,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.videoTitle ?? 'Video',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tap to expand',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Play/Pause
              _PlayPauseButton(controller: provider.controller!),
              // Close
              IconButton(
                onPressed: () => provider.close(),
                icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                tooltip: 'Close player',
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stateful play/pause toggle that listens to the BetterPlayer events.
class _PlayPauseButton extends StatefulWidget {
  final BetterPlayerController controller;
  const _PlayPauseButton({required this.controller});

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addEventsListener(_onEvent);
    _isPlaying = widget.controller.isPlaying() ?? false;
  }

  @override
  void dispose() {
    try {
      widget.controller.removeEventsListener(_onEvent);
    } catch (_) {}
    super.dispose();
  }

  void _onEvent(BetterPlayerEvent event) {
    if (!mounted) return;
    if (event.betterPlayerEventType == BetterPlayerEventType.play) {
      setState(() => _isPlaying = true);
    } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (_isPlaying) {
          widget.controller.pause();
        } else {
          widget.controller.play();
        }
      },
      icon: Icon(
        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        color: Colors.white,
        size: 28,
      ),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
      tooltip: _isPlaying ? 'Pause' : 'Play',
    );
  }
}
