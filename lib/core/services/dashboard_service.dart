import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/live_session_model.dart';
import 'package:pgme/core/models/package_model.dart';
import 'package:pgme/core/models/video_model.dart';
import 'package:pgme/core/models/faculty_model.dart';
import 'package:pgme/core/models/subject_selection_model.dart';
import 'package:pgme/core/models/series_model.dart';
import 'package:pgme/core/models/module_model.dart';
import 'package:pgme/core/models/series_document_model.dart';
import 'package:pgme/core/services/api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  // Cache for faculty (1 hour TTL)
  DateTime? _lastFacultyFetch;
  List<FacultyModel>? _cachedFaculty;

  // Cache for packages (1 hour TTL)
  DateTime? _lastPackagesFetch;
  List<PackageModel>? _cachedPackages;
  String? _cachedPackagesSubjectId;

  /// Get next upcoming live session
  /// Returns null if no upcoming session found
  Future<LiveSessionModel?> getNextUpcomingSession({String? subjectId}) async {
    try {
      debugPrint('=== DashboardService: Getting next upcoming session ===');

      final queryParams = <String, dynamic>{};
      if (subjectId != null) {
        queryParams['subject_id'] = subjectId;
      }

      final response = await _apiService.dio.get(
        ApiConstants.nextUpcomingSession,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final sessionData = response.data['data']['session'];

        // If session is null, no upcoming session
        if (sessionData == null) {
          debugPrint('✓ No upcoming session');
          return null;
        }

        final session = LiveSessionModel.fromJson(sessionData as Map<String, dynamic>);
        debugPrint('✓ Next upcoming session retrieved: ${session.title}');
        return session;
      }

      throw Exception('Failed to load upcoming session');
    } on DioException catch (e) {
      debugPrint('✗ Get upcoming session error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get list of live sessions with filters
  Future<List<LiveSessionModel>> getLiveSessions({
    String? status,
    String? subjectId,
    int limit = 10,
    bool upcomingOnly = false,
  }) async {
    try {
      debugPrint('=== DashboardService: Getting live sessions ===');

      final queryParams = <String, dynamic>{
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;
      if (subjectId != null) queryParams['subject_id'] = subjectId;
      if (upcomingOnly) queryParams['upcoming_only'] = true;

      final response = await _apiService.dio.get(
        ApiConstants.liveSessions,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final sessionsData = response.data['data']['sessions'] as List;
        final sessions = sessionsData
            .map((json) => LiveSessionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        debugPrint('✓ ${sessions.length} live sessions retrieved');
        return sessions;
      }

      throw Exception('Failed to load live sessions');
    } on DioException catch (e) {
      debugPrint('✗ Get live sessions error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get live session details by ID
  Future<LiveSessionModel> getSessionDetails(String sessionId) async {
    try {
      debugPrint('=== DashboardService: Getting session details ===');

      final response = await _apiService.dio.get(
        ApiConstants.liveSessionDetails(sessionId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final sessionData = response.data['data']['session'];
        final session = LiveSessionModel.fromJson(sessionData as Map<String, dynamic>);

        debugPrint('✓ Session details retrieved: ${session.title}');
        return session;
      }

      throw Exception('Failed to load session details');
    } on DioException catch (e) {
      debugPrint('✗ Get session details error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get user's subject selections
  /// Use isPrimary: true to get only the primary subject
  Future<List<SubjectSelectionModel>> getSubjectSelections({bool? isPrimary}) async {
    try {
      debugPrint('=== DashboardService: Getting subject selections ===');

      final queryParams = <String, dynamic>{};
      if (isPrimary != null) {
        queryParams['is_primary'] = isPrimary.toString();
      }

      final response = await _apiService.dio.get(
        ApiConstants.subjectSelections,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final selectionsData = response.data['data']['selections'] as List;
        final selections = selectionsData
            .map((json) => SubjectSelectionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        debugPrint('✓ ${selections.length} subject selections retrieved');
        return selections;
      }

      throw Exception('Failed to load subject selections');
    } on DioException catch (e) {
      debugPrint('✗ Get subject selections error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get available packages
  /// Use forceRefresh to bypass cache
  Future<List<PackageModel>> getPackages({
    String? subjectId,
    String? packageType,
    bool forceRefresh = false,
  }) async {
    try {
      debugPrint('=== DashboardService: Getting packages ===');

      // Check cache validity (1 hour TTL)
      if (!forceRefresh &&
          _cachedPackages != null &&
          _lastPackagesFetch != null &&
          _cachedPackagesSubjectId == subjectId &&
          DateTime.now().difference(_lastPackagesFetch!) < const Duration(hours: 1)) {
        debugPrint('✓ Returning cached packages (${_cachedPackages!.length} items)');
        return _cachedPackages!;
      }

      final queryParams = <String, dynamic>{};
      if (subjectId != null) queryParams['subject_id'] = subjectId;
      if (packageType != null) queryParams['package_type'] = packageType;

      final response = await _apiService.dio.get(
        ApiConstants.packages,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('Raw packages response: ${response.data}');
        final packagesData = response.data['data']['packages'] as List;
        debugPrint('Packages data list: $packagesData');
        final packages = packagesData
            .where((json) => json != null)
            .map((json) => PackageModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by display_order
        packages.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        // Update cache
        _cachedPackages = packages;
        _lastPackagesFetch = DateTime.now();
        _cachedPackagesSubjectId = subjectId;

        debugPrint('✓ ${packages.length} packages retrieved and cached');
        return packages;
      }

      throw Exception('Failed to load packages');
    } on DioException catch (e) {
      debugPrint('✗ Get packages error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get user's last watched videos
  Future<List<VideoModel>> getLastWatchedVideos({int limit = 1}) async {
    try {
      debugPrint('=== DashboardService: Getting last watched videos ===');

      final response = await _apiService.dio.get(
        ApiConstants.lastWatched,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final videosData = response.data['data']['videos'] as List;
        final videos = videosData
            .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
            .toList();

        debugPrint('✓ ${videos.length} last watched videos retrieved');
        return videos;
      }

      throw Exception('Failed to load last watched videos');
    } on DioException catch (e) {
      debugPrint('✗ Get last watched videos error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get faculty list
  /// Use forceRefresh to bypass cache
  Future<List<FacultyModel>> getFaculty({
    int limit = 10,
    String? specialization,
    bool forceRefresh = false,
  }) async {
    try {
      debugPrint('=== DashboardService: Getting faculty list ===');

      // Check cache validity (1 hour TTL)
      if (!forceRefresh &&
          _cachedFaculty != null &&
          _lastFacultyFetch != null &&
          DateTime.now().difference(_lastFacultyFetch!) < const Duration(hours: 1)) {
        debugPrint('✓ Returning cached faculty (${_cachedFaculty!.length} items)');

        // Apply limit to cached data
        if (_cachedFaculty!.length > limit) {
          return _cachedFaculty!.sublist(0, limit);
        }
        return _cachedFaculty!;
      }

      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (specialization != null) {
        queryParams['specialization'] = specialization;
      }

      final response = await _apiService.dio.get(
        ApiConstants.faculty,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final facultyData = response.data['data']['faculty'] as List;
        final faculty = facultyData
            .map((json) => FacultyModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Update cache
        _cachedFaculty = faculty;
        _lastFacultyFetch = DateTime.now();

        debugPrint('✓ ${faculty.length} faculty members retrieved and cached');
        return faculty;
      }

      throw Exception('Failed to load faculty');
    } on DioException catch (e) {
      debugPrint('✗ Get faculty error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get faculty details by ID
  Future<FacultyModel> getFacultyDetails(String facultyId) async {
    try {
      debugPrint('=== DashboardService: Getting faculty details ===');

      final response = await _apiService.dio.get(
        ApiConstants.facultyDetails(facultyId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final facultyData = response.data['data']['faculty'];
        final faculty = FacultyModel.fromJson(facultyData as Map<String, dynamic>);

        debugPrint('✓ Faculty details retrieved: ${faculty.name}');
        return faculty;
      }

      throw Exception('Failed to load faculty details');
    } on DioException catch (e) {
      debugPrint('✗ Get faculty details error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get series for a specific package
  Future<List<SeriesModel>> getPackageSeries(String packageId) async {
    try {
      debugPrint('=== DashboardService: Getting package series ===');
      debugPrint('Package ID: $packageId');

      final response = await _apiService.dio.get(
        '${ApiConstants.baseUrl}/packages/$packageId/series',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('Raw series response: ${response.data}');

        final seriesData = response.data['data']['series'] as List;
        debugPrint('Series data list: $seriesData');

        final series = seriesData
            .map((json) => SeriesModel.fromJson(json as Map<String, dynamic>))
            .toList();

        debugPrint('√ ${series.length} series retrieved');
        return series;
      } else {
        debugPrint('✗ Failed to retrieve series');
        throw Exception('Failed to retrieve series');
      }
    } on DioException catch (e) {
      debugPrint('✗ Get series error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get series details by ID
  Future<SeriesModel> getSeriesDetails(String seriesId) async {
    try {
      debugPrint('=== DashboardService: Getting series details ===');
      debugPrint('Series ID: $seriesId');

      final response = await _apiService.dio.get(
        '${ApiConstants.baseUrl}/series/$seriesId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final seriesData = response.data['data'];
        final series = SeriesModel.fromJson(seriesData as Map<String, dynamic>);

        debugPrint('√ Series details retrieved: ${series.title}');
        return series;
      }

      throw Exception('Failed to load series details');
    } on DioException catch (e) {
      debugPrint('✗ Get series details error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get modules for a specific series
  Future<List<ModuleModel>> getSeriesModules(String seriesId) async {
    try {
      debugPrint('=== DashboardService: Getting series modules ===');
      debugPrint('Series ID: $seriesId');

      final response = await _apiService.dio.get(
        '${ApiConstants.baseUrl}/series/$seriesId/modules',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final modulesData = response.data['data']['modules'] as List;
        final modules = modulesData
            .map((json) => ModuleModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by display_order
        modules.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        debugPrint('√ ${modules.length} modules retrieved');
        return modules;
      }

      throw Exception('Failed to load series modules');
    } on DioException catch (e) {
      debugPrint('✗ Get series modules error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get documents for a specific series
  Future<List<SeriesDocumentModel>> getSeriesDocuments(String seriesId) async {
    try {
      debugPrint('=== DashboardService: Getting series documents ===');
      debugPrint('Series ID: $seriesId');

      final response = await _apiService.dio.get(
        '${ApiConstants.baseUrl}/series/$seriesId/documents',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final documentsData = response.data['data']['documents'] as List;
        final documents = documentsData
            .map((json) => SeriesDocumentModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by display_order
        documents.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        debugPrint('√ ${documents.length} documents retrieved');
        return documents;
      }

      throw Exception('Failed to load series documents');
    } on DioException catch (e) {
      debugPrint('✗ Get series documents error: $e');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Clear all caches
  void clearCache() {
    debugPrint('=== DashboardService: Clearing cache ===');
    _cachedFaculty = null;
    _lastFacultyFetch = null;
    _cachedPackages = null;
    _lastPackagesFetch = null;
    _cachedPackagesSubjectId = null;
  }
}
