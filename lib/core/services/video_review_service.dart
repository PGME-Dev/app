import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/services/api_service.dart';

class VideoReviewService {
  final ApiService _apiService = ApiService();

  /// Get the current user's own review for a video.
  /// Returns null if no review exists yet (not a 404).
  /// Returns a map with: rating, rating_submitted_at, feedback, feedback_submitted_at
  Future<Map<String, dynamic>?> getMyReview(String videoId) async {
    try {
      debugPrint('VideoReviewService: fetching review for video=$videoId');
      final response = await _apiService.dio.get(
        ApiConstants.videoMyReview(videoId),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['review'] as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('VideoReviewService.getMyReview error: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  /// Submit a rating (1–5) for a video.
  /// Throws if rating already submitted.
  Future<Map<String, dynamic>> submitRating(String videoId, int rating) async {
    try {
      debugPrint('VideoReviewService: submitting rating=$rating for video=$videoId');
      final response = await _apiService.dio.post(
        ApiConstants.submitVideoRating(videoId),
        data: {'rating': rating},
      );
      if (response.data['success'] == true) {
        return response.data['data']['review'] as Map<String, dynamic>;
      }
      throw Exception(response.data['message'] ?? 'Failed to submit rating');
    } on DioException catch (e) {
      debugPrint('VideoReviewService.submitRating error: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  /// Submit feedback text for a video.
  /// Throws if feedback already submitted.
  Future<Map<String, dynamic>> submitFeedback(String videoId, String feedback) async {
    try {
      debugPrint('VideoReviewService: submitting feedback for video=$videoId');
      final response = await _apiService.dio.post(
        ApiConstants.submitVideoFeedback(videoId),
        data: {'feedback': feedback},
      );
      if (response.data['success'] == true) {
        return response.data['data']['review'] as Map<String, dynamic>;
      }
      throw Exception(response.data['message'] ?? 'Failed to submit feedback');
    } on DioException catch (e) {
      debugPrint('VideoReviewService.submitFeedback error: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }
}
