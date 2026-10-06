import 'dart:convert';

/// Response model for the Logout API.
///
/// Follows strict null-safety and safe JSON parsing rules:
/// - All fields have safe default fallbacks or null checks.
/// - Never crashes on null or missing keys.
///
/// Example:
/// {
///   "success": true,
///   "message": "Logged out successfully.",
///   "data": {}
/// }
class LogoutResponse {
  final bool success;
  final String message;
  final Map<String, dynamic> data;

  const LogoutResponse({
    this.success = false,
    this.message = '',
    this.data = const {},
  });

  factory LogoutResponse.fromRawJson(String str) =>
      LogoutResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory LogoutResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LogoutResponse();

    Map<String, dynamic> parsedData = const {};
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      parsedData = json['data'] as Map<String, dynamic>;
    }

    return LogoutResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data,
  };
}
