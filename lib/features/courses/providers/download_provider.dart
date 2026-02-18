import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/models/offline_video_model.dart';
import 'package:pgme/core/services/download_service.dart';
import 'package:pgme/core/services/download_notification_service.dart';
import 'package:pgme/core/services/offline_storage_service.dart';

/// Holds metadata needed to start/retry a download
class _DownloadParams {
  final String videoId;
  final String title;
  final String? thumbnailUrl;
  final String facultyName;
  final int durationSeconds;
  final String? moduleName;
  final String? seriesName;

  _DownloadParams({
    required this.videoId,
    required this.title,
    this.thumbnailUrl,
    this.facultyName = '',
    this.durationSeconds = 0,
    this.moduleName,
    this.seriesName,
  });
}

class DownloadProvider with ChangeNotifier {
  final DownloadService _downloadService = DownloadService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final DownloadNotificationService _notificationService =
      DownloadNotificationService();

  // State
  List<OfflineVideoModel> _downloadedVideos = [];
  final Map<String, double> _activeDownloads = {}; // videoId -> progress 0.0..1.0
  final Map<String, String> _failedDownloads = {}; // videoId -> error message
  final Map<String, _DownloadParams> _downloadParams = {}; // for retry
  final Map<String, CancelToken> _cancelTokens = {}; // for cancellation
  double _totalStorageUsedMb = 0;
  bool _isLoaded = false;
  bool _isInitializing = false;

  // Getters
  List<OfflineVideoModel> get downloadedVideos => _downloadedVideos;
  Map<String, double> get activeDownloads => Map.unmodifiable(_activeDownloads);
  Map<String, String> get failedDownloads => Map.unmodifiable(_failedDownloads);
  double get totalStorageUsedMb => _totalStorageUsedMb;
  bool get isLoaded => _isLoaded;
  int get downloadedCount => _downloadedVideos.length;
  bool get hasActiveDownloads => _activeDownloads.isNotEmpty;

  String get formattedTotalStorage {
    if (_totalStorageUsedMb >= 1024) {
      return '${(_totalStorageUsedMb / 1024).toStringAsFixed(1)} GB';
    }
    return '${_totalStorageUsedMb.toStringAsFixed(1)} MB';
  }

  /// Initialize: load persisted metadata and verify files still exist
  Future<void> loadDownloads() async {
    if (_isLoaded || _isInitializing) return;
    _isInitializing = true;

    try {
      debugPrint('DownloadProvider: Loading downloads');
      await _notificationService.initialize();
      _downloadedVideos = await _offlineStorage.getOfflineVideos();

      // Verify files still exist on disk (user might have cleared storage)
      final toRemove = <String>[];
      for (final video in _downloadedVideos) {
        final exists = await _downloadService.isDownloaded(video.fileName);
        if (!exists) {
          toRemove.add(video.videoId);
        }
      }
      for (final videoId in toRemove) {
        await _offlineStorage.removeOfflineVideo(videoId);
        _downloadedVideos.removeWhere((v) => v.videoId == videoId);
      }

      _totalStorageUsedMb = await _offlineStorage.getTotalStorageUsedMb();
      _isLoaded = true;
      notifyListeners();
      debugPrint(
          'DownloadProvider: Loaded ${_downloadedVideos.length} videos, $formattedTotalStorage used');
    } finally {
      _isInitializing = false;
    }
  }

  /// Check if a video is downloaded (persistent check)
  bool isDownloaded(String videoId) {
    return _downloadedVideos.any((v) => v.videoId == videoId);
  }

  /// Check if a video is currently downloading
  bool isDownloading(String videoId) {
    return _activeDownloads.containsKey(videoId);
  }

  /// Check if a video download failed
  bool hasFailed(String videoId) {
    return _failedDownloads.containsKey(videoId);
  }

  /// Get failure error message
  String? getFailureMessage(String videoId) {
    return _failedDownloads[videoId];
  }

