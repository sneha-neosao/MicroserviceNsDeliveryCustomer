import 'dart:convert';

/// Response model for the Token Refresh API.
///
/// Follows strict null-safety and safe JSON parsing rules:
/// - All fields have safe default fallbacks or null checks.
/// - Never crashes on null or missing keys.
class TokenRefreshResponse {
  final bool success;
  final String message;
  final TokenRefreshData? data;

  const TokenRefreshResponse({
    this.success = false,
    this.message = '',
    this.data,
  });

  factory TokenRefreshResponse.fromRawJson(String str) =>
      TokenRefreshResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory TokenRefreshResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TokenRefreshResponse();

    final dataMap = json['data'] != null && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : null;

    return TokenRefreshResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: dataMap != null
          ? TokenRefreshData.fromJson(dataMap)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class TokenRefreshData {
  final String access;
  final String refresh;

  const TokenRefreshData({
    this.access = '',
    this.refresh = '',
  });

  factory TokenRefreshData.fromRawJson(String str) =>
      TokenRefreshData.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory TokenRefreshData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TokenRefreshData();

    final access = json['access']?.toString() ??
        json['access_token']?.toString() ??
        json['accessToken']?.toString() ??
        json['token']?.toString() ??
        '';

    final refresh = json['refresh']?.toString() ??
        json['refresh_token']?.toString() ??
        json['refreshToken']?.toString() ??
        '';

    return TokenRefreshData(
      access: access,
      refresh: refresh,
    );
  }

  Map<String, dynamic> toJson() => {
    'access': access,
    'refresh': refresh,
  };
}
