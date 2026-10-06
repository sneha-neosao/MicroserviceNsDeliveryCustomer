import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';

/// Represents a parsed physical delivery address with geographic coordinates.
class DeliveryLocationModel {
  final String formattedAddress;
  final String title;
  final String locality;
  final String city;
  final String postalCode;
  final double latitude;
  final double longitude;

  const DeliveryLocationModel({
    required this.formattedAddress,
    required this.title,
    required this.locality,
    required this.city,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'formattedAddress': formattedAddress,
        'title': title,
        'locality': locality,
        'city': city,
        'postalCode': postalCode,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory DeliveryLocationModel.fromJson(Map<String, dynamic> json) {
    return DeliveryLocationModel(
      formattedAddress: json['formattedAddress'] as String? ?? '',
      title: json['title'] as String? ?? 'Delivery Location',
      locality: json['locality'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Helper service for fetching current GPS position and resolving
/// addresses through the Google Maps Geocoding API.
class LocationService {
  static const String googleMapsApiKey =
      "AIzaSyAp9y2dQbI46aH-gilodzawnaT6VFjNOIY";

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  /// Requests permissions and retrieves the user's current GPS position.
  static Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w("Location services are disabled.");
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          logger.w("Location permissions are denied.");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        logger.w("Location permissions are permanently denied.");
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      logger.e("Error obtaining current position: $e");
      return null;
    }
  }

  /// Reverse geocodes coordinates (lat, lng) to a [DeliveryLocationModel]
  /// via Google Maps Geocoding API.
  static Future<DeliveryLocationModel?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleMapsApiKey";

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          final firstResult = results.first as Map<String, dynamic>;
          final formattedAddress =
              firstResult['formatted_address'] as String? ?? '';
          final components =
              firstResult['address_components'] as List<dynamic>? ?? [];

          String title = '';
          String locality = '';
          String city = '';
          String postalCode = '';

          for (final comp in components) {
            final c = comp as Map<String, dynamic>;
            final types = (c['types'] as List<dynamic>?)?.cast<String>() ?? [];
            final longName = c['long_name'] as String? ?? '';

            if (types.contains('sublocality') ||
                types.contains('sublocality_level_1') ||
                types.contains('neighborhood')) {
              if (title.isEmpty) title = longName;
              if (locality.isEmpty) locality = longName;
            } else if (types.contains('locality')) {
              city = longName;
              if (title.isEmpty) title = longName;
            } else if (types.contains('administrative_area_level_2')) {
              if (city.isEmpty) city = longName;
            } else if (types.contains('postal_code')) {
              postalCode = longName;
            }
          }

          if (title.isEmpty) {
            final parts = formattedAddress.split(',');
            title = parts.isNotEmpty ? parts.first.trim() : 'Location';
          }

          return DeliveryLocationModel(
            formattedAddress: formattedAddress,
            title: title,
            locality: locality,
            city: city,
            postalCode: postalCode,
            latitude: latitude,
            longitude: longitude,
          );
        }
      }
    } catch (e) {
      logger.e("Error reverse geocoding ($latitude, $longitude): $e");
    }
    return null;
  }

  /// Forward geocodes an address string query into matching locations.
  static Future<List<DeliveryLocationModel>> searchAddress(String query) async {
    final list = <DeliveryLocationModel>[];
    if (query.trim().isEmpty) return list;

    try {
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$googleMapsApiKey";

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];

        for (final res in results) {
          final item = res as Map<String, dynamic>;
          final formattedAddress = item['formatted_address'] as String? ?? '';
          final geometry = item['geometry'] as Map<String, dynamic>?;
          final location = geometry?['location'] as Map<String, dynamic>?;
          final lat = (location?['lat'] as num?)?.toDouble() ?? 0.0;
          final lng = (location?['lng'] as num?)?.toDouble() ?? 0.0;

          final parts = formattedAddress.split(',');
          final title = parts.isNotEmpty ? parts.first.trim() : formattedAddress;

          list.add(
            DeliveryLocationModel(
              formattedAddress: formattedAddress,
              title: title,
              locality: parts.length > 1 ? parts[1].trim() : '',
              city: parts.length > 2 ? parts[2].trim() : '',
              postalCode: '',
              latitude: lat,
              longitude: lng,
            ),
          );
        }
      }
    } catch (e) {
      logger.e("Error searching address '$query': $e");
    }
    return list;
  }
}
