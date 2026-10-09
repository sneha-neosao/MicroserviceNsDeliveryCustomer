import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Response model for the Profile Details API:
/// GET /api/v1/web/profile
///
/// Example:
/// {
///   "status": 200,
///   "message": "Profile fetched successfully",
///   "data": {
///     "name": "sneha jadhav",
///     "email": null,
///     "contact": "8551939455",
///     "profile_image": null
///   }
/// }
class ProfileResponse extends Equatable {
  final int status;
  final String message;
  final ProfileData? data;

  const ProfileResponse({
    this.status = 0,
    this.message = '',
    this.data,
  });

  factory ProfileResponse.fromRawJson(String str) =>
      ProfileResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory ProfileResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProfileResponse();
    return ProfileResponse(
      status: (json['status'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ProfileData.fromJson(json['data'] as Map<String, dynamic>)
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

class ProfileData extends Equatable {
  final String name;
  final String? email;
  final String contact;
  final String? profileImage;

  const ProfileData({
    this.name = '',
    this.email,
    this.contact = '',
    this.profileImage,
  });

  factory ProfileData.fromRawJson(String str) =>
      ProfileData.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory ProfileData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProfileData();
    return ProfileData(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      contact: json['contact']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'contact': contact,
        'profile_image': profileImage,
      };

  @override
  List<Object?> get props => [name, email, contact, profileImage];
}
