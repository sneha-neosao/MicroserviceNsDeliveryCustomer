import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Response model for Delete Address API:
/// DELETE /api/v1/web/address/delete?public_id={public_id}
///
/// Example:
/// {
///   "status": 200,
///   "message": "Address deleted successfully",
///   "data": {
///     "deleted_address_public_id": "ae76f3e8-8175-41ba-b51d-8a67f270cc49"
///   }
/// }
class DeleteAddressResponse extends Equatable {
  final int status;
  final String message;
  final DeleteAddressData? data;

  const DeleteAddressResponse({
    this.status = 0,
    this.message = '',
    this.data,
  });

  factory DeleteAddressResponse.fromRawJson(String str) =>
      DeleteAddressResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory DeleteAddressResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeleteAddressResponse();
    return DeleteAddressResponse(
      status: (json['status'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? DeleteAddressData.fromJson(json['data'] as Map<String, dynamic>)
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

class DeleteAddressData extends Equatable {
  final String deletedAddressPublicId;

  const DeleteAddressData({
    this.deletedAddressPublicId = '',
  });

  factory DeleteAddressData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeleteAddressData();
    return DeleteAddressData(
      deletedAddressPublicId:
          json['deleted_address_public_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'deleted_address_public_id': deletedAddressPublicId,
      };

  @override
  List<Object?> get props => [deletedAddressPublicId];
}
