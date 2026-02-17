import 'package:dio/dio.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/services/api_service.dart';

class HighlightService {
  final ApiService _apiService = ApiService();

  /// Get all highlights for a document
  Future<List<Map<String, dynamic>>> getHighlights(String documentId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.documentHighlights,
        queryParameters: {'document_id': documentId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final highlights = response.data['data']['highlights'] as List;
        return highlights.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to fetch highlights: ${e.toString()}');
    }
  }

  /// Add a highlight to a document
  Future<Map<String, dynamic>> addHighlight({
    required String documentId,
    required int pageNumber,
    required int startOffset,
    required int endOffset,
    required String highlightedText,
    String color = 'yellow',
    String? note,
    List<Map<String, dynamic>>? boundsData,
    String annotationType = 'highlight',
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.documentHighlights,
        data: {
          'document_id': documentId,
          'page_number': pageNumber,
          'start_offset': startOffset,
          'end_offset': endOffset,
          'highlighted_text': highlightedText,
          'color': color,
          'annotation_type': annotationType,
          if (note != null) 'note': note,
          if (boundsData != null) 'bounds_data': boundsData,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(response.data['message'] ?? 'Failed to add highlight');
    } on DioException catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to add highlight: ${e.toString()}');
    }
  }

  /// Update a highlight's note
  Future<Map<String, dynamic>> updateHighlightNote(
      String highlightId, String? note) async {
    try {
      final response = await _apiService.dio.put(
        ApiConstants.documentHighlightNote(highlightId),
        data: {'note': note},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(response.data['message'] ?? 'Failed to update note');
    } on DioException catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to update note: ${e.toString()}');
    }
  }

  /// Delete a highlight
  Future<void> deleteHighlight(String highlightId) async {
    try {
      final response = await _apiService.dio.delete(
        ApiConstants.documentHighlight(highlightId),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete highlight');
      }
    } on DioException catch (e) {
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to delete highlight: ${e.toString()}');
    }
  }
}
