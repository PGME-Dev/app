import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pgme/core/models/offline_video_model.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance =
      OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  static const String _storageKey = 'pgme_offline_videos';
  static const String _lastWatchedKey = 'pgme_last_watched_video';
  static const String _videoProgressPrefix = 'pgme_video_progress_';

  /// In-memory cache
  List<OfflineVideoModel>? _cachedVideos;

  /// Load all offline video metadata from SharedPreferences
  Future<List<OfflineVideoModel>> getOfflineVideos() async {
    if (_cachedVideos != null) return List.from(_cachedVideos!);

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      _cachedVideos = [];
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      _cachedVideos = jsonList
          .map((e) => OfflineVideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return List.from(_cachedVideos!);
    } catch (e) {
      _cachedVideos = [];
      return [];
    }
  }

  /// Save a new offline video entry
  Future<void> saveOfflineVideo(OfflineVideoModel video) async {
    final videos = await getOfflineVideos();
    // Remove existing entry for same videoId (in case of re-download)
    videos.removeWhere((v) => v.videoId == video.videoId);
    videos.insert(0, video); // newest first
    await _persist(videos);
  }

  /// Remove an offline video entry by videoId
  Future<void> removeOfflineVideo(String videoId) async {
    final videos = await getOfflineVideos();
    videos.removeWhere((v) => v.videoId == videoId);
    await _persist(videos);
  }

  /// Get metadata for a specific video (null if not found)
  Future<OfflineVideoModel?> getOfflineVideo(String videoId) async {
    final videos = await getOfflineVideos();
    try {
      return videos.firstWhere((v) => v.videoId == videoId);
    } catch (_) {
      return null;
    }
  }

  /// Check if a video has offline metadata
  Future<bool> hasOfflineVideo(String videoId) async {
    final videos = await getOfflineVideos();
    return videos.any((v) => v.videoId == videoId);
  }

  /// Get total storage used in MB
  Future<double> getTotalStorageUsedMb() async {
    final videos = await getOfflineVideos();
    return videos.fold<double>(0.0, (sum, v) => sum + v.fileSizeMb);
  }

  /// Clear all offline metadata
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.remove(_lastWatchedKey);
    _cachedVideos = [];
  }

  // ---------------------------------------------------------------------------
  // Last Watched Video (for home screen "Continue where you left off")
  // ---------------------------------------------------------------------------

  /// Save the last watched video metadata for offline fallback on home screen.
  /// [videoJson] should match the VideoModel.toJson() format.
  Future<void> saveLastWatchedVideo(Map<String, dynamic> videoJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastWatchedKey, jsonEncode(videoJson));
  }

  /// Load the cached last-watched video. Returns null when nothing is saved.
  Future<Map<String, dynamic>?> getLastWatchedVideo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastWatchedKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Per-Video Progress (for resume when offline or provider list is empty)
  // ---------------------------------------------------------------------------

  /// Save the playback position for a specific video.
  Future<void> saveVideoProgress(
    String videoId,
    int positionSeconds,
    int durationSeconds,
    bool isCompleted,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_videoProgressPrefix$videoId',
      jsonEncode({
        'videoId': videoId,
        'positionSeconds': positionSeconds,
        'durationSeconds': durationSeconds,
        'isCompleted': isCompleted,
        'savedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  /// Get the locally-saved playback position for a video.
  /// Returns null when no local progress exists.
  Future<Map<String, dynamic>?> getVideoProgress(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_videoProgressPrefix$videoId');
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist(List<OfflineVideoModel> videos) async {
    _cachedVideos = videos;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(videos.map((v) => v.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
