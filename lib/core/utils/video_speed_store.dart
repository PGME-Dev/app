import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Tiny persistence layer for the user's chosen video playback speed.
///
/// Earlier the value was kept in [SharedPreferences], which on iOS is
/// backed by `NSUserDefaults` — writes are queued and flushed by the OS
/// asynchronously. If the user changed speed and killed the app within
/// the flush window the value was lost (and sometimes a *previous* queued
/// value was the one that hit disk, producing the "last‑to‑last" symptom
/// the user reported).
///
/// This store writes the value as plain text to a file inside the app
/// documents directory using [File.writeAsStringSync], which blocks the
/// caller until the bytes are handed to the kernel. That makes the write
/// durable across an abrupt app kill on both iOS and Android.
class VideoSpeedStore {
  VideoSpeedStore._();

  static const String _fileName = 'video_playback_speed.txt';

  /// Cached file handle so we don't repeatedly hit `getApplicationDocumentsDirectory`
  /// on every save (it's an async platform call that defeats the point of
  /// the sync write).
  static File? _file;
  static Future<File>? _filePending;

  /// Resolve the file once. Call this during app/screen init so [saveSync]
  /// is ready to use synchronously when the user changes speed.
  static Future<File> ensureReady() {
    if (_file != null) return Future.value(_file!);
    return _filePending ??= () async {
      final dir = await getApplicationDocumentsDirectory();
      _file = File('${dir.path}/$_fileName');
      return _file!;
    }();
  }

  /// Read the saved speed. Returns null if no value has ever been
  /// written, the file is missing, or its contents are unparseable.
  static Future<double?> read() async {
    try {
      final file = await ensureReady();
      if (!file.existsSync()) {
        debugPrint('[SpeedStore] read: file missing at ${file.path}');
        return null;
      }
      final text = file.readAsStringSync().trim();
      final value = double.tryParse(text);
      if (value == null || value <= 0) {
        debugPrint('[SpeedStore] read: unparseable "$text"');
        return null;
      }
      debugPrint('[SpeedStore] read: $value from ${file.path}');
      return value;
    } catch (e) {
      debugPrint('[SpeedStore] read failed - $e');
      return null;
    }
  }

  /// Write the speed synchronously. Safe to call from event handlers —
  /// the underlying write blocks for sub-millisecond time on flash
  /// storage. Requires [ensureReady] to have been awaited at least once
  /// (otherwise the write is silently dropped and only the next async
  /// save catches up).
  static void saveSync(double speed) {
    final file = _file;
    if (file == null) {
      // Kick off async warm-up so the next call hits the fast path.
      // First save still happens via the async fallback below.
      ensureReady().then((f) {
        try {
          f.writeAsStringSync(speed.toString());
          debugPrint('[SpeedStore] deferred save: $speed -> ${f.path}');
        } catch (e) {
          debugPrint('[SpeedStore] deferred save failed - $e');
        }
      });
      return;
    }
    try {
      file.writeAsStringSync(speed.toString());
      debugPrint('[SpeedStore] save: $speed -> ${file.path}');
    } catch (e) {
      debugPrint('[SpeedStore] save failed - $e');
    }
  }
}
