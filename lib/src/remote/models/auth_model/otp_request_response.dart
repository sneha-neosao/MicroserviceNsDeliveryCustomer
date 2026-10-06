import 'dart:convert';

/// Response model for the OTP Request API.
///
/// Follows strict null-safety and safe JSON parsing rules:
/// - All fields have safe default fallbacks or null checks.
/// - Never crashes on null or missing keys.
class OtpRequestResponse {
  final bool success;
  final String message;
  final OtpRequestData? data;

  const OtpRequestResponse({
    this.success = false,
    this.message = '',
    this.data,
  });

  factory OtpRequestResponse.fromRawJson(String str) =>
      OtpRequestResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory OtpRequestResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OtpRequestResponse();
    return OtpRequestResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? OtpRequestData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class OtpRequestData {
  final int cooldownSeconds;
  final int expiresInSeconds;

  const OtpRequestData({
    this.cooldownSeconds = 0,
    this.expiresInSeconds = 0,
  });

  factory OtpRequestData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OtpRequestData();
    return OtpRequestData(
      cooldownSeconds: (json['cooldown_seconds'] as num?)?.toInt() ?? 0,
      expiresInSeconds: (json['expires_in_seconds'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'cooldown_seconds': cooldownSeconds,
    'expires_in_seconds': expiresInSeconds,
  };
}
