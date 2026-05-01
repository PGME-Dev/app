import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Durable on-device cache for downloaded PDF documents.
///
/// Lives in the app's *cache* directory (purgeable by the OS under storage
/// pressure, but otherwise persistent across launches — unlike
/// `getTemporaryDirectory()`, which iOS treats as scratch space and is wiped
/// aggressively). A reopened PDF skips the network entirely as long as it
/// hasn't been evicted by the TTL or size cap.
///
/// Cache keys come from the caller — pass `documentId` when present so a
/// new signed URL on the next open still hits the same entry. Eviction is
/// LRU by file mtime (touched on every cache hit), bounded by both an age
/// TTL and a total-size cap.
///
/// ## Privacy
///
/// `getApplicationCacheDirectory()` resolves to **internal app storage** on
/// both platforms:
///
///   * Android: `/data/data/<pkg>/cache/pdf_cache/` — sandbox-private.
///     File managers (incl. Files by Google, Samsung My Files, ES Explorer)
///     cannot read another app's internal storage on Android 11+. Android
///     auto-backup systems explicitly exclude `getCacheDir()` so cached
///     PDFs never leave the device via `adb backup` / Pixel Migrate.
///   * iOS: `<sandbox>/Library/Caches/<bundle>/pdf_cache/` — sandbox-private.
///     The Files app only surfaces `Documents/` (and only when
///     `UIFileSharingEnabled` is set, which we don't). `Library/Caches/`
///     is also automatically excluded from iCloud backup per Apple's
///     system rule.
///
/// Files are stored as plain bytes — a rooted Android device or jailbroken
/// iPhone could still read the cache via shell. If at-rest encryption is
/// required, wrap the writes here with a `flutter_secure_storage`-derived
/// key + AES-GCM.
class PdfCacheService {
  /// How long a cached PDF stays valid since its last access.
  static const Duration defaultMaxAge = Duration(days: 7);

  /// Total cache size cap. Older entries (by mtime) are dropped first.
  /// 500 MB is enough to hold 5–10 medium textbooks without crowding out
  /// other app data on a 32 GB tablet.
  static const int defaultMaxBytes = 500 * 1024 * 1024;

  static const String _subdirName = 'pdf_cache';