  /// Get download progress for a video (null if not downloading)
  double? getProgress(String videoId) {
    return _activeDownloads[videoId];
  }

  /// Get offline metadata for a video
  OfflineVideoModel? getOfflineVideo(String videoId) {
    try {
      return _downloadedVideos.firstWhere((v) => v.videoId == videoId);
    } catch (_) {
      return null;
    }
  }

  /// Get the title for a video that is downloading or failed
  String? getActiveDownloadTitle(String videoId) {
    return _downloadParams[videoId]?.title;
  }

  /// Start downloading a video.
  Future<void> startDownload({
    required String videoId,
    required String title,
    String? thumbnailUrl,
    String facultyName = '',
    int durationSeconds = 0,
    String? moduleName,
    String? seriesName,
  }) async {
    if (_activeDownloads.containsKey(videoId) || isDownloaded(videoId)) return;

    // Store params for potential retry
    final params = _DownloadParams(
      videoId: videoId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      facultyName: facultyName,
      durationSeconds: durationSeconds,
      moduleName: moduleName,
      seriesName: seriesName,
    );
    _downloadParams[videoId] = params;

    // Create cancel token for this download
    final cancelToken = CancelToken();
    _cancelTokens[videoId] = cancelToken;

    // Clear any previous failure
    _failedDownloads.remove(videoId);

    debugPrint('DownloadProvider: Starting download for $videoId');
    _activeDownloads[videoId] = 0.0;
    notifyListeners();

    // Show initial notification
    await _notificationService.showProgress(
      videoId: videoId,
      title: title,
      progress: 0.0,
    );

    try {
      // 1. Get signed download URL from backend
      final data = await _downloadService.getVideoDownloadUrl(videoId);
      final url = data['download_url'] as String;

      // Check if cancelled during URL fetch
      if (cancelToken.isCancelled) return;

      // Extract metadata from API response (backend now provides these)
      final apiThumbnail = data['thumbnail_url'] as String?;
      final apiDuration =
          (data['duration_seconds'] as num?)?.toInt() ?? durationSeconds;

      // 2. Download the file with progress tracking
      int lastNotifiedPct = 0;
      final filePath = await _downloadService.downloadFile(
        url: url,
        fileName: 'video_$videoId.mp4',
        cancelToken: cancelToken,
        onProgress: (progress) {
          _activeDownloads[videoId] = progress;
          notifyListeners();

          // Update notification every 5% to avoid flooding
          final pct = (progress * 100).round();
          if (pct - lastNotifiedPct >= 5 || pct >= 100) {
            lastNotifiedPct = pct;
            _notificationService.showProgress(
              videoId: videoId,
              title: title,
              progress: progress,
            );
          }
        },
      );

      // 3. Get actual file size from disk (backend file_size_mb is often 0)
      final fileOnDisk = File(filePath);
      final fileSizeBytes = await fileOnDisk.length();
      final actualFileSizeMb = fileSizeBytes / (1024 * 1024);

      // 4. Persist metadata
      final offlineVideo = OfflineVideoModel(
        videoId: videoId,
        title: title,
        thumbnailUrl: apiThumbnail ?? thumbnailUrl,
        facultyName: facultyName,
        durationSeconds: apiDuration,
        fileSizeMb: actualFileSizeMb,
        downloadedAt: DateTime.now(),
        filePath: filePath,
        moduleName: moduleName,
        seriesName: seriesName,
      );

      await _offlineStorage.saveOfflineVideo(offlineVideo);
      _downloadedVideos.insert(0, offlineVideo);
      _totalStorageUsedMb = await _offlineStorage.getTotalStorageUsedMb();

      _activeDownloads.remove(videoId);
      _cancelTokens.remove(videoId);
      _downloadParams.remove(videoId);
      notifyListeners();

      // Show completion notification
      await _notificationService.showComplete(videoId: videoId, title: title);

      debugPrint(
          'DownloadProvider: Download complete for $videoId (${actualFileSizeMb.toStringAsFixed(1)} MB)');
    } on DioException catch (e) {
      _activeDownloads.remove(videoId);
      _cancelTokens.remove(videoId);

      if (e.type == DioExceptionType.cancel) {
        // User cancelled - don't treat as failure
        debugPrint('DownloadProvider: Download cancelled for $videoId');
        _downloadParams.remove(videoId);
        notifyListeners();
        await _notificationService.cancel(videoId);
      } else {
        _failedDownloads[videoId] =
            e.message ?? 'Download failed';
        notifyListeners();
        debugPrint('DownloadProvider: Download failed for $videoId: $e');
        await _notificationService.showFailed(
            videoId: videoId, title: _downloadParams[videoId]?.title ?? 'Video');
      }

      // Clean up partial file
      await _downloadService.deleteDownload('video_$videoId.mp4');
      if (e.type != DioExceptionType.cancel) rethrow;
    } catch (e) {
      _activeDownloads.remove(videoId);
      _cancelTokens.remove(videoId);
      _failedDownloads[videoId] =
          e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      debugPrint('DownloadProvider: Download failed for $videoId: $e');

      // Show failure notification
      await _notificationService.showFailed(
          videoId: videoId, title: _downloadParams[videoId]?.title ?? 'Video');

      // Clean up partial file left by failed download
      await _downloadService.deleteDownload('video_$videoId.mp4');
      rethrow;
    }
  }

