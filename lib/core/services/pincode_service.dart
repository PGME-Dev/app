import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PincodeResult {
  final String city;
  final String state;
  final String district;

  PincodeResult({
    required this.city,
    required this.state,
    required this.district,
  });
}

class PincodeService {
  final Dio _dio = Dio();

  /// Lookup pincode details from India Post API (free, no auth)
  /// Returns city, state, and district for valid 6-digit pincodes.
  Future<PincodeResult?> lookupPincode(String pincode) async {
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(pincode)) return null;

    try {
      final response = await _dio.get(
        'https://api.postalpincode.in/pincode/$pincode',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List;
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final postOffices = data[0]['PostOffice'] as List?;
          if (postOffices != null && postOffices.isNotEmpty) {
            final first = postOffices[0] as Map<String, dynamic>;
            return PincodeResult(
              city: first['Block'] as String? ??
                  first['District'] as String? ??
                  '',
              state: first['State'] as String? ?? '',
              district: first['District'] as String? ?? '',
            );
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('PincodeService: Error looking up pincode $pincode: $e');
      return null;
    }
  }
}
