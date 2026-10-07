import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';

/// Represents a parsed physical delivery address with geographic coordinates.
class DeliveryLocationModel {
  final String formattedAddress;
  final String title;
  final String addressLine;
  final String locality;
  final String city;
  final String postalCode;
  final double latitude;
  final double longitude;

  const DeliveryLocationModel({
    required this.formattedAddress,
    required this.title,
    this.addressLine = '',
    required this.locality,
    required this.city,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'formattedAddress': formattedAddress,
        'title': title,
        'addressLine': addressLine,
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
      addressLine: json['addressLine'] as String? ?? '',
      locality: json['locality'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryLocationModel &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          formattedAddress == other.formattedAddress &&
          addressLine == other.addressLine &&
          locality == other.locality &&
          city == other.city &&
          postalCode == other.postalCode;

  @override
  int get hashCode => Object.hash(
        latitude,
        longitude,
        formattedAddress,
        addressLine,
        locality,
        city,
        postalCode,
      );
}

/// Helper service for fetching high-accuracy current GPS position and resolving
/// addresses through Native Geocoding, Google Geocoding, and OpenStreetMap Nominatim.
class LocationService {
  static const String googleMapsApiKey =
      "AIzaSyAp9y2dQbI46aH-gilodzawnaT6VFjNOIY";

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  /// Requests permissions and retrieves the user's live current GPS position
  /// with high accuracy.
  static Future<Position?> getCurrentPosition() async {
    try {
      // 1. Verify location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w("Location services are disabled, requesting settings...");
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          logger.w("Location services remain disabled by user.");
          return null;
        }
      }

      // 2. Check and request location permissions
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

      // 3. Acquire live position with high accuracy
      Position? freshPosition;
      try {
        LocationSettings settings;
        if (defaultTargetPlatform == TargetPlatform.android) {
          settings = AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
            forceLocationManager: false,
            intervalDuration: const Duration(seconds: 1),
            timeLimit: const Duration(seconds: 15),
          );
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          settings = AppleSettings(
            accuracy: LocationAccuracy.best,
            activityType: ActivityType.other,
            pauseLocationUpdatesAutomatically: false,
            timeLimit: const Duration(seconds: 15),
          );
        } else {
          settings = const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 15),
          );
        }

        freshPosition = await Geolocator.getCurrentPosition(
          locationSettings: settings,
        );
      } catch (e) {
        logger.w("Fused position timed out or failed: $e, trying hardware GPS provider...");
      }

