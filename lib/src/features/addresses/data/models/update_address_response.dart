import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'address_list_response.dart';

/// Response model for Update Address API:
/// PUT /api/v1/web/address/update?public_id={public_id}
///
/// Example:
/// {
///   "status": 200,
///   "message": "Address updated successfully",
///   "data": {
///     "id": 8,
///     "public_id": "385d5536-75b5-49b3-9145-327f60fe61c8",
///     "label": "office",
///     "delivery_name": "sneha jadhav",
///     "delivery_phone": "8551939455",
///     "address_line": "Udyam Nagar, Rajarampuri",
///     "landmark": "Shivaji udyam nagar",
///     "city": "Kolhapur",
///     "pincode": "416002",
///     "lat": 16.691885877393656,
///     "lng": 74.23528634011745,
///     "is_default": false
///   }
/// }
class UpdateAddressResponse extends Equatable {
  final int status;
  final String message;
  final AddressModel? data;

  const UpdateAddressResponse({
    this.status = 0,
    this.message = '',
    this.data,
  });

  factory UpdateAddressResponse.fromRawJson(String str) =>
      UpdateAddressResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory UpdateAddressResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpdateAddressResponse();
    return UpdateAddressResponse(
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
