import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/subject_model.dart';
import 'package:pgme/core/services/api_service.dart';

class OnboardingService {
  final ApiService _apiService = ApiService();

  /// Get all active subjects
  Future<List<SubjectModel>> getSubjects() async {
    try {
      debugPrint('=== Fetching Subjects ===');
      debugPrint('Endpoint: ${ApiConstants.baseUrl}${ApiConstants.subjects}');

      final response = await _apiService.dio.get(
        ApiConstants.subjects,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final subjectsData = response.data['data']['subjects'] as List;
        final subjects = subjectsData
            .map((json) => SubjectModel.fromJson(json))
            .toList();

        // Sort by display_order
        subjects.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        debugPrint('✓ Fetched ${subjects.length} subjects');
        return subjects;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch subjects');
      }
    } on DioException catch (e) {
      debugPrint('Fetch subjects DioException: ${e.response?.data}');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('Fetch subjects error: $e');
      throw Exception('Failed to fetch subjects: ${e.toString()}');
    }
  }

  /// Update subject selection
  Future<bool> updateSubjectSelection(String subjectId) async {
    try {
      debugPrint('=== Updating Subject Selection ===');
      debugPrint('Subject ID: $subjectId');
      debugPrint('Endpoint: ${ApiConstants.baseUrl}${ApiConstants.subjectSelection}');

      final response = await _apiService.dio.put(
        ApiConstants.subjectSelection,
        data: {
          'subject_id': subjectId,
          'is_primary': true,
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✓ Subject selection updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update subject selection');
      }
    } on DioException catch (e) {
      debugPrint('Update subject DioException: ${e.response?.data}');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('Update subject error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Mark onboarding as complete
  Future<bool> completeOnboarding() async {
    try {
      debugPrint('=== Completing Onboarding ===');

      final response = await _apiService.dio.put(
        ApiConstants.onboardingComplete,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✓ Onboarding completed successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to complete onboarding');
      }
    } on DioException catch (e) {
      debugPrint('Complete onboarding DioException: ${e.response?.data}');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('Complete onboarding error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
