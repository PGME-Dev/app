import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Checks available device storage via platform channels.
/// Returns values in MB. Returns -1 on failure.
class StorageHelper {
  static const _channel = MethodChannel('com.pgme.app/storage_info');

  /// Minimum free space required to start a download (in MB).
  /// 200 MB gives a comfortable buffer for typical video files.
  static const double minRequiredMb = 200;

  /// Get available (free) disk space in MB.
  static Future<double> getFreeDiskSpaceMB() async {
    try {
      final result = await _channel.invokeMethod<double>('getFreeDiskSpace');
      return result ?? -1;
    } catch (e) {
      debugPrint('StorageHelper: getFreeDiskSpace failed - $e');
      return -1;
    }
  }

  /// Get total disk space in MB.
  static Future<double> getTotalDiskSpaceMB() async {
    try {
      final result = await _channel.invokeMethod<double>('getTotalDiskSpace');
      return result ?? -1;
    } catch (e) {
      debugPrint('StorageHelper: getTotalDiskSpace failed - $e');
      return -1;
    }
  }

  /// Returns true if there is enough free space to download a video.
  /// [estimatedSizeMb] is an optional hint; if not provided the default
  /// [minRequiredMb] threshold is used.
  static Future<bool> hasEnoughSpace({double? estimatedSizeMb}) async {
    final free = await getFreeDiskSpaceMB();
    if (free < 0) return true; // can't determine — allow download, let it fail naturally
    final required = estimatedSizeMb ?? minRequiredMb;
    return free >= required;
  }

  /// Human-readable free space string (e.g. "1.2 GB" or "450 MB").
  static String formatMb(double mb) {
    if (mb < 0) return 'Unknown';
    if (mb >= 1024) return '${(mb / 1024).toStringAsFixed(1)} GB';
    return '${mb.toStringAsFixed(0)} MB';
  }
}
