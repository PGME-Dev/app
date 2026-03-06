import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core_ios/constants/api_constants.dart';
import 'package:pgme/core_ios/models/ebook_access_model.dart';
import 'package:pgme/core_ios/services/api_service.dart';

class EbookAccessService {
  final ApiService _apiService = ApiService();

  /// Get user's accessible ebooks
  Future<List<EbookAccessModel>> getUserAccessibleEbooks() async {
    try {
      debugPrint('=== EbookAccessService: Getting accessible ebooks ===');

      final response = await _apiService.dio.get(ApiConstants.activeUserReads);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final ebooksList = data['ebooks'] as List;
        return ebooksList
            .map((json) => EbookAccessModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to load accessible ebooks');
    } on DioException catch (e) {
      debugPrint('DioException getting accessible ebooks: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting accessible ebooks: $e');
      rethrow;
    }
  }

  /// Get ebook view URL (presigned URL for reading)
  Future<Map<String, dynamic>> getEbookViewUrl(String bookId) async {
    try {
      debugPrint('=== EbookAccessService: Getting view URL for book $bookId ===');

      final response = await _apiService.dio.get(
        ApiConstants.activeReadViewUrl(bookId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception('Failed to get ebook URL');
    } on DioException catch (e) {
      debugPrint('DioException getting ebook view URL: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting ebook view URL: $e');
      rethrow;
    }
  }
}
