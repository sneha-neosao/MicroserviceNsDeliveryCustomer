import 'dart:convert';

/// Response model for the Send OTP API:
/// {
///   "status": 200,
///   "message": "OTP sent successfully",
///   "data": {
///     "mobile": "9970044090"
///   }
/// }
class SendOtpResponse {
  final int status;
  final String message;
  final SendOtpData? data;

  const SendOtpResponse({
    this.status = 0,
    this.message = '',
    this.data,
  });

  factory SendOtpResponse.fromRawJson(String str) =>
      SendOtpResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory SendOtpResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SendOtpResponse();
    return SendOtpResponse(
      status: (json['status'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SendOtpData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class SendOtpData {
  final String mobile;

  const SendOtpData({
    this.mobile = '',
  });

  factory SendOtpData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SendOtpData();
    return SendOtpData(
      mobile: json['mobile']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'mobile': mobile,
  };
}
