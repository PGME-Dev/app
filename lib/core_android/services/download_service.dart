import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pgme/core_android/constants/api_constants.dart';
import 'package:pgme/core_android/services/api_service.dart';

/// Result of a video download performed via the OS-managed background engine.
class VideoDownloadResult {
  final bool success;
  final bool canceled;
  final String? filePath;
  final String? errorMessage;

  const VideoDownloadResult._({
    required this.success,
    required this.canceled,
    this.filePath,
    this.errorMessage,
  });

  factory VideoDownloadResult.success(String filePath) =>
      VideoDownloadResult._(success: true, canceled: false, filePath: filePath);
  factory VideoDownloadResult.canceledByUser() =>
      const VideoDownloadResult._(success: false, canceled: true);
  factory VideoDownloadResult.failure(String message) =>
      VideoDownloadResult._(success: false, canceled: false, errorMessage: message);
}

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final ApiService _apiService = ApiService();
  bool _bgInitialized = false;

  /// Initialize the background downloader plugin (notifications, FG service).
  /// Safe to call multiple times — only the first call takes effect.
  Future<void> initializeBackgroundDownloader() async {
    if (_bgInitialized) return;
    _bgInitialized = true;
    try {
      await FileDownloader().configureNotification(
        running: const TaskNotification(
          'Downloading {displayName}',
          '{progress} • {networkSpeed} • {timeRemaining}',
        ),
        complete: const TaskNotification(
          'Download complete',
          '{displayName}',
        ),
        error: const TaskNotification(
          'Download failed',
          '{displayName}',
        ),
        paused: const TaskNotification(
          'Download paused',
          '{displayName}',
        ),
        progressBar: true,
        tapOpensFile: false,
      );
      // Ensure target directory + .nomedia exist before any task runs.
      await _getDownloadsDir();
      debugPrint('DownloadService: background downloader initialized');
    } catch (e) {
      debugPrint('DownloadService: failed to init background downloader - $e');
    }
  }

  /// Get the persistent downloads directory
  Future<Directory> _getDownloadsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${appDir.path}/pgme_downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    // Create .nomedia file to hide from device media scanner / file browser
    final nomediaFile = File('${downloadsDir.path}/.nomedia');
    if (!await nomediaFile.exists()) {
      await nomediaFile.create();
    }
    return downloadsDir;
  }

  /// Get video download URL from backend
  Future<Map<String, dynamic>> getVideoDownloadUrl(String videoId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.videoDownloadUrl(videoId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(
          response.data['message'] ?? 'Failed to get download URL');
    } on DioException catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to get video download URL: ${e.toString()}');
    }
  }

  /// Download a file with progress tracking and optional cancellation
  Future<String> downloadFile({
    required String url,
    required String fileName,
    required Function(double) onProgress,
    CancelToken? cancelToken,
  }) async {
    final dir = await _getDownloadsDir();
    final filePath = '${dir.path}/$fileName';

    // Use a separate Dio instance without base URL for direct downloads
    final downloadDio = Dio();
    downloadDio.options.receiveTimeout = const Duration(minutes: 30);

    await downloadDio.download(
      url,
      filePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(received / total);
        }
      },
    );

    return filePath;
  }

  /// Check if a file is already downloaded
  Future<bool> isDownloaded(String fileName) async {
    final dir = await _getDownloadsDir();
    final file = File('${dir.path}/$fileName');
    return file.exists();
  }

  /// Get path of a downloaded file (null if not downloaded)
  Future<String?> getDownloadedPath(String fileName) async {
    final dir = await _getDownloadsDir();
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  /// Delete a downloaded file
  Future<void> deleteDownload(String fileName) async {
    final dir = await _getDownloadsDir();
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Download a video via OS-managed background task.
  /// Survives app backgrounding, screen-off, and (mostly) app process kill.
  /// Supports HTTP Range resume on networks/CDNs that honor it (S3, Cloudinary do).
  ///
  /// [videoId] is used as the taskId, so cancel/lookup uses the same id.
  /// [title] shows in the OS notification.
  Future<VideoDownloadResult> downloadVideoFile({
    required String url,
    required String videoId,
    required String fileName,
    required String title,
    required void Function(double progress) onProgress,
  }) async {
    await initializeBackgroundDownloader();
    await _getDownloadsDir(); // ensures pgme_downloads + .nomedia

    final task = DownloadTask(
      taskId: videoId,
      url: url,
      filename: fileName,
      baseDirectory: BaseDirectory.applicationDocuments,
      directory: 'pgme_downloads',
      updates: Updates.statusAndProgress,
      allowPause: true,
      retries: 3,
      requiresWiFi: false,
      displayName: title,
    );

    try {
      final result = await FileDownloader().download(
        task,
        onProgress: (p) {
          if (p >= 0 && p <= 1) onProgress(p);
        },
      );

      switch (result.status) {
        case TaskStatus.complete:
          final filePath = await task.filePath();
          return VideoDownloadResult.success(filePath);
        case TaskStatus.canceled:
          return VideoDownloadResult.canceledByUser();
        case TaskStatus.failed:
          return VideoDownloadResult.failure(
            result.exception?.description ?? 'Download failed',
          );
        case TaskStatus.notFound:
          return VideoDownloadResult.failure('File not found on server');
        default:
          return VideoDownloadResult.failure(
            'Unexpected download state: ${result.status}',
          );
      }
    } catch (e) {
      return VideoDownloadResult.failure(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Cancel an active video download by videoId (= taskId).
  Future<void> cancelVideoDownload(String videoId) async {
    try {
      await FileDownloader().cancelTaskWithId(videoId);
    } catch (e) {
      debugPrint('DownloadService: cancel failed for $videoId - $e');
    }
  }
}
