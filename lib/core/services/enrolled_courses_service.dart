import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/lecture_model.dart';
import 'package:pgme/core/models/access_record_model.dart';
import 'package:pgme/core/models/series_model.dart';
import 'package:pgme/core/models/progress_model.dart';
import 'package:pgme/core/models/library_model.dart';
import 'package:pgme/core/services/api_service.dart';

class EnrolledCoursesService {
  final ApiService _apiService = ApiService();

  // Cache for series (1 hour TTL)
  DateTime? _lastSeriesFetch;
  List<SeriesModel>? _cachedSeries;
  String? _cachedSeriesPurchaseId;

  /// Get all user purchases
  /// Returns list of active and expired purchases
  Future<List<AccessRecordModel>> getPurchases() async {
    try {
      debugPrint('=== EnrolledCoursesService: Getting purchases ===');

      final response = await _apiService.dio.get(
        ApiConstants.purchases,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final purchasesData = response.data['data']['purchases'] as List;

        // Debug: Log raw API response for each purchase
        debugPrint('=== RAW API RESPONSE ===');
        for (var i = 0; i < purchasesData.length; i++) {
          final raw = purchasesData[i] as Map<String, dynamic>;
          final pkg = raw['package'] as Map<String, dynamic>?;
          debugPrint('Purchase $i:');
          debugPrint('  package_name: ${pkg?['name']}');
          debugPrint('  package_type: ${pkg?['package_type']}');
          debugPrint('  is_active: ${raw['is_active']}');
          debugPrint('  payment_status: ${raw['payment_status']}');
        }
        debugPrint('=== END RAW API RESPONSE ===');

        final purchases = purchasesData
            .map((json) => AccessRecordModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by purchase date (newest first)
        purchases.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));

        debugPrint('✓ ${purchases.length} purchases retrieved');
        return purchases;
      }

      throw Exception('Failed to load purchases');
    } on DioException catch (e) {
      debugPrint('✗ Get purchases error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get purchase details by ID
  /// Includes complete package information and expiry details
  Future<AccessRecordModel> getPurchaseDetails(String purchaseId) async {
    try {
      debugPrint('=== EnrolledCoursesService: Getting purchase details ===');

      final response = await _apiService.dio.get(
        ApiConstants.purchaseDetails(purchaseId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final purchaseData = response.data['data']['purchase'];
        final purchase = AccessRecordModel.fromJson(purchaseData as Map<String, dynamic>);

        debugPrint('✓ Purchase details retrieved: ${purchase.package.name}');
        return purchase;
      }

      throw Exception('Failed to load purchase details');
    } on DioException catch (e) {
      debugPrint('✗ Get purchase details error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get series for a purchase
  /// Returns both theory and practical series
  /// Use forceRefresh to bypass cache
  Future<List<SeriesModel>> getSeries({
    required String purchaseId,
    String? type,
    bool forceRefresh = false,
  }) async {
    try {
      debugPrint('=== EnrolledCoursesService: Getting series ===');

      // Check cache validity (1 hour TTL)
      if (!forceRefresh &&
          _cachedSeries != null &&
          _lastSeriesFetch != null &&
          _cachedSeriesPurchaseId == purchaseId &&
          DateTime.now().difference(_lastSeriesFetch!) < const Duration(hours: 1)) {
        debugPrint('✓ Returning cached series (${_cachedSeries!.length} items)');

        // Filter by type if specified
        if (type != null) {
          return _cachedSeries!.where((s) => s.type == type).toList();
        }
        return _cachedSeries!;
      }

      final queryParams = <String, dynamic>{
        'purchase_id': purchaseId,
      };
      if (type != null) {
        queryParams['type'] = type;
      }

      final response = await _apiService.dio.get(
        ApiConstants.series,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final seriesData = response.data['data']['series'] as List;
        final series = seriesData
            .map((json) => SeriesModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by sequence number
        series.sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));

        // Update cache
        _cachedSeries = series;
        _lastSeriesFetch = DateTime.now();
        _cachedSeriesPurchaseId = purchaseId;

        debugPrint('✓ ${series.length} series retrieved and cached');
        return series;
      }

      throw Exception('Failed to load series');
    } on DioException catch (e) {
      debugPrint('✗ Get series error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get user's recent progress.
  /// Uses GET /users/progress/last-watched (the only backend endpoint available).
  /// Client-side filters isCompleted and limit are applied after fetch.
  Future<List<ProgressModel>> getProgress({
    String? purchaseId,
    String? seriesId,
    bool? isCompleted,
    int? limit,
  }) async {
    try {
      debugPrint('=== EnrolledCoursesService: Getting progress (last-watched) ===');

      final queryParams = <String, dynamic>{
        'limit': limit ?? 10,
      };

      final response = await _apiService.dio.get(
        ApiConstants.lastWatched,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final videosData = response.data['data']['videos'] as List;

        final progress = videosData.map((json) {
          return _progressFromLastWatchedJson(json as Map<String, dynamic>);
        }).toList();

        // Apply optional client-side filter
        final filtered = isCompleted != null
            ? progress.where((p) => p.isCompleted == isCompleted).toList()
            : progress;

        // Sort by last watched (most recent first)
        filtered.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));

        debugPrint('✓ ${filtered.length} progress items retrieved');
        return filtered;
      }

      throw Exception('Failed to load progress');
    } on DioException catch (e) {
      debugPrint('✗ Get progress error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Update or create video progress.
  /// Calls POST /users/progress/video/:videoId — the correct backend endpoint.
  Future<ProgressModel> updateProgress({
    required String lectureId,
    required int lastWatchedPositionSeconds,
    required int watchTimeSeconds,
    required bool isCompleted,
    required int completionPercentage,
  }) async {
    try {
      debugPrint('=== EnrolledCoursesService: Updating progress ===');

      final response = await _apiService.dio.post(
        ApiConstants.updateVideoProgress(lectureId),
        data: {
          'position_seconds': lastWatchedPositionSeconds,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data']['progress'] as Map<String, dynamic>;
        final progress = _progressFromUpdateJson(
          data,
          lectureId: lectureId,
          watchTimeSeconds: watchTimeSeconds,
          sentPositionSeconds: lastWatchedPositionSeconds,
          sentIsCompleted: isCompleted,
          sentCompletionPercentage: completionPercentage,
        );

        debugPrint('✓ Progress updated for lecture: $lectureId');
        return progress;
      }

      throw Exception('Failed to update progress');
    } on DioException catch (e) {
      debugPrint('✗ Update progress error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Fetch progress for a specific video from the backend.
  /// Returns the position in seconds, or null if no progress exists.
  Future<Map<String, dynamic>?> getVideoProgress(String videoId) async {
    try {
      debugPrint('=== EnrolledCoursesService: Fetching video progress for $videoId ===');

      final response = await _apiService.dio.get(
        ApiConstants.getVideoProgress(videoId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        // The response may have progress nested or flat — handle both
        final progress = data is Map<String, dynamic>
            ? (data['progress'] as Map<String, dynamic>? ?? data)
            : null;

        if (progress != null) {
          debugPrint('✓ Video progress fetched: position_seconds=${progress['position_seconds']}');
          return progress;
        }
      }

      return null;
    } catch (e) {
      debugPrint('✗ Fetch video progress failed: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers — map backend response shapes to ProgressModel
  // ---------------------------------------------------------------------------

  /// Maps the GET /last-watched item to a ProgressModel.
  ProgressModel _progressFromLastWatchedJson(Map<String, dynamic> json) {
    final videoId = json['video_id'] as String? ?? '';
    final durationSeconds = (json['duration_seconds'] as num?)?.toInt() ?? 0;
    return ProgressModel(
      progressId: videoId,
      lecture: LectureModel(
        lectureId: videoId,
        title: json['title'] as String? ?? '',
        durationMinutes: (durationSeconds / 60).ceil(),
        sequenceNumber: 0,
        isFree: false,
      ),
      watchTimeSeconds: 0,
      lastWatchedPositionSeconds:
          (json['position_seconds'] as num?)?.toInt() ?? 0,
      isCompleted: json['completed'] as bool? ?? false,
      completionPercentage:
          (json['watch_percentage'] as num?)?.toInt() ?? 0,
      lastWatchedAt: json['last_accessed_at'] as String? ??
          DateTime.now().toIso8601String(),
    );
  }

  /// Maps the POST /video/:id response to a ProgressModel.
  /// Uses the sent values as fallbacks in case the backend response omits
  /// or uses different field names for position/completion data.
  ProgressModel _progressFromUpdateJson(
    Map<String, dynamic> json, {
    required String lectureId,
    required int watchTimeSeconds,
    required int sentPositionSeconds,
    required bool sentIsCompleted,
    required int sentCompletionPercentage,
  }) {
    final durationSeconds =
        (json['duration_seconds'] as num?)?.toInt() ?? 0;
    final backendPosition =
        (json['position_seconds'] as num?)?.toInt() ?? 0;
    return ProgressModel(
      progressId: json['video_id'] as String? ?? lectureId,
      lecture: LectureModel(
        lectureId: lectureId,
        title: '',
        durationMinutes: (durationSeconds / 60).ceil(),
        sequenceNumber: 0,
        isFree: false,
      ),
      watchTimeSeconds: watchTimeSeconds,
      lastWatchedPositionSeconds:
          backendPosition > 0 ? backendPosition : sentPositionSeconds,
      isCompleted: json['completed'] as bool? ?? sentIsCompleted,
      completionPercentage:
          (json['watch_percentage'] as num?)?.toInt() ?? sentCompletionPercentage,
      lastWatchedAt: json['last_accessed_at'] as String? ??
          DateTime.now().toIso8601String(),
    );
  }

  /// Get user's library (saved documents)
  /// Returns PDFs, notes, and handouts saved by user
  Future<List<LibraryModel>> getLibrary({String? purchaseId}) async {
    try {
      debugPrint('=== EnrolledCoursesService: Getting library ===');

      final queryParams = <String, dynamic>{};
      if (purchaseId != null) {
        queryParams['purchase_id'] = purchaseId;
      }

      final response = await _apiService.dio.get(
        ApiConstants.library,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final libraryData = response.data['data']['library'] as List;
        final library = libraryData
            .map((json) => LibraryModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by added date (most recent first)
        library.sort((a, b) => b.addedAt.compareTo(a.addedAt));

        debugPrint('✓ ${library.length} library items retrieved');
        return library;
      }

      throw Exception('Failed to load library');
    } on DioException catch (e) {
      debugPrint('✗ Get library error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Add a document to user's library
  /// Returns the created library item
  Future<LibraryModel> addToLibrary({required String documentId}) async {
    try {
      debugPrint('=== EnrolledCoursesService: Adding to library ===');

      final response = await _apiService.dio.post(
        ApiConstants.addToLibrary,
        data: {
          'document_id': documentId,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final libraryData = response.data['data']['library'];
        final library = LibraryModel.fromJson(libraryData as Map<String, dynamic>);

        debugPrint('✓ Document added to library: $documentId');
        return library;
      }

      throw Exception('Failed to add to library');
    } on DioException catch (e) {
      debugPrint('✗ Add to library error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Remove a document from user's library
  /// Returns true if successfully removed
  Future<bool> removeFromLibrary({required String libraryId}) async {
    try {
      debugPrint('=== EnrolledCoursesService: Removing from library ===');

      final response = await _apiService.dio.delete(
        ApiConstants.removeFromLibrary(libraryId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✓ Document removed from library: $libraryId');
        return true;
      }

      throw Exception('Failed to remove from library');
    } on DioException catch (e) {
      debugPrint('✗ Remove from library error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Clear series cache
  void clearSeriesCache() {
    debugPrint('=== EnrolledCoursesService: Clearing series cache ===');
    _cachedSeries = null;
    _lastSeriesFetch = null;
    _cachedSeriesPurchaseId = null;
  }

  /// Clear all caches
  void clearCache() {
    debugPrint('=== EnrolledCoursesService: Clearing all caches ===');
    clearSeriesCache();
  }
}
