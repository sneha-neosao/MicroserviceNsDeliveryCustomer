import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../remote/models/auth_model/otp_verify_response.dart';
import '../../remote/models/auth_model/verify_otp_response.dart';
import '../../remote/models/auth_model/register_response.dart';
import '../errors/failures.dart';
import '../utils/failure_converter.dart';

/// Session manager for managing user authentication and local preferences.
class SessionManager {
  static Future<bool> checkIsKeyPresent(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", isLoggedIn);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }

  static Future<void> saveSessionId(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token ?? "");
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token != null && token.trim().isNotEmpty) return token.trim();

    // Check VerifyOtp session
    final verifySession = await getVerifyOtpSession();
    if (verifySession?.data?.accessToken.isNotEmpty == true) {
      return verifySession!.data!.accessToken.trim();
    }

    // Check Register session
    final registerSession = await getRegisterSession();
    if (registerSession?.data?.accessToken.isNotEmpty == true) {
      return registerSession!.data!.accessToken.trim();
    }

    // Fallback: check saved userSession
    final userSession = await getUserSession();
    final sessionToken = userSession?.data?.accessToken ?? userSession?.data?.token;
    if (sessionToken != null && sessionToken.trim().isNotEmpty) return sessionToken.trim();

    return null;
  }

  static Future<void> saveRefreshToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("refreshToken", token ?? "");
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("refreshToken");
    if (token != null && token.trim().isNotEmpty) return token.trim();

    // Check VerifyOtp session
    final verifySession = await getVerifyOtpSession();
    if (verifySession?.data?.refreshToken.isNotEmpty == true) {
      return verifySession!.data!.refreshToken.trim();
    }

    // Check Register session
    final registerSession = await getRegisterSession();
    if (registerSession?.data?.refreshToken.isNotEmpty == true) {
      return registerSession!.data!.refreshToken.trim();
    }

    // Fallback: check saved userSession
    final userSession = await getUserSession();
    final sessionRefresh = userSession?.data?.refreshToken;
    if (sessionRefresh != null && sessionRefresh.trim().isNotEmpty) return sessionRefresh.trim();

    return null;
  }

  static Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveSessionId(accessToken);
    await saveRefreshToken(refreshToken);

    final userSession = await getUserSession();
    if (userSession != null) {
      final updatedData = OtpVerifyData(
        cooldownSeconds: userSession.data?.cooldownSeconds ?? 0,
        expiresInSeconds: userSession.data?.expiresInSeconds ?? 0,
        token: accessToken,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await saveUserSession(
        OtpVerifyResponse(
          success: userSession.success,
          message: userSession.message,
          data: updatedData,
        ),
      );
    }
  }

  static Future<void> saveUserSession(OtpVerifyResponse value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userSession", value.toRawJson());
  }

  static Future<OtpVerifyResponse?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("userSession");
    if (raw == null) return null;
    return OtpVerifyResponse.fromRawJson(raw);
  }

  static Future<void> saveVerifyOtpSession(VerifyOtpResponse value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("verifyOtpSession", value.toRawJson());
    await saveLoginStatus(value.data?.isRegistered ?? false);
    if (value.data != null) {
      if (value.data!.accessToken.isNotEmpty) {
        await saveSessionId(value.data!.accessToken);
      }
      if (value.data!.refreshToken.isNotEmpty) {
        await saveRefreshToken(value.data!.refreshToken);
      }
      final customer = value.data!.customer;
      if (customer != null) {
        await prefs.setString(
          "customerData",
          json.encode(customer.toJson()),
        );

        if (customer.contact.isNotEmpty) {
          await saveUserMobileNumber(customer.contact);
        }
        if (customer.name.isNotEmpty) {
          await saveUserName(customer.name);
        }
        if (customer.email.isNotEmpty) {
          await saveUserEmail(customer.email);
        }
        if (customer.id > 0) {
          await saveUserId(customer.id);
        }
        if (customer.publicId.isNotEmpty) {
          await saveUserPublicId(customer.publicId);
        }
      }
    }
  }

  static Future<VerifyOtpResponse?> getVerifyOtpSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("verifyOtpSession");
    if (raw == null) return null;
    return VerifyOtpResponse.fromRawJson(raw);
  }

  static Future<void> saveRegisterSession(RegisterResponse value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("registerSession", value.toRawJson());
    await saveLoginStatus(value.data?.isRegistered ?? true);

    final data = value.data;
    if (data != null) {
      if (data.accessToken.isNotEmpty) {
        await saveSessionId(data.accessToken);
      }
      if (data.refreshToken.isNotEmpty) {
        await saveRefreshToken(data.refreshToken);
      }

      final customer = data.customer;
      if (customer != null) {
        await prefs.setString(
          "customerData",
          json.encode(customer.toJson()),
        );

        if (customer.contact.isNotEmpty) {
          await saveUserMobileNumber(customer.contact);
        }
        if (customer.name.isNotEmpty) {
          await saveUserName(customer.name);
        }
        if (customer.email.isNotEmpty) {
          await saveUserEmail(customer.email);
        }
        if (customer.id > 0) {
          await saveUserId(customer.id);
        }
        if (customer.publicId.isNotEmpty) {
          await saveUserPublicId(customer.publicId);
        }
      }
    }
  }

  static Future<RegisterResponse?> getRegisterSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("registerSession");
    if (raw == null) return null;
    return RegisterResponse.fromRawJson(raw);
  }

  static Future<CustomerData?> getCustomerData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("customerData");
    if (raw == null) return null;
    return CustomerData.fromJson(json.decode(raw) as Map<String, dynamic>?);
  }

  static Future<void> saveUserMobileNumber(String? mobileNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userMobileNumber", mobileNumber ?? "");
  }

  static Future<String?> getUserMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userMobileNumber");
  }

  static Future<void> saveUserName(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userName", name ?? "");
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName");
  }

  static Future<void> saveUserEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userEmail", email ?? "");
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userEmail");
  }

  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("userId", id);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }

  static Future<void> saveUserPublicId(String? publicId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userPublicId", publicId ?? "");
  }

  static Future<String?> getUserPublicId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userPublicId");
  }

  static Future<void> saveDeliveryAddress({
    required String address,
    String? title,
    double? latitude,
    double? longitude,
    int? addressId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("deliveryAddress", address);
    if (title != null) await prefs.setString("deliveryAddressTitle", title);
    if (latitude != null) await prefs.setDouble("deliveryLatitude", latitude);
    if (longitude != null) await prefs.setDouble("deliveryLongitude", longitude);
    if (addressId != null) await prefs.setInt("selectedAddressId", addressId);
  }

  static Future<void> saveSelectedAddressId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("selectedAddressId", id);
  }

  static Future<int?> getSelectedAddressId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("selectedAddressId");
  }

  static Future<String?> getDeliveryAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("deliveryAddress");
  }

  static Future<String?> getDeliveryAddressTitle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("deliveryAddressTitle");
  }

  static Future<Map<String, double>?> getDeliveryCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble("deliveryLatitude");
    final lng = prefs.getDouble("deliveryLongitude");
    if (lat != null && lng != null) {
      return {"lat": lat, "lng": lng};
    }
    return null;
  }

  // static Future<void> saveUserProfile(ProfileResponse value) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString("userProfile", value.toRawJson());
  // }

  // static Future<ProfileResponse?> getUserProfile() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final raw = prefs.getString("userProfile");
  //   if (raw == null) return null;
  //   return ProfileResponse.fromRawJson(raw);
  // }

  static Future<void> saveFirebaseToken(String? firebasetoken) async {
    if (firebasetoken == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("firebasetoken", firebasetoken);
  }

  static Future<String?> getFirebaseToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("firebasetoken");
  }

  static Future<void> saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("saved_username", username);
    await prefs.setString("saved_password", password);
  }

  static Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString("saved_username");
    final password = prefs.getString("saved_password");
    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
    return null;
  }

  static Future<Either<Failure, void>> clear() async {
    final prefs = await SharedPreferences.getInstance();

    // Backup credentials and tokens before clearing
    final username = prefs.getString("saved_username");
    final password = prefs.getString("saved_password");
    final firebaseToken = prefs.getString("firebasetoken");

    final success = await prefs.clear();

    // Restore persistent identifiers
    if (username != null && password != null) {
      await prefs.setString("saved_username", username);
      await prefs.setString("saved_password", password);
    }
    if (firebaseToken != null) {
      await prefs.setString("firebasetoken", firebaseToken);
    }

    if (success) {
      return const Right(null);
    } else {
      return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
    }
  }
}
