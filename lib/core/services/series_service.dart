import 'package:dio/dio.dart';
import 'package:pgme/core/models/series_model.dart';
import 'package:pgme/core/services/api_service.dart';
import 'package:pgme/core/constants/api_constants.dart';

class SeriesService {
  final ApiService _apiService = ApiService();

  /// Get the first practical package ID
  Future<String> getFirstPracticalPackage() async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.packages,
        queryParameters: {'package_type': 'Practical'},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> packages = response.data['data']['packages'];
        if (packages.isEmpty) {
          throw Exception('No practical packages found');
        }
        return packages[0]['package_id'].toString();
      }

      throw Exception('Failed to fetch packages');
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Unknown error';
        throw Exception('API Error: $message (${e.response?.statusCode})');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch packages: $e');
    }
  }

  /// Get all series for a package
  /// [packageId] - The package ID
  Future<List<SeriesModel>> getPackageSeries(String packageId) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.packageSeries(packageId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> seriesJson = response.data['data']['series'];
        return seriesJson.map((json) => SeriesModel.fromJson(json)).toList();
      }

      throw Exception('Failed to load series: Invalid response');
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Unknown error';
        throw Exception('API Error: $message (${e.response?.statusCode})');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to load series: $e');
    }
  }
}
