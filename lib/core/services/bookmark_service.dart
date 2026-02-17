import 'package:dio/dio.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/services/api_service.dart';

class BookmarkService {
  final ApiService _apiService = ApiService();

  /// Get all bookmarks for a document
  Future<List<Map<String, dynamic>>> getBookmarks(String documentId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.documentBookmarks,
        queryParameters: {'document_id': documentId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final bookmarks = response.data['data']['bookmarks'] as List;
        return bookmarks.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to fetch bookmarks: ${e.toString()}');
    }
  }

  /// Add bookmark to a page
  Future<Map<String, dynamic>> addBookmark({
    required String documentId,
    required int pageNumber,
    String? note,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.documentBookmarks,
        data: {
          'document_id': documentId,
          'page_number': pageNumber,
          if (note != null) 'note': note,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(response.data['message'] ?? 'Failed to add bookmark');
    } on DioException catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to add bookmark: ${e.toString()}');
    }
  }

  /// Delete a bookmark
  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      final response = await _apiService.dio.delete(
        ApiConstants.documentBookmark(bookmarkId),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Failed to delete bookmark');
      }
    } on DioException catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to delete bookmark: ${e.toString()}');
    }
  }

  /// Update bookmark note
  Future<Map<String, dynamic>> updateBookmarkNote(
      String bookmarkId, String? note) async {
    try {
      final response = await _apiService.dio.put(
        ApiConstants.documentBookmarkNote(bookmarkId),
        data: {'note': note},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(
          response.data['message'] ?? 'Failed to update bookmark note');
    } on DioException catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to update bookmark note: ${e.toString()}');
    }
  }
}
