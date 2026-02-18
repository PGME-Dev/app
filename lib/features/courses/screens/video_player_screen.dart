import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/services/download_service.dart';
import 'package:pgme/core/services/offline_storage_service.dart';
import 'package:pgme/features/courses/providers/download_provider.dart';
import 'package:pgme/features/courses/providers/enrolled_courses_provider.dart';
import 'package:pgme/core/models/progress_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final DashboardService _dashboardService = DashboardService();

  BetterPlayerController? _playerController;
  Timer? _progressTimer;
  Timer? _fullscreenCheckTimer;

  // Video metadata from API
  String? _videoUrl;
  String? _videoTitle;
  int _videoDurationSeconds = 0;

  // Progress tracking
  int _watchTimeSeconds = 0;
  int _lastSavedPositionSeconds = 0;
  DateTime? _playStartTime;
  bool _isProgressSaving = false;

  // UI state
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;
  bool _isPlayerInitialized = false;
  bool _isLocalFile = false;

  // Existing progress for resume
  ProgressModel? _existingProgress;

  // Fullscreen overlay
  OverlayEntry? _fullscreenBackButtonOverlay;
  bool _isFullscreen = false;
  bool _controlsVisible = true;
  Timer? _controlsHideTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('VideoPlayer: init for videoId=${widget.videoId}');
    _loadVideoData();
  }

  @override
  void dispose() {
    debugPrint('VideoPlayer: disposing');
    _isDisposed = true;
    _saveProgressOnExit();
    _progressTimer?.cancel();
    _progressTimer = null;
    _fullscreenCheckTimer?.cancel();
    _fullscreenCheckTimer = null;
    _controlsHideTimer?.cancel();
    _controlsHideTimer = null;
    _removeFullscreenOverlay();
    _playerController?.removeEventsListener(_onPlayerEvent);
    // Pause first to stop audio immediately, then dispose
    _playerController?.pause();
    _playerController?.dispose();
    _playerController = null;
    // Restore orientation - allow landscape on tablets, portrait-only on phones
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logicalShortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
    final isTablet = logicalShortestSide >= 600;
    SystemChrome.setPreferredOrientations(isTablet
        ? [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data Loading
  // ---------------------------------------------------------------------------

  Future<void> _loadVideoData() async {
    debugPrint('VideoPlayer: loading video data');
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load existing progress for resume position
      _loadExistingProgress();

      // Check for locally downloaded video first, but NOT if it's still downloading
      final isCurrentlyDownloading = Provider.of<DownloadProvider>(context, listen: false)
          .isDownloading(widget.videoId);
      if (!isCurrentlyDownloading) {
        final downloadedPath = await DownloadService().getDownloadedPath('video_${widget.videoId}.mp4');
        if (downloadedPath != null) {
          // Load persisted metadata for proper title/duration display
          final offlineVideo = await OfflineStorageService().getOfflineVideo(widget.videoId);
          if (offlineVideo != null) {
            debugPrint('VideoPlayer: using local file at $downloadedPath');
            _videoUrl = downloadedPath;
            _isLocalFile = true;
            _videoTitle = offlineVideo.title;
            _videoDurationSeconds = offlineVideo.durationSeconds;
            _initializePlayer();
            return;
          }
          // File exists but no metadata = orphaned partial file, ignore it
          debugPrint('VideoPlayer: local file found but no metadata, streaming instead');
        }
      } else {
        debugPrint('VideoPlayer: download in progress, streaming instead');
      }

      final videoData =
          await _dashboardService.getVideoPlaybackData(widget.videoId);

      if (_isDisposed || !mounted) return;

      final videoUrl = videoData['video_url'] as String?;
      if (videoUrl == null || videoUrl.isEmpty) {
        final status = videoData['status'] as String?;
        debugPrint('VideoPlayer: no video_url in response, status=$status');
        setState(() {
          _error = status == 'processing'
              ? 'This video is still being processed. Please try again in a few minutes.'
              : 'Video URL not available';
          _isLoading = false;
        });
        return;
      }

      _videoUrl = videoUrl;
      _videoTitle = videoData['title'] as String? ?? 'Untitled';
      _videoDurationSeconds = (videoData['duration_seconds'] as num?)?.toInt() ?? 0;

      debugPrint(
          'VideoPlayer: data loaded - title=$_videoTitle, duration=${_videoDurationSeconds}s');

      _initializePlayer();
    } catch (e) {
      debugPrint('VideoPlayer: load error - $e');
      if (_isDisposed || !mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _loadExistingProgress() {
    try {
      final provider =
          Provider.of<EnrolledCoursesProvider>(context, listen: false);
      _existingProgress = provider.getProgressForLecture(widget.videoId);
      if (_existingProgress != null) {
        _watchTimeSeconds = _existingProgress!.watchTimeSeconds;
        debugPrint(
            'VideoPlayer: resume pos=${_existingProgress!.lastWatchedPositionSeconds}s, watch=${_watchTimeSeconds}s');
      } else {
        debugPrint('VideoPlayer: no existing progress');
      }
    } catch (e) {
      // Provider may not be registered; proceed without resume
      debugPrint('VideoPlayer: could not load progress - $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Player Initialization
  // ---------------------------------------------------------------------------

  void _initializePlayer() {
    if (_videoUrl == null || _isDisposed) return;

    int resumePositionSeconds = 0;
    if (_existingProgress != null) {
      resumePositionSeconds = _existingProgress!.lastWatchedPositionSeconds;

      // Guard: resume position exceeds duration -> start from beginning
      if (_videoDurationSeconds > 0 &&
          resumePositionSeconds >= _videoDurationSeconds) {
        debugPrint(
            'VideoPlayer: resume pos ($resumePositionSeconds) >= duration ($_videoDurationSeconds), resetting');
        resumePositionSeconds = 0;
      }

      // Already completed -> start from beginning
      if (_existingProgress!.isCompleted) {
        debugPrint('VideoPlayer: already completed, starting from 0');
        resumePositionSeconds = 0;
      }
    }

    debugPrint('VideoPlayer: initializing, resume at ${resumePositionSeconds}s');

    final BetterPlayerDataSource dataSource;
    if (_isLocalFile) {
      dataSource = BetterPlayerDataSource.file(_videoUrl!);
    } else {
      dataSource = BetterPlayerDataSource.network(
        _videoUrl!,
        videoFormat: BetterPlayerVideoFormat.hls,
        useAsmsTracks: true,
        useAsmsSubtitles: true,
        useAsmsAudioTracks: true,
      );
    }

    _playerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fit: BoxFit.contain,
        fullScreenByDefault: false,
        allowedScreenSleep: false,
        handleLifecycle: true,
        autoDispose: false,
        startAt: resumePositionSeconds > 0
            ? Duration(seconds: resumePositionSeconds)
            : null,
        deviceOrientationsOnFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableProgressBar: true,
          enablePlayPause: true,
          enableFullscreen: true,
          enableSkips: true,
          enablePlaybackSpeed: true,
          enableQualities: true,
          enableMute: true,
          enableProgressText: true,
          enableOverflowMenu: true,
          enableRetry: true,
          forwardSkipTimeInMilliseconds: 10000,
          backwardSkipTimeInMilliseconds: 10000,
          loadingColor: Colors.white,
          progressBarPlayedColor: Colors.white,
          progressBarHandleColor: Colors.white,
          progressBarBufferedColor: Colors.white70,
          progressBarBackgroundColor: Colors.white24,
        ),
        errorBuilder: (context, errorMessage) {
          return _buildPlayerError(errorMessage);
        },
      ),
      betterPlayerDataSource: dataSource,
    );

    _playerController!.addEventsListener(_onPlayerEvent);

    if (!_isDisposed && mounted) {
      setState(() {
        _isLoading = false;
        _isPlayerInitialized = true;
      });
    }

    _startProgressTimer();
    _startFullscreenMonitoring();
  }

  // ---------------------------------------------------------------------------
  // Player Events
  // ---------------------------------------------------------------------------

  void _onPlayerEvent(BetterPlayerEvent event) {
    if (_isDisposed) return;

    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        debugPrint('VideoPlayer: player initialized');
        final duration =
            _playerController?.videoPlayerController?.value.duration;
        if (duration != null && _videoDurationSeconds == 0) {
          _videoDurationSeconds = duration.inSeconds;
          debugPrint(
              'VideoPlayer: duration from player - ${_videoDurationSeconds}s');
        }
        break;

      case BetterPlayerEventType.play:
        // Accumulate any existing watch time before resetting the start marker.
        // Prevents losing tracked time if multiple play events fire consecutively
        // (e.g., during seeks or buffering).
        _accumulateWatchTime();
        _playStartTime = DateTime.now();
        break;

      case BetterPlayerEventType.pause:
        debugPrint('VideoPlayer: paused');
        _accumulateWatchTime();
        _saveProgress();
        break;

      case BetterPlayerEventType.finished:
        debugPrint('VideoPlayer: finished');
        _accumulateWatchTime();
        _saveProgress(forceComplete: true);
        break;

      case BetterPlayerEventType.exception:
        final errorMsg = event.parameters?['exception'];
        debugPrint('VideoPlayer: exception - $errorMsg');
        break;

      default:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Progress Tracking
  // ---------------------------------------------------------------------------

  void _accumulateWatchTime() {
    if (_playStartTime != null) {
      final now = DateTime.now();
      // Clamp to non-negative to guard against device clock changes
      final elapsed = now.difference(_playStartTime!).inSeconds.clamp(0, 86400);
      _watchTimeSeconds += elapsed;
      _playStartTime = now;
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_isDisposed) return;
      _accumulateWatchTime();
      _saveProgress();
    });
    debugPrint('VideoPlayer: progress timer started (15s)');
  }

  Future<void> _saveProgress({bool forceComplete = false}) async {
    if (_isDisposed || _isProgressSaving) return;
    if (_playerController?.videoPlayerController == null) return;

    final value = _playerController!.videoPlayerController!.value;
    final positionSeconds = value.position.inSeconds;

    // Skip if position hasn't changed since last save
    if (!forceComplete && positionSeconds == _lastSavedPositionSeconds) return;

    _isProgressSaving = true;

    try {
      final duration = _videoDurationSeconds > 0
          ? _videoDurationSeconds
          : (value.duration?.inSeconds ?? 0);

      if (duration <= 0) {
        debugPrint('VideoPlayer: skip save, duration unknown');
        _isProgressSaving = false;
        return;
      }

      final completionPercentage =
          ((positionSeconds / duration) * 100).round().clamp(0, 100);
      final isCompleted = forceComplete || completionPercentage >= 90;

      debugPrint(
          'VideoPlayer: saving pos=${positionSeconds}s, watch=${_watchTimeSeconds}s, $completionPercentage%, done=$isCompleted');

      final provider =
          Provider.of<EnrolledCoursesProvider>(context, listen: false);
      await provider.updateLectureProgress(
        lectureId: widget.videoId,
        lastWatchedPositionSeconds: positionSeconds,
        watchTimeSeconds: _watchTimeSeconds,
        isCompleted: isCompleted,
        completionPercentage: completionPercentage,
      );

      _lastSavedPositionSeconds = positionSeconds;
    } catch (e) {
      // Silent fail - don't interrupt playback
      debugPrint('VideoPlayer: save failed - $e');
    } finally {
      _isProgressSaving = false;
    }
  }

  void _saveProgressOnExit() {
    if (_playerController?.videoPlayerController == null) return;

    _accumulateWatchTime();

    final value = _playerController!.videoPlayerController!.value;
    final positionSeconds = value.position.inSeconds;

    if (positionSeconds == _lastSavedPositionSeconds) return;

    final duration = _videoDurationSeconds > 0
        ? _videoDurationSeconds
        : (value.duration?.inSeconds ?? 0);

    if (duration <= 0) return;

    final completionPercentage =
        ((positionSeconds / duration) * 100).round().clamp(0, 100);
    final isCompleted = completionPercentage >= 90;

    debugPrint(
        'VideoPlayer: exit save pos=${positionSeconds}s, watch=${_watchTimeSeconds}s');

    try {
      final provider =
          Provider.of<EnrolledCoursesProvider>(context, listen: false);
      // Fire-and-forget on dispose
      provider.updateLectureProgress(
        lectureId: widget.videoId,
        lastWatchedPositionSeconds: positionSeconds,
        watchTimeSeconds: _watchTimeSeconds,
        isCompleted: isCompleted,
        completionPercentage: completionPercentage,
      );
    } catch (e) {
      debugPrint('VideoPlayer: exit save failed - $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _stopAndGoBack() {
    _playerController?.pause();
    if (mounted) {
      context.pop();
    }
  }

  // ---------------------------------------------------------------------------
  // Fullscreen Overlay Management
  // ---------------------------------------------------------------------------

  void _startFullscreenMonitoring() {
    _fullscreenCheckTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (_isDisposed || !mounted) {
        timer.cancel();
        return;
      }

      final isFullscreen = _playerController?.isFullScreen ?? false;
      if (isFullscreen != _isFullscreen) {
        _isFullscreen = isFullscreen;
        if (isFullscreen) {
          _showFullscreenOverlay();
        } else {
          _removeFullscreenOverlay();
        }
      }
    });
  }

  void _showFullscreenOverlay() {
    if (_fullscreenBackButtonOverlay != null) return;

    _fullscreenBackButtonOverlay = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Start auto-hide timer initially
          _startControlsHideTimer(() {
            if (mounted && _fullscreenBackButtonOverlay != null) {
              setState(() {
                _controlsVisible = false;
              });
            }
          });

          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              // Show controls on tap
              setState(() {
                _controlsVisible = true;
              });
              // Restart hide timer
              _startControlsHideTimer(() {
                if (mounted && _fullscreenBackButtonOverlay != null) {
                  setState(() {
                    _controlsVisible = false;
                  });
                }
              });
            },
            child: Stack(
              children: [
                // Back button - synced with control visibility
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: AnimatedOpacity(
                      opacity: _controlsVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !_controlsVisible,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _playerController?.exitFullScreen();
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    Overlay.of(context).insert(_fullscreenBackButtonOverlay!);
  }

  void _startControlsHideTimer(VoidCallback onHide) {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(const Duration(seconds: 3), onHide);
  }

  void _removeFullscreenOverlay() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = null;
    _fullscreenBackButtonOverlay?.remove();
    _fullscreenBackButtonOverlay = null;
    _controlsVisible = true; // Reset for next session
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        // Check if player is in fullscreen mode
        final isFullscreen = _playerController?.isFullScreen ?? false;
        if (isFullscreen) {
          // Exit fullscreen first, don't close the screen
          _playerController?.exitFullScreen();
          return;
        }

        // Pause and navigate back
        _playerController?.pause();
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildPlayerArea(),
              if (!_isLoading && _error == null) _buildVideoInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerArea() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_playerController != null && _isPlayerInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer(controller: _playerController!),
      );
    }

    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                    Icons.error_outline, color: Colors.white54, size: 48),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'Failed to load video',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _stopAndGoBack,
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white70, size: 18),
                      label: const Text('Go Back',
                          style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _loadVideoData,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerError(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
                Icons.error_outline, color: Colors.white54, size: 40),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Playback error',
              style:
                  const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Expanded(
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _stopAndGoBack,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.arrow_back,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _videoTitle ?? 'Video',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (_videoDurationSeconds > 0) ...[
                const SizedBox(height: 8),
                Text(
                  _formatDuration(_videoDurationSeconds),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? "$minutes min" : ""}';
    }
    if (minutes > 0) {
      return '$minutes min ${seconds > 0 ? "$seconds sec" : ""}';
    }
    return '$seconds sec';
  }
}
