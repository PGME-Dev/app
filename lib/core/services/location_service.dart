import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final Dio _dio = Dio();

  /// Check and request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// Get current device location (latitude, longitude)
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permission status
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied permanently');
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      debugPrint(
          'Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Fetch address from OpenStreetMap Nominatim API using coordinates
  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': latitude,
          'lon': longitude,
          'zoom': 18,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent':
                'PGMEApp/1.0', // Nominatim requires a user agent
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          // Build a readable address from components
          final components = <String>[];

          // Add relevant address components
          if (address['house_number'] != null) {
            components.add(address['house_number'].toString());
          }
          if (address['road'] != null) {
            components.add(address['road'].toString());
          }
          if (address['suburb'] != null) {
            components.add(address['suburb'].toString());
          }
          if (address['city'] != null) {
            components.add(address['city'].toString());
          }
          if (address['county'] != null) {
            components.add(address['county'].toString());
          }
          if (address['state'] != null) {
            components.add(address['state'].toString());
          }
          if (address['postcode'] != null) {
            components.add(address['postcode'].toString());
          }

          final fullAddress = components.join(', ');
          debugPrint('Fetched address: $fullAddress');
          return fullAddress.isNotEmpty ? fullAddress : null;
        }
      }

      throw Exception('Failed to fetch address');
    } on DioException catch (e) {
      debugPrint('Network error fetching address: $e');
      return null;
    } catch (e) {
      debugPrint('Error fetching address: $e');
      return null;
    }
  }

  /// Complete method: get location and fetch address
  Future<String?> getAddressFromCurrentLocation() async {
    try {
      debugPrint('=== LocationService: Fetching address from current location ===');

      final position = await getCurrentLocation();
      if (position == null) {
        throw Exception('Failed to get current location');
      }

      final address =
          await getAddressFromCoordinates(position.latitude, position.longitude);
      return address;
    } catch (e) {
      debugPrint('Error getting address from current location: $e');
      return null;
    }
  }
}
