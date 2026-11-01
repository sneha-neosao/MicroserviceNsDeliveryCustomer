import 'dart:convert';

/// Response model for the Verify OTP API:
/// ```json
/// {
///   "status": 200,
///   "message": "Login successful",
///   "data": {
///     "is_registered": true,
///     "access_token": "...",
///     "refresh_token": "...",
///     "token_type": "bearer",
///     "customer": {
///       "id": 13,
///       "public_id": "cus_6e10335c1615",
///       "name": "sneha jadhav",
///       "email": "sneha@gmail.com",
///       "contact": "9970044090",
///       "is_active": true
///     },
///     "cart_merged": false
///   }
/// }
/// ```
class VerifyOtpResponse {
  final int status;
  final String message;
  final VerifyOtpData? data;

  const VerifyOtpResponse({
    this.status = 0,
    this.message = '',
    this.data,
  });

  factory VerifyOtpResponse.fromRawJson(String str) =>
      VerifyOtpResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory VerifyOtpResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VerifyOtpResponse();
    return VerifyOtpResponse(
      status: (json['status'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? VerifyOtpData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class VerifyOtpData {
  final bool isRegistered;
  final bool isExist;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final CustomerData? customer;
  final bool cartMerged;

  const VerifyOtpData({
    this.isRegistered = false,
    this.isExist = false,
    this.accessToken = '',
    this.refreshToken = '',
    this.tokenType = '',
    this.customer,
    this.cartMerged = false,
  });

  factory VerifyOtpData.fromRawJson(String str) =>
      VerifyOtpData.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory VerifyOtpData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VerifyOtpData();
    final bool? isExistRaw = json['is_exist'] as bool?;
    final bool? isRegRaw = json['is_registered'] as bool?;
    final bool hasCustomerAndToken = json['customer'] != null &&
        (json['access_token']?.toString().isNotEmpty ?? false);
    final bool resolvedExist = isExistRaw ?? isRegRaw ?? hasCustomerAndToken;

    return VerifyOtpData(
      isRegistered: resolvedExist,
      isExist: resolvedExist,
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? '',
      customer: json['customer'] != null && json['customer'] is Map<String, dynamic>
          ? CustomerData.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      cartMerged: json['cart_merged'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_registered': isRegistered,
    'is_exist': isExist,
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'token_type': tokenType,
    'customer': customer?.toJson(),
    'cart_merged': cartMerged,
  };
}

class CustomerData {
  final int id;
  final String uuId;
  final String publicId;
  final String name;
  final String email;
  final String contact;
  final String alternateNumber;
  final bool isActive;

  const CustomerData({
    this.id = 0,
    this.uuId = '',
    this.publicId = '',
    this.name = '',
    this.email = '',
    this.contact = '',
    this.alternateNumber = '',
    this.isActive = false,
  });

  factory CustomerData.fromRawJson(String str) =>
      CustomerData.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory CustomerData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CustomerData();
    final resolvedUuId = json['uu_id']?.toString() ?? json['public_id']?.toString() ?? '';
    final resolvedPublicId = json['public_id']?.toString() ?? json['uu_id']?.toString() ?? '';
    return CustomerData(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uuId: resolvedUuId,
      publicId: resolvedPublicId,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      alternateNumber: json['alternate_number']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uu_id': uuId,
    'public_id': publicId,
    'name': name,
    'email': email,
    'contact': contact,
    'alternate_number': alternateNumber,
    'is_active': isActive,
  };
}
