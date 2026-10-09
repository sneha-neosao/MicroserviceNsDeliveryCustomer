import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'address_list_response.dart';

/// Response model for Add Address API:
/// POST /api/v1/web/address/add
///
/// Example:
/// {
///   "status": 200,
///   "message": "Address added successfully",
///   "data": {
///     "id": 8,
///     "public_id": "385d5536-75b5-49b3-9145-327f60fe61c8",
///     "label": "home",
///     "delivery_name": "sneha",
///     "delivery_phone": "8551939455",
///     "address_line": "Nageshkar Heights",
///     "landmark": "Rajarampuri",
///     "city": "Kolhapur",
///     "pincode": "416007",
///     "lat": 16.6919,
///     "lng": 74.2353,
///     "is_default": false
///   }
/// }
class AddAddressResponse extends Equatable {
  final int status;
  final String message;
  final AddressModel? data;

  const AddAddressResponse({
    this.status = 0,
    this.message = '',
    this.data,
  });

  factory AddAddressResponse.fromRawJson(String str) =>
      AddAddressResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory AddAddressResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AddAddressResponse();
    return AddAddressResponse(
      status: (json['status'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AddressModel.fromJson(json['data'] as Map<String, dynamic>)
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
