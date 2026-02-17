import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/book_model.dart';
import 'package:pgme/core/services/api_service.dart';

class BookService {
  final ApiService _apiService = ApiService();

  /// Get all available books with optional filters
  Future<BooksResponse> getBooks({
    String? category,
    String? subjectId,
    String? search,
    int page = 1,
    int limit = 20,
    String? sort,
    bool? ebook,
  }) async {
    try {
      debugPrint('=== BookService: Getting books ===');

      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (subjectId != null) queryParams['subject_id'] = subjectId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      queryParams['page'] = page;
      queryParams['limit'] = limit;
      if (sort != null) queryParams['sort'] = sort;
      if (ebook != null) queryParams['ebook'] = ebook;

      final response = await _apiService.dio.get(
        ApiConstants.books,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BooksResponse.fromJson(data);
      }

      throw Exception('Failed to load books');
    } on DioException catch (e) {
      debugPrint('DioException getting books: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting books: $e');
      rethrow;
    }
  }

  /// Get book details by ID
  Future<BookModel> getBookById(String bookId) async {
    try {
      debugPrint('=== BookService: Getting book $bookId ===');

      final response = await _apiService.dio.get(
        ApiConstants.bookDetails(bookId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final bookData = response.data['data']['book'] as Map<String, dynamic>;
        return BookModel.fromJson(bookData);
      }

      throw Exception('Failed to load book details');
    } on DioException catch (e) {
      debugPrint('DioException getting book: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting book: $e');
      rethrow;
    }
  }

  /// Search books by query
  Future<List<BookModel>> searchBooks(String query, {int limit = 10}) async {
    try {
      debugPrint('=== BookService: Searching books for "$query" ===');

      if (query.trim().length < 2) {
        return [];
      }

      final response = await _apiService.dio.get(
        ApiConstants.searchBooks,
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final booksData = response.data['data']['books'] as List;
        return booksData
            .map((json) => BookModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('DioException searching books: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error searching books: $e');
      return [];
    }
  }

  /// Check book stock availability
  Future<Map<String, dynamic>> checkStock(String bookId, {int quantity = 1}) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConstants.bookDetails(bookId)}/stock',
        queryParameters: {'quantity': quantity},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception('Failed to check stock');
    } catch (e) {
      debugPrint('Error checking stock: $e');
      rethrow;
    }
  }

  /// Get book categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.bookCategories,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final categories = response.data['data']['categories'] as List;
        return categories.cast<String>();
      }

      return [];
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  /// Get shipping cost from backend
  Future<int> getShippingCost() async {
    try {
      debugPrint('=== BookService: Getting shipping cost ===');

      final response = await _apiService.dio.get(
        '/books/config/shipping-cost',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['shipping_cost'] as int;
      }

      throw Exception('Failed to load shipping cost');
    } on DioException catch (e) {
      debugPrint('DioException getting shipping cost: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting shipping cost: $e');
      rethrow;
    }
  }
}
