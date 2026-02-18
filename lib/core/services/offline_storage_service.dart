import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pgme/core/models/offline_video_model.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance =
      OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  static const String _storageKey = 'pgme_offline_videos';

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
    _cachedVideos = [];
  }

  Future<void> _persist(List<OfflineVideoModel> videos) async {
    _cachedVideos = videos;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(videos.map((v) => v.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
