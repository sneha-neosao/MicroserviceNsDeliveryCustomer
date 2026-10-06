import 'dart:convert';
import 'verify_otp_response.dart';

/// Response model for the Register API:
/// ```json
/// {
///   "status": 200,
///   "message": "Registration successful",
///   "data": {
///     "is_registered": true,
///     "access_token": "...",
///     "refresh_token": "...",
///     "token_type": null,
///     "customer": {
///       "id": 15,
///       "public_id": "cus_c51a659eb4f5",
///       "name": "sneha jadhav",
///       "email": "sneha@gmail.com",
///       "contact": "9970044093",
///       "is_active": true
///     },
///     "cart_merged": false
///   }
/// }
/// ```
class RegisterResponse {
  final int status;
  final String message;
  final RegisterData? data;

  const RegisterResponse({
    this.status = 0,
    this.message = '',
    this.data,
  });

  factory RegisterResponse.fromRawJson(String str) =>
      RegisterResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory RegisterResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RegisterResponse();
    return RegisterResponse(
      status: (json['status'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? RegisterData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class RegisterData {
  final bool isRegistered;
  final String accessToken;
  final String refreshToken;
  final String? tokenType;
  final CustomerData? customer;
  final bool cartMerged;

  const RegisterData({
    this.isRegistered = false,
    this.accessToken = '',
    this.refreshToken = '',
    this.tokenType,
    this.customer,
    this.cartMerged = false,
  });

  factory RegisterData.fromRawJson(String str) =>
      RegisterData.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory RegisterData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RegisterData();
    return RegisterData(
      isRegistered: json['is_registered'] as bool? ?? false,
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString(),
      customer: json['customer'] != null && json['customer'] is Map<String, dynamic>
          ? CustomerData.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      cartMerged: json['cart_merged'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_registered': isRegistered,
    'access_token': accessToken,
    'refresh_token': refreshToken,
    if (tokenType != null) 'token_type': tokenType,
    'customer': customer?.toJson(),
    'cart_merged': cartMerged,
  };
}
