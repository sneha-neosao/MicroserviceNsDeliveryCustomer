import 'dart:convert';

/// Response model for the OTP Verify API.
///
/// Follows strict null-safety and safe JSON parsing rules:
/// - All fields have safe default fallbacks or null checks.
/// - Never crashes on null or missing keys.
class OtpVerifyResponse {
  final bool success;
  final String message;
  final OtpVerifyData? data;

  const OtpVerifyResponse({
    this.success = false,
    this.message = '',
    this.data,
  });

  factory OtpVerifyResponse.fromRawJson(String str) =>
      OtpVerifyResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory OtpVerifyResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OtpVerifyResponse();
    final dataMap = json['data'] != null && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : null;

    return OtpVerifyResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: dataMap != null
          ? OtpVerifyData.fromJson(dataMap, rootJson: json)
          : OtpVerifyData.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class OtpVerifyData {
  final int cooldownSeconds;
  final int expiresInSeconds;
  final String? token;
  final String? accessToken;
  final String? refreshToken;

  const OtpVerifyData({
    this.cooldownSeconds = 0,
    this.expiresInSeconds = 0,
    this.token,
    this.accessToken,
    this.refreshToken,
  });

  factory OtpVerifyData.fromJson(Map<String, dynamic>? json, {Map<String, dynamic>? rootJson}) {
    if (json == null) return const OtpVerifyData();

    final access = json['access']?.toString() ??
        json['access_token']?.toString() ??
        json['accessToken']?.toString() ??
        json['token']?.toString() ??
        (json['tokens'] is Map ? json['tokens']['access']?.toString() : null) ??
        rootJson?['access']?.toString() ??
        rootJson?['access_token']?.toString() ??
        rootJson?['token']?.toString();

    final refresh = json['refresh']?.toString() ??
        json['refresh_token']?.toString() ??
        json['refreshToken']?.toString() ??
        (json['tokens'] is Map ? json['tokens']['refresh']?.toString() : null) ??
        rootJson?['refresh']?.toString() ??
        rootJson?['refresh_token']?.toString();

    return OtpVerifyData(
      cooldownSeconds: (json['cooldown_seconds'] as num?)?.toInt() ?? 0,
      expiresInSeconds: (json['expires_in_seconds'] as num?)?.toInt() ?? 0,
      token: access,
      accessToken: access,
      refreshToken: refresh,
    );
  }

  Map<String, dynamic> toJson() => {
    'cooldown_seconds': cooldownSeconds,
    'expires_in_seconds': expiresInSeconds,
    if (token != null) 'token': token,
    if (accessToken != null) 'access_token': accessToken,
    if (refreshToken != null) 'refresh_token': refreshToken,
  };
}
