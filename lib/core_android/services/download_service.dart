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

    debugPrint(
        '[PDF-DBG] DownloadService.downloadFile START fileName=$fileName '
        'target=$filePath urlHost=${_safeUrlHost(url)} '
        'urlLen=${url.length} urlPrefix=${_safeUrlPrefix(url)}');

    // Use a separate Dio instance without base URL for direct downloads
    final downloadDio = Dio();
    downloadDio.options.receiveTimeout = const Duration(minutes: 30);

    Response response;
    try {
      response = await downloadDio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(received / total);
          }
        },
      );
    } catch (e, st) {
      debugPrint(
          '[PDF-DBG] DownloadService.downloadFile FAILED fileName=$fileName '
          'err=$e');
      debugPrint('[PDF-DBG] stack: $st');
      rethrow;
    }

    // Post-download forensics — match the validation PdfCacheService does
    // for streamed PDFs so we can SEE if the downloaded blob is a real PDF.
    try {
      final file = File(filePath);
      final exists = await file.exists();
      final size = exists ? await file.length() : -1;
      final magic = exists ? await _readMagicBytes(file) : '<no-file>';
      final isPdf = magic.startsWith('%PDF');
      final headInfo = isPdf
          ? ''
          : ' headSnippet=${await _readHeadSnippet(file)}';
      final contentType = response.headers.value('content-type') ?? 'n/a';
      debugPrint(
          '[PDF-DBG] DownloadService.downloadFile DONE fileName=$fileName '
          'exists=$exists size=$size magic="$magic" isPdf=$isPdf '
          'statusCode=${response.statusCode} contentType=$contentType'
          '$headInfo');
    } catch (e) {
      debugPrint(
          '[PDF-DBG] DownloadService.downloadFile post-check error: $e');
    }

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
    final exists = await file.exists();
    if (exists) {
      try {
        final size = await file.length();
        final magic = await _readMagicBytes(file);
        debugPrint(
            '[PDF-DBG] DownloadService.getDownloadedPath HIT fileName=$fileName '
            'path=${file.path} size=$size magic="$magic" isPdf=${magic.startsWith('%PDF')}');
      } catch (e) {
        debugPrint(
            '[PDF-DBG] DownloadService.getDownloadedPath stat error: $e');
      }
      return file.path;
    }
    debugPrint(
        '[PDF-DBG] DownloadService.getDownloadedPath MISS fileName=$fileName '
        'path=${file.path}');
    return null;
  }

  /// Reads first 8 bytes of [file] and returns as printable ASCII. Used by
  /// debug logging to spot non-PDF payloads (HTML/JSON error bodies) that
  /// got written to disk because we don't currently validate the download
  /// content-type.
  static Future<String> _readMagicBytes(File file) async {
    try {
      final raf = await file.open();
      try {
        final bytes = await raf.read(8);
        final buf = StringBuffer();
        for (final b in bytes) {
          if (b >= 0x20 && b < 0x7F) {
            buf.writeCharCode(b);
          } else {
            buf.write('\\x${b.toRadixString(16).padLeft(2, '0')}');
          }
        }
        return buf.toString();
      } finally {
        await raf.close();
      }
    } catch (e) {
      return '<read-err:$e>';
    }
  }

  /// Reads up to first 200 bytes of [file] as a printable preview. Only
  /// called when the magic header doesn't look like a PDF — gives us a
  /// chance to recognize an HTML error page or JSON auth payload.
  static Future<String> _readHeadSnippet(File file) async {
    try {
      final raf = await file.open();
      try {
        final bytes = await raf.read(200);
        final buf = StringBuffer();
        for (final b in bytes) {
          if (b == 0x0A) {
            buf.write('\\n');
          } else if (b == 0x0D) {
            buf.write('\\r');
          } else if (b >= 0x20 && b < 0x7F) {
            buf.writeCharCode(b);
          } else {
            buf.write('.');
          }
        }
        return buf.toString();
      } finally {
        await raf.close();
      }
    } catch (e) {
      return '<read-err:$e>';
    }
  }

  /// Strips query string + path so we can log the source host without
  /// leaking signed-URL credentials into the device log buffer.
  static String _safeUrlHost(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return '<unparseable>';
    }
  }

  /// First 80 chars of the URL minus query string — enough to tell which
  /// endpoint generated the link without dumping the signature.
  static String _safeUrlPrefix(String url) {
    try {
      final uri = Uri.parse(url);
      final base = '${uri.scheme}://${uri.host}${uri.path}';
      return base.length > 80 ? '${base.substring(0, 80)}…' : base;
    } catch (_) {
      return url.length > 80 ? '${url.substring(0, 80)}…' : url;
    }
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
