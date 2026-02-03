import 'package:flutter/foundation.dart';
import 'package:pgme/core/models/live_session_model.dart';
import 'package:pgme/core/models/package_model.dart';
import 'package:pgme/core/models/video_model.dart';
import 'package:pgme/core/models/faculty_model.dart';
import 'package:pgme/core/models/subject_selection_model.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/services/storage_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();
  final StorageService _storageService = StorageService();

  // State
  String? _userName;
  SubjectSelectionModel? _primarySubject;
  List<LiveSessionModel> _upcomingSessions = [];
  List<PackageModel> _packages = [];
  VideoModel? _lastWatchedVideo;
  List<FacultyModel> _facultyList = [];

  // Loading states (per section)
  bool _isLoadingSession = false;
  bool _isLoadingSubjects = false;
  bool _isLoadingContent = false;
  bool _isLoadingFaculty = false;
  bool _isRefreshing = false;

  // Error states (per section)
  String? _sessionError;
  String? _subjectError;
  String? _contentError;
  String? _facultyError;

  // Purchase status (determines For You vs What We Offer)
  bool? _hasActivePurchase;

  // Getters
  String? get userName => _userName;
  SubjectSelectionModel? get primarySubject => _primarySubject;
  List<LiveSessionModel> get upcomingSessions => _upcomingSessions;
  List<PackageModel> get packages => _packages;
  VideoModel? get lastWatchedVideo => _lastWatchedVideo;
  List<FacultyModel> get facultyList => _facultyList;

  bool get isLoadingSession => _isLoadingSession;
  bool get isLoadingSubjects => _isLoadingSubjects;
  bool get isLoadingContent => _isLoadingContent;
  bool get isLoadingFaculty => _isLoadingFaculty;
  bool get isRefreshing => _isRefreshing;

  String? get sessionError => _sessionError;
  String? get subjectError => _subjectError;
  String? get contentError => _contentError;
  String? get facultyError => _facultyError;

  bool? get hasActivePurchase => _hasActivePurchase;

  /// Main dashboard load method
  /// Loads all sections in parallel
  Future<void> loadDashboard() async {
    debugPrint('=== DashboardProvider: Loading dashboard ===');

    // Get user name from storage
    _userName = await _getUserName();

    // Load all sections in parallel (don't stop on first error)
    await Future.wait([
      _loadPrimarySubject(),
      _loadUpcomingSession(),
      _loadFacultyList(),
      _loadContentSection(),
    ], eagerError: false);

    notifyListeners();
    debugPrint('✓ Dashboard loaded');
  }

  /// Refresh dashboard (for pull-to-refresh)
  Future<void> refresh() async {
    debugPrint('=== DashboardProvider: Refreshing dashboard ===');
    _isRefreshing = true;
    notifyListeners();

    await loadDashboard();

    _isRefreshing = false;
    notifyListeners();
    debugPrint('✓ Dashboard refreshed');
  }

  /// Get user name from storage or user model
  Future<String> _getUserName() async {
    try {
      // Try to get user ID from storage and fetch profile if needed
      final userId = await _storageService.getUserId();
      if (userId != null && userId.isNotEmpty) {
        // For now, return a default greeting
        // In future, you could fetch user profile here if needed
        return 'User';
      }
      return 'User';
    } catch (e) {
      debugPrint('✗ Error getting user name: $e');
      return 'User';
    }
  }

  /// Load primary subject
  Future<void> _loadPrimarySubject() async {
    _isLoadingSubjects = true;
    _subjectError = null;

    try {
      debugPrint('Loading primary subject...');
      final selections = await _dashboardService.getSubjectSelections(isPrimary: true);

      if (selections.isNotEmpty) {
        _primarySubject = selections.first;
        debugPrint('✓ Primary subject loaded: ${_primarySubject!.subjectName}');
      } else {
        _primarySubject = null;
        debugPrint('⚠ No primary subject found');
      }
    } catch (e) {
      _subjectError = e.toString().replaceAll('Exception: ', '');
      debugPrint('✗ Error loading primary subject: $_subjectError');
    } finally {
      _isLoadingSubjects = false;
    }
  }

  /// Load upcoming live sessions (multiple for carousel)
  Future<void> _loadUpcomingSession() async {
    _isLoadingSession = true;
    _sessionError = null;

    try {
      debugPrint('Loading upcoming sessions...');

      // Fetch multiple upcoming sessions (limit 5 for carousel)
      final sessions = await _dashboardService.getLiveSessions(
        upcomingOnly: true,
        subjectId: _primarySubject?.subjectId,
        limit: 5,
      );

      _upcomingSessions = sessions;

      if (sessions.isNotEmpty) {
        debugPrint('✓ ${sessions.length} upcoming sessions loaded');
      } else {
        debugPrint('⚠ No upcoming sessions');
      }
    } catch (e) {
      _sessionError = e.toString().replaceAll('Exception: ', '');
      debugPrint('✗ Error loading upcoming sessions: $_sessionError');
    } finally {
      _isLoadingSession = false;
    }
  }

  /// Load faculty list
  Future<void> _loadFacultyList() async {
    _isLoadingFaculty = true;
    _facultyError = null;

    try {
      debugPrint('Loading faculty list...');

      _facultyList = await _dashboardService.getFaculty(limit: 10);

      debugPrint('✓ Faculty list loaded: ${_facultyList.length} members');
    } catch (e) {
      _facultyError = e.toString().replaceAll('Exception: ', '');
      debugPrint('✗ Error loading faculty: $_facultyError');
    } finally {
      _isLoadingFaculty = false;
    }
  }

  /// Load content section (For You or What We Offer)
  /// Determines purchase status and loads appropriate content
  Future<void> _loadContentSection() async {
    _isLoadingContent = true;
    _contentError = null;

    try {
      debugPrint('Loading content section...');

      // Try to get last watched videos to determine purchase status
      try {
        final videos = await _dashboardService.getLastWatchedVideos(limit: 1);

        if (videos.isNotEmpty) {
          // User has watch history = has active purchase
          _hasActivePurchase = true;
          _lastWatchedVideo = videos.first;
          debugPrint('✓ User has active purchase - showing For You section');
          debugPrint('  Last watched: ${_lastWatchedVideo!.title}');
        } else {
          // No watch history = no active purchase
          _hasActivePurchase = false;
          _lastWatchedVideo = null;
          debugPrint('⚠ No watch history - user likely has no purchase');
        }
      } catch (e) {
        // Error getting watch history - assume no purchase
        _hasActivePurchase = false;
        _lastWatchedVideo = null;
        debugPrint('⚠ Error getting watch history (assuming no purchase): $e');
      }

      // If no active purchase, load packages for What We Offer section
      if (_hasActivePurchase == false) {
        try {
          debugPrint('Loading packages for What We Offer section...');
          // Load packages with or without subject filter
          _packages = await _dashboardService.getPackages(
            subjectId: _primarySubject?.subjectId,
          );
          debugPrint('✓ ${_packages.length} packages loaded');
        } catch (e) {
          _contentError = e.toString().replaceAll('Exception: ', '');
          debugPrint('✗ Error loading packages: $_contentError');
        }
      }
    } catch (e) {
      _contentError = e.toString().replaceAll('Exception: ', '');
      debugPrint('✗ Error loading content section: $_contentError');
    } finally {
      _isLoadingContent = false;
    }
  }

  /// Retry loading primary subject
  Future<void> retrySubject() async {
    debugPrint('=== Retrying primary subject ===');
    await _loadPrimarySubject();
    notifyListeners();
  }

  /// Retry loading upcoming session
  Future<void> retrySession() async {
    debugPrint('=== Retrying upcoming session ===');
    await _loadUpcomingSession();
    notifyListeners();
  }

  /// Retry loading faculty list
  Future<void> retryFaculty() async {
    debugPrint('=== Retrying faculty list ===');
    await _loadFacultyList();
    notifyListeners();
  }

  /// Retry loading content section
  Future<void> retryContent() async {
    debugPrint('=== Retrying content section ===');
    await _loadContentSection();
    notifyListeners();
  }

  /// Clear all dashboard data
  void clearDashboard() {
    debugPrint('=== DashboardProvider: Clearing dashboard ===');

    _userName = null;
    _primarySubject = null;
    _upcomingSessions = [];
    _packages = [];
    _lastWatchedVideo = null;
    _facultyList = [];

    _isLoadingSession = false;
    _isLoadingSubjects = false;
    _isLoadingContent = false;
    _isLoadingFaculty = false;
    _isRefreshing = false;

    _sessionError = null;
    _subjectError = null;
    _contentError = null;
    _facultyError = null;

    _hasActivePurchase = null;

    _dashboardService.clearCache();

    notifyListeners();
    debugPrint('✓ Dashboard cleared');
  }
}