  /// Cancel an active download
  Future<void> cancelDownload(String videoId) async {
    final cancelToken = _cancelTokens[videoId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('User cancelled');
    }
    // If the token wasn't set yet (still fetching URL), clean up manually
    if (_activeDownloads.containsKey(videoId) && cancelToken == null) {
      _activeDownloads.remove(videoId);
      _cancelTokens.remove(videoId);
      _downloadParams.remove(videoId);
      notifyListeners();
      await _notificationService.cancel(videoId);
      await _downloadService.deleteDownload('video_$videoId.mp4');
    }
  }

  /// Retry a failed download
  Future<void> retryDownload(String videoId) async {
    final params = _downloadParams[videoId];
    if (params == null) return;

    _failedDownloads.remove(videoId);
    notifyListeners();

    await startDownload(
      videoId: params.videoId,
      title: params.title,
      thumbnailUrl: params.thumbnailUrl,
      facultyName: params.facultyName,
      durationSeconds: params.durationSeconds,
      moduleName: params.moduleName,
      seriesName: params.seriesName,
    );
  }

  /// Clear a failed download entry (dismiss error)
  void clearFailure(String videoId) {
    _failedDownloads.remove(videoId);
    _downloadParams.remove(videoId);
    notifyListeners();
  }

  /// Delete a downloaded video (file + metadata)
  Future<void> deleteDownload(String videoId) async {
    debugPrint('DownloadProvider: Deleting download $videoId');
    await _downloadService.deleteDownload('video_$videoId.mp4');
    await _offlineStorage.removeOfflineVideo(videoId);
    _downloadedVideos.removeWhere((v) => v.videoId == videoId);
    _totalStorageUsedMb = await _offlineStorage.getTotalStorageUsedMb();
    await _notificationService.cancel(videoId);
    notifyListeners();
  }

  /// Delete all downloaded videos
  Future<void> deleteAllDownloads() async {
    debugPrint('DownloadProvider: Deleting all downloads');
    for (final video in _downloadedVideos) {
      await _downloadService.deleteDownload(video.fileName);
      await _notificationService.cancel(video.videoId);
    }
    await _offlineStorage.clearAll();
    _downloadedVideos = [];
    _totalStorageUsedMb = 0;
    notifyListeners();
  }

  /// Get downloaded videos grouped by series
  Map<String, List<OfflineVideoModel>> get downloadsBySeriesGroup {
    final Map<String, List<OfflineVideoModel>> grouped = {};
    for (final video in _downloadedVideos) {
      final key = video.seriesName ?? 'Other';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(video);
    }
    return grouped;
  }
}
