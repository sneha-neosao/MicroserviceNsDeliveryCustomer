import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Response model for the Address List API:
/// GET /api/v1/web/address/list
///
/// Example:
/// {
///   "status": 200,
///   "message": "Addresses fetched successfully",
///   "data": {
///     "total": 2,
///     "addresses": [
///       {
///         "id": 7,
///         "public_id": "12ba1565-9f68-4b1f-9640-8ae515a84192",
///         "label": "string",
///         "delivery_name": "sneha",
///         "delivery_phone": "8551939455",
///         "address_line": "Nageshkar Heights",
///         "landmark": "Rajarampuri",
///         "city": "Kolhapur",
///         "pincode": "416007",
///         "lat": 16.6919,
///         "lng": 74.2353,
///         "is_default": true
///       }
///     ]
///   }
/// }
class AddressListResponse extends Equatable {
  final int status;
  final String message;
  final AddressListData? data;

  const AddressListResponse({
    this.status = 0,
    this.message = '',
    this.data,
  });

  factory AddressListResponse.fromRawJson(String str) =>
      AddressListResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory AddressListResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AddressListResponse();
    return AddressListResponse(
      status: (json['status'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AddressListData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };

  @override
  List<Object?> get props => [status, message, data];
}

class AddressListData extends Equatable {
  final int total;
  final List<AddressModel> addresses;

  const AddressListData({
    this.total = 0,
    this.addresses = const [],
  });

  factory AddressListData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AddressListData();

    final rawList = json['addresses'];
    final parsedAddresses = <AddressModel>[];

    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          parsedAddresses.add(AddressModel.fromJson(item));
        }
      }
    }

    return AddressListData(
      total: (json['total'] as num?)?.toInt() ?? parsedAddresses.length,
      addresses: parsedAddresses,
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'addresses': addresses.map((x) => x.toJson()).toList(),
  };

  @override
  List<Object?> get props => [total, addresses];
}

class AddressModel extends Equatable {
  final int id;
  final String publicId;
  final String label;
  final String deliveryName;
  final String deliveryPhone;
  final String addressLine;
  final String landmark;
  final String city;
  final String pincode;
  final double lat;
  final double lng;
  final bool isDefault;

  const AddressModel({
    this.id = 0,
    this.publicId = '',
    this.label = '',
    this.deliveryName = '',
    this.deliveryPhone = '',
    this.addressLine = '',
    this.landmark = '',
    this.city = '',
    this.pincode = '',
    this.lat = 0.0,
    this.lng = 0.0,
    this.isDefault = false,
  });

  /// Formatted single-line or multi-line full address
  String get fullAddress {
    final parts = <String>[];
    if (addressLine.trim().isNotEmpty) parts.add(addressLine.trim());
    if (landmark.trim().isNotEmpty) parts.add(landmark.trim());
    if (city.trim().isNotEmpty) parts.add(city.trim());
    if (pincode.trim().isNotEmpty) parts.add(pincode.trim());
    return parts.join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AddressModel();
    return AddressModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      publicId: json['public_id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      deliveryName: json['delivery_name']?.toString() ?? '',
      deliveryPhone: json['delivery_phone']?.toString() ?? '',
      addressLine: json['address_line']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'public_id': publicId,
    'label': label,
    'delivery_name': deliveryName,
    'delivery_phone': deliveryPhone,
    'address_line': addressLine,
    'landmark': landmark,
    'city': city,
    'pincode': pincode,
    'lat': lat,
    'lng': lng,
    'is_default': isDefault,
  };

  @override
  List<Object?> get props => [
    id,
    publicId,
    label,
    deliveryName,
    deliveryPhone,
    addressLine,
    landmark,
    city,
    pincode,
    lat,
    lng,
    isDefault,
  ];
}