  static Future<Directory> _cacheDir() async {
    // getApplicationCacheDirectory:
    //   Android → context.cacheDir (internal/cache)
    //   iOS     → ~/Library/Caches/<bundle>
    // Both are durable across launches and purgeable by the OS only on
    // genuine storage pressure — far more reliable than temporaryDirectory.
    final base = await getApplicationCacheDirectory();
    final dir = Directory('${base.path}/$_subdirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    // Defensive: drop a `.nomedia` marker so any future move of the cache
    // to scannable storage (or a custom file manager with shell access)
    // skips indexing the PDFs into Gallery / media pickers. No-op on iOS,
    // and harmless on Android internal storage where scanners don't run.
    final nomedia = File('${dir.path}/.nomedia');
    if (!await nomedia.exists()) {
      try {
        await nomedia.create();
      } catch (_) {/* best-effort */}
    }
    return dir;
  }

  /// Returns the cached file for [cacheKey] if it exists and isn't past
  /// [maxAge]. Bumps mtime on hit so the entry survives LRU eviction.
  static Future<File?> getCachedFile(
    String cacheKey, {
    Duration maxAge = defaultMaxAge,
  }) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/${_safeKey(cacheKey)}.pdf');
      if (!await file.exists()) return null;
      final stat = await file.stat();
      if (stat.size <= 0) {
        await _safeDelete(file);
        return null;
      }
      final age = DateTime.now().difference(stat.modified);
      if (age > maxAge) {
        await _safeDelete(file);
        return null;
      }
      // LRU touch: bump mtime so this entry isn't the next to be pruned.
      try {
        await file.setLastModified(DateTime.now());
      } catch (_) {/* best-effort */}
      return file;
    } catch (e) {
      debugPrint('[PdfCache] getCachedFile($cacheKey) error: $e');
      return null;
    }
  }

  /// Downloads [url] into the cache under [cacheKey] and returns the file.
  /// Writes to a `.part` sibling first and renames atomically so a crashed
  /// or cancelled download can't be served as a valid cached PDF on the
  /// next open. Pass [cancelToken] to abort an in-flight download (e.g.
  /// when the user closes the viewer before the file finishes).
  static Future<File> cacheFromUrl(
    String cacheKey,
    String url, {
    Dio? dio,
    CancelToken? cancelToken,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    final dir = await _cacheDir();
    final safeKey = _safeKey(cacheKey);
    final finalPath = '${dir.path}/$safeKey.pdf';
    final tempPath = '${dir.path}/$safeKey.pdf.part';
    final tempFile = File(tempPath);
    if (await tempFile.exists()) {
      await _safeDelete(tempFile);
    }

    final client = dio ?? Dio();
    try {
      await client.download(
        url,
        tempPath,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (_) {
      // Clean up the partial file so a retry isn't blocked by a stale
      // .part on disk.
      await _safeDelete(tempFile);
      rethrow;
    }

    final finalFile = File(finalPath);
    if (await finalFile.exists()) {
      await _safeDelete(finalFile);
    }
    await tempFile.rename(finalPath);
    return finalFile;
  }

  /// Drops entries older than [maxAge]. Safe to call from app startup
  /// fire-and-forget — failures are swallowed.
  static Future<void> cleanupExpired({
    Duration maxAge = defaultMaxAge,
  }) async {
    try {
      final dir = await _cacheDir();
      if (!await dir.exists()) return;
      final now = DateTime.now();
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        try {
          final stat = await entity.stat();
          if (now.difference(stat.modified) > maxAge) {
            await entity.delete();
          }
        } catch (_) {/* skip individual file failures */}
      }
    } catch (e) {
      debugPrint('[PdfCache] cleanupExpired error: $e');
    }
  }

  /// Enforces a total size cap by deleting LRU entries (oldest mtime first)
  /// until the cache fits under [maxBytes]. Safe to call after writes or
  /// on startup.
  static Future<void> pruneToSizeLimit({
    int maxBytes = defaultMaxBytes,
  }) async {
    try {
      final dir = await _cacheDir();
      if (!await dir.exists()) return;
      final entries = <_CacheEntry>[];
      int totalBytes = 0;
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        try {
          final stat = await entity.stat();
          entries.add(_CacheEntry(entity, stat.modified, stat.size));
          totalBytes += stat.size;
        } catch (_) {/* skip */}
      }
      if (totalBytes <= maxBytes) return;
      entries.sort((a, b) => a.modified.compareTo(b.modified)); // oldest first
      var bytesToRemove = totalBytes - maxBytes;
      for (final entry in entries) {
        if (bytesToRemove <= 0) break;
        try {
          await entry.file.delete();
          bytesToRemove -= entry.size;
        } catch (_) {/* skip */}
      }
    } catch (e) {
      debugPrint('[PdfCache] pruneToSizeLimit error: $e');
    }
  }

  /// Wipes the entire cache. Useful for "clear cache" settings actions.
  static Future<void> clear() async {
    try {
      final dir = await _cacheDir();
      if (!await dir.exists()) return;
      await for (final entity in dir.list()) {
        try {
          await entity.delete(recursive: true);
        } catch (_) {/* skip */}
      }
    } catch (e) {
      debugPrint('[PdfCache] clear error: $e');
    }
  }

  /// Returns the total size in bytes of the cache. Useful for surfacing
  /// usage in a settings screen.
  static Future<int> totalSizeBytes() async {
    try {
      final dir = await _cacheDir();
      if (!await dir.exists()) return 0;
      var total = 0;
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        try {
          total += (await entity.stat()).size;
        } catch (_) {/* skip */}
      }
      return total;
    } catch (e) {
      debugPrint('[PdfCache] totalSizeBytes error: $e');
      return 0;
    }
  }

  // Strips characters that are illegal in a path on either platform so a
  // raw URL or document id can't escape the cache directory.
  static String _safeKey(String input) {
    return input.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
  }

  static Future<void> _safeDelete(File file) async {
    try {
      await file.delete();
    } catch (_) {/* swallow */}
  }
}

class _CacheEntry {
  final File file;
  final DateTime modified;
  final int size;
  _CacheEntry(this.file, this.modified, this.size);
}