      // 4. Fallback to hardware GPS directly if FusedLocationProvider failed on Android
      if (freshPosition == null && defaultTargetPlatform == TargetPlatform.android) {
        try {
          freshPosition = await Geolocator.getCurrentPosition(
            locationSettings: AndroidSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 0,
              forceLocationManager: true, // Bypass Google Play Services to direct GPS
              intervalDuration: const Duration(seconds: 1),
              timeLimit: const Duration(seconds: 12),
            ),
          );
        } catch (e) {
          logger.w("Direct hardware GPS position attempt failed: $e");
        }
      }

      if (freshPosition != null) {
        logger.i("Obtained live accurate GPS position: ${freshPosition.latitude}, ${freshPosition.longitude} (Accuracy: ${freshPosition.accuracy}m)");
        return freshPosition;
      }

      // 5. Fallback to last known position only if fresh acquisition failed
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        logger.i("Falling back to last known position: ${lastKnown.latitude}, ${lastKnown.longitude}");
        return lastKnown;
      }

      return null;
    } catch (e) {
      logger.e("Error obtaining current position: $e");
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Reverse geocodes coordinates (lat, lng) to a [DeliveryLocationModel].
  /// Strategy:
  /// 1. Native device geocoder (`package:geocoding`) for device-accurate lane/street/area.
  /// 2. Google Maps Geocoding API if configured.
  /// 3. OpenStreetMap Nominatim with zoom=18 building/lane level granularity.
  static Future<DeliveryLocationModel?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // 1. Attempt Google Maps Geocoding HTTP API
    try {
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleMapsApiKey";

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as String? ?? '';
        final results = data['results'] as List<dynamic>?;

        if (status == 'OK' && results != null && results.isNotEmpty) {
          final firstResult = results.first as Map<String, dynamic>;
          final formattedAddress =
              firstResult['formatted_address'] as String? ?? '';
          final components =
              firstResult['address_components'] as List<dynamic>? ?? [];

          String streetNumber = '';
          String premise = '';
          String subpremise = '';
          String route = '';
          String lane = '';
          String neighborhood = '';
          String sublocality = '';
          String city = '';
          String postalCode = '';

          for (final comp in components) {
            final c = comp as Map<String, dynamic>;
            final types = (c['types'] as List<dynamic>?)?.cast<String>() ?? [];
            final longName = c['long_name'] as String? ?? '';

            if (types.contains('street_number')) {
              streetNumber = longName;
            } else if (types.contains('premise')) {
              premise = longName;
            } else if (types.contains('subpremise')) {
              subpremise = longName;
            } else if (types.contains('route')) {
              route = longName;
            } else if (types.contains('sublocality_level_2')) {
              lane = longName;
            } else if (types.contains('neighborhood')) {
              neighborhood = longName;
            } else if (types.contains('sublocality') ||
                types.contains('sublocality_level_1') ||
                types.contains('point_of_interest')) {
              if (sublocality.isEmpty) sublocality = longName;
            } else if (types.contains('locality')) {
              city = longName;
            } else if (types.contains('administrative_area_level_2')) {
              if (city.isEmpty) city = longName;
            } else if (types.contains('postal_code')) {
              postalCode = longName;
            }
          }

          final bldgNum = [subpremise, premise, streetNumber]
              .where((s) => s.isNotEmpty)
              .join('/');
          final googleAddressParts = <String>[];
          if (bldgNum.isNotEmpty) {
            googleAddressParts.add('Building No. $bldgNum');
          }
          if (lane.isNotEmpty) googleAddressParts.add(lane);
          if (route.isNotEmpty) googleAddressParts.add(route);
          if (neighborhood.isNotEmpty &&
              !googleAddressParts.contains(neighborhood)) {
            googleAddressParts.add(neighborhood);
          }

          final addressLine = googleAddressParts.isNotEmpty
              ? googleAddressParts.join(', ')
              : formattedAddress.split(',').first.trim();

          final area = sublocality.isNotEmpty ? sublocality : neighborhood;

          String title = '';
          if (bldgNum.isNotEmpty && route.isNotEmpty) {
            title = 'Building No. $bldgNum, $route';
          } else if (lane.isNotEmpty && area.isNotEmpty) {
            title = '$lane, $area';
          } else if (route.isNotEmpty && lane.isNotEmpty) {
            title = '$lane, $route';
          } else if (route.isNotEmpty && area.isNotEmpty) {
            title = '$route, $area';
          } else if (route.isNotEmpty) {
            title = route;
          } else if (area.isNotEmpty) {
            title = area;
          } else {
            title = formattedAddress.split(',').first.trim();
          }

          if (postalCode.isEmpty) {
            final match = RegExp(r'\b\d{6}\b').firstMatch(formattedAddress);
            if (match != null) postalCode = match.group(0)!;
          }

          return DeliveryLocationModel(
            formattedAddress: formattedAddress,
            title: title,
            addressLine: addressLine,
            locality: area,
            city: city,
            postalCode: postalCode,
            latitude: latitude,
            longitude: longitude,
          );
        }
      }
    } catch (e) {
      logger.w("Google Geocoding unavailable ($latitude, $longitude): $e");
    }

    // 2. High-precision OpenStreetMap Nominatim reverse geocoding with zoom=18 building/lane accuracy
    return await _reverseGeocodeNominatim(latitude, longitude);
  }

  static Future<DeliveryLocationModel?> _reverseGeocodeNominatim(
    double latitude,
    double longitude,
  ) async {
    try {
      final url =
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&addressdetails=1&zoom=18&extratags=1&namedetails=1";

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'NSDeliveryCustomerApp/1.0 (contact@nsdelivery.com)',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data is String
                ? jsonDecode(response.data as String) as Map<String, dynamic>
                : null);

        if (data != null) {
          final displayName = data['display_name'] as String? ?? '';
          final address = data['address'] as Map<String, dynamic>? ?? {};

          final name = data['name'] as String? ?? '';
          final houseNumber = (address['house_number'] ??
                  address['housenumber'] ??
                  address['building_number'] ??
                  address['door_number'] ??
                  address['plot_number'] ??
                  address['flat'] ??
                  '')
              .toString()
              .trim();
          final building = (address['building'] ??
                  address['apartments'] ??
                  address['apartment'] ??
                  address['residential'] ??
                  address['complex'] ??
                  address['society'] ??
                  '')
              .toString()
              .trim();
          final amenity = (address['amenity'] ??
                  address['shop'] ??
                  address['office'] ??
                  address['commercial'] ??
                  address['place'] ??
                  address['hotel'] ??
                  address['hospital'] ??
                  '')
              .toString()
              .trim();
          final lane = (address['lane'] ??
                  address['alley'] ??
                  address['cross_street'] ??
                  address['footway'] ??
                  address['pedestrian'] ??
                  address['path'] ??
                  '')
              .toString()
              .trim();
          final road = (address['road'] ??
                  address['street'] ??
                  address['highway'] ??
                  '')
              .toString()
              .trim();
          final layout = (address['neighbourhood'] ??
                  address['colony'] ??
                  address['layout'] ??
                  address['sector'] ??
                  address['block'] ??
                  '')
              .toString()
              .trim();
          final suburb = (address['suburb'] ??
                  address['quarter'] ??
                  address['city_district'] ??
                  address['subdivision'] ??
                  address['village'] ??
                  address['hamlet'] ??
                  '')
              .toString()
              .trim();
          final city = (address['city'] ??
                  address['town'] ??
                  address['village'] ??
                  address['municipality'] ??
                  address['county'] ??
                  '')
              .toString()
              .trim();
          final postcode = (address['postcode'] ?? '').toString().trim();

          // 1. Build detailed Address Line (Building Number, Society, Lane & Street)
          final addressLineParts = <String>[];
          if (houseNumber.isNotEmpty) {
            if (houseNumber.toLowerCase().contains('no') ||
                houseNumber.toLowerCase().contains('flat') ||
                houseNumber.toLowerCase().contains('plot') ||
                houseNumber.toLowerCase().contains('house') ||
                houseNumber.toLowerCase().contains('bldg')) {
              addressLineParts.add(houseNumber);
            } else {
              addressLineParts.add('Building No. $houseNumber');
            }
          }
          if (building.isNotEmpty && !addressLineParts.contains(building)) {
            addressLineParts.add(building);
          }
          if (amenity.isNotEmpty &&
              amenity != road &&
              amenity != building &&
              !addressLineParts.contains(amenity)) {
            addressLineParts.add(amenity);
          }
          if (lane.isNotEmpty && !addressLineParts.contains(lane)) {
            addressLineParts.add(lane);
          }
          if (road.isNotEmpty && !addressLineParts.contains(road)) {
            addressLineParts.add(road);
          }
          if (layout.isNotEmpty &&
              !addressLineParts.contains(layout) &&
              addressLineParts.length < 3) {
            addressLineParts.add(layout);
          }

          var addressLine = addressLineParts.join(', ');
          if (addressLine.isEmpty) {
            if (name.isNotEmpty) {
              addressLine = name;
            } else if (displayName.isNotEmpty) {
              final segments = displayName.split(',');
              addressLine = segments.isNotEmpty
                  ? segments.take(2).map((e) => e.trim()).join(', ')
                  : '';
            }
          }

          // 2. Build Landmark / Area
          var landmark = '';
          if (layout.isNotEmpty && suburb.isNotEmpty && layout != suburb) {
            landmark = '$layout, $suburb';
          } else if (suburb.isNotEmpty) {
            landmark = suburb;
          } else if (layout.isNotEmpty) {
            landmark = layout;
          } else if (address['residential'] != null) {
            landmark = address['residential'] as String;
          }

          // 3. Meaningful Title (Lane & Area / Road & Area)
          String title = '';
          if (lane.isNotEmpty && (landmark.isNotEmpty || suburb.isNotEmpty)) {
            final areaPart = landmark.isNotEmpty ? landmark : suburb;
            title = '$lane, $areaPart';
          } else if (road.isNotEmpty && landmark.isNotEmpty) {
            title = '$road, $landmark';
          } else if (houseNumber.isNotEmpty &&
              (building.isNotEmpty || road.isNotEmpty)) {
            final targetBldg = building.isNotEmpty ? building : road;
            title = 'Building No. $houseNumber, $targetBldg';
          } else if (building.isNotEmpty && road.isNotEmpty) {
            title = '$building, $road';
          } else if (amenity.isNotEmpty && road.isNotEmpty) {
            title = '$amenity, $road';
          } else if (name.isNotEmpty && road.isNotEmpty && name != road) {
            title = '$name, $road';
          } else if (lane.isNotEmpty && road.isNotEmpty) {
            title = '$lane, $road';
          } else if (road.isNotEmpty) {
            title = road;
          } else if (landmark.isNotEmpty) {
            title = landmark;
          } else if (suburb.isNotEmpty) {
            title = suburb;
          } else {
            title = 'Pinned Location';
          }

          // 4. Pincode with 6-digit regex fallback
          var resolvedPincode = postcode;
          if (resolvedPincode.isEmpty && displayName.isNotEmpty) {
            final pinMatch = RegExp(r'\b\d{6}\b').firstMatch(displayName);
            if (pinMatch != null) {
              resolvedPincode = pinMatch.group(0)!;
            }
          }

          return DeliveryLocationModel(
            formattedAddress: displayName.isNotEmpty
                ? displayName
                : [addressLine, landmark, city, resolvedPincode]
                    .where((s) => s.isNotEmpty)
                    .join(', '),
            title: title,
            addressLine: addressLine,
            locality: landmark,
            city: city,
            postalCode: resolvedPincode,
            latitude: latitude,
            longitude: longitude,
          );
        }
      }
    } catch (e) {
      logger.e(
          "Error reverse geocoding via Nominatim ($latitude, $longitude): $e");
    }
    return null;
  }

  /// Forward geocodes an address string query into matching locations.
  static Future<List<DeliveryLocationModel>> searchAddress(String query) async {
    final list = <DeliveryLocationModel>[];
    if (query.trim().isEmpty) return list;

    // 1. Attempt Google Maps Search
    try {
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$googleMapsApiKey";

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as String? ?? '';
        final results = data['results'] as List<dynamic>? ?? [];

        if (status == 'OK' && results.isNotEmpty) {
          for (final res in results) {
            final item = res as Map<String, dynamic>;
            final formattedAddress =
                item['formatted_address'] as String? ?? '';
            final geometry = item['geometry'] as Map<String, dynamic>?;
            final location = geometry?['location'] as Map<String, dynamic>?;
            final lat = (location?['lat'] as num?)?.toDouble() ?? 0.0;
            final lng = (location?['lng'] as num?)?.toDouble() ?? 0.0;

            final parts = formattedAddress.split(',');
            final title =
                parts.isNotEmpty ? parts.first.trim() : formattedAddress;

            list.add(
              DeliveryLocationModel(
                formattedAddress: formattedAddress,
                title: title,
                addressLine: parts.isNotEmpty ? parts.first.trim() : '',
                locality: parts.length > 1 ? parts[1].trim() : '',
                city: parts.length > 2 ? parts[2].trim() : '',
                postalCode: '',
                latitude: lat,
                longitude: lng,
              ),
            );
          }
          return list;
        }
      }
    } catch (e) {
      logger.w("Google search unavailable for '$query': $e");
    }

    // 3. Fallback to OpenStreetMap Nominatim search
    return await _searchAddressNominatim(query);
  }

  static Future<List<DeliveryLocationModel>> _searchAddressNominatim(
    String query,
  ) async {
    final list = <DeliveryLocationModel>[];
    try {
      final url =
          "https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&addressdetails=1&limit=8";

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'NSDeliveryCustomerApp/1.0 (contact@nsdelivery.com)',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final items = response.data as List<dynamic>? ?? [];
        for (final item in items) {
          final map = item as Map<String, dynamic>;
          final displayName = map['display_name'] as String? ?? '';
          final lat = double.tryParse(map['lat']?.toString() ?? '') ?? 0.0;
          final lon = double.tryParse(map['lon']?.toString() ?? '') ?? 0.0;
          final address = map['address'] as Map<String, dynamic>? ?? {};

          final name = map['name'] as String? ?? '';
          final road = address['road'] as String? ?? '';
          final suburb = address['suburb'] as String? ??
              address['neighbourhood'] as String? ??
              '';
          final city = address['city'] as String? ??
              address['town'] as String? ??
              address['county'] as String? ??
              '';
          final postcode = address['postcode'] as String? ?? '';

          final title = name.isNotEmpty
              ? name
              : (displayName.split(',').first.trim());

          list.add(
            DeliveryLocationModel(
              formattedAddress: displayName,
              title: title,
              addressLine: road.isNotEmpty ? road : title,
              locality: suburb,
              city: city,
              postalCode: postcode,
              latitude: lat,
              longitude: lon,
            ),
          );
        }
      }
    } catch (e) {
      logger.e("Error searching via Nominatim '$query': $e");
    }
    return list;
  }
}

