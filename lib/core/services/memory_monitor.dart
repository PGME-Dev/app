import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Periodically logs the app's heap usage and warns when it nears the
/// per-app heap cap. Also reacts to Android low-memory signals
/// ([WidgetsBindingObserver.didHaveMemoryPressure]).
///
/// Why this matters: on mid-tier OEMs (BBK group, MIUI, budget tablets) the
/// per-app JVM heap is capped at 256-384 MB regardless of device RAM. The
/// production OOM crashes happen when this cap is hit, not when device RAM
/// is exhausted. This monitor surfaces that ceiling in adb logcat so we can
/// see growth in real time.
///
/// Logs are tagged `[MEM]` for easy filtering: `adb logcat | findstr MEM`.
class MemoryMonitor with WidgetsBindingObserver {
  MemoryMonitor._();
  static final MemoryMonitor instance = MemoryMonitor._();

  static const _channel = MethodChannel('com.pgme.app/memory_info');

  /// 80% of heap cap → start warning.
  static const double _warnThreshold = 0.80;

  /// 95% of heap cap → critical, OOM is likely soon.
  static const double _criticalThreshold = 0.95;

  Timer? _timer;
  bool _started = false;
  Duration _interval = const Duration(seconds: 10);

  void start({Duration interval = const Duration(seconds: 10)}) {
    if (_started) return;
    _started = true;
    _interval = interval;
    WidgetsBinding.instance.addObserver(this);
    _scheduleNext();
    // Immediate first sample so we see baseline at app start.
    _sample(reason: 'start');
  }

  void stop() {
    if (!_started) return;
    _started = false;
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(_interval, () {
      if (!_started) return;
      _sample(reason: 'tick');
      _scheduleNext();
    });
  }

  /// Forces an immediate sample with a custom label. Use this around
  /// memory-sensitive transitions (e.g. before/after disposing a player,
  /// before/after loading a PDF) to see the delta in the log.
  Future<void> logNow(String label) => _sample(reason: label);

  @override
  void didHaveMemoryPressure() {
    // Android raised onTrimMemory / iOS sent UIApplicationDidReceiveMemoryWarning.
    // Sample immediately so the log shows the heap state at the moment of pressure.
    _sample(reason: 'PRESSURE-SIGNAL');
  }

  Future<void> _sample({required String reason}) async {
    if (!Platform.isAndroid) {
      // iOS doesn't have the same per-app JVM heap cap; skip for now.
      return;
    }
    try {
      final info =
          await _channel.invokeMapMethod<String, dynamic>('getHeapInfo');
      if (info == null) return;
      _emit(info, reason);
    } catch (e) {
      debugPrint('[MEM] Failed to read heap info: $e');
    }
  }

  void _emit(Map<String, dynamic> info, String reason) {
    final maxBytes = (info['dartHeapMaxBytes'] as num?)?.toInt() ?? 0;
    final usedBytes = (info['dartHeapUsedBytes'] as num?)?.toInt() ?? 0;
    final totalBytes = (info['dartHeapTotalBytes'] as num?)?.toInt() ?? 0;
    final nativeBytes =
        (info['nativeHeapAllocatedBytes'] as num?)?.toInt() ?? 0;
    final memClass = (info['memoryClassMb'] as num?)?.toInt() ?? 0;
    final largeMemClass = (info['largeMemoryClassMb'] as num?)?.toInt() ?? 0;
    final sysAvail = (info['systemAvailMemBytes'] as num?)?.toInt() ?? 0;
    final isLow = info['isLowMemory'] as bool? ?? false;

    final usedMb = _toMb(usedBytes);
    final totalMb = _toMb(totalBytes);
    final maxMb = _toMb(maxBytes);
    final nativeMb = _toMb(nativeBytes);
    final sysAvailMb = _toMb(sysAvail);

    final ratio = maxBytes > 0 ? usedBytes / maxBytes : 0.0;
    final pct = (ratio * 100).toStringAsFixed(0);

    // Tagged with reason so timeline is easy to follow in logcat.
    final tag = reason == 'tick' ? '' : ' [$reason]';

    if (ratio >= _criticalThreshold) {
      debugPrint(
          '[MEM]$tag CRITICAL Java heap ${usedMb}MB/${maxMb}MB ($pct%) — OOM IMMINENT  '
          '| native ${nativeMb}MB | sysAvail ${sysAvailMb}MB | lowMem=$isLow');
    } else if (ratio >= _warnThreshold) {
      debugPrint(
          '[MEM]$tag WARN Java heap ${usedMb}MB/${maxMb}MB ($pct%) nearing cap  '
          '| native ${nativeMb}MB | sysAvail ${sysAvailMb}MB | lowMem=$isLow');
    } else {
      debugPrint(
          '[MEM]$tag Java heap ${usedMb}MB/${totalMb}MB allocated of ${maxMb}MB cap ($pct% used)  '
          '| native ${nativeMb}MB | sysAvail ${sysAvailMb}MB | lowMem=$isLow  '
          '| heapClass=${memClass}MB largeHeapClass=${largeMemClass}MB');
    }

    if (isLow) {
      debugPrint(
          '[MEM]$tag system flagged LOW MEMORY — Android may start killing background apps');
    }
  }

  static int _toMb(int bytes) => (bytes / (1024 * 1024)).round();
}
