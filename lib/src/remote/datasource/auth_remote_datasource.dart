// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import '../../configs/injector/injector.dart';
import '../../core/api/api_exception.dart';
import '../../core/errors/exceptions.dart';

sealed class RemoteDataSource {

  /// Authentication
  Future<SendOtpResponse> SendOtp(SendOtpParams params);
  Future<VerifyOtpResponse> VerifyOtp(VerifyOtpParams params);
  Future<RegisterResponse> Register(RegisterParams params);

  /// Address
  Future<AddressListResponse> AddressList();
  Future<AddAddressResponse> AddAddress(AddAddressParams params);
  Future<UpdateAddressResponse> EditAddress(EditAddressParams params);
  Future<DeleteAddressResponse> DeleteAddress(DeleteAddressParams params);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final ApiHelper _helper;

  /// Helper for normal API requests
  // final ApiHelper _superAdminHelper; /// Helper for super-admin or special API requests

  RemoteDataSourceImpl(this._helper);

  @override
  Future<SendOtpResponse> SendOtp(SendOtpParams params) async {
    try {
      final data = {
        "mobile": params.mobile,
      };

      final response = await _helper.execute(
        method: Method.post,
        url: ApiUrl.sendOtp,
        data: data,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      final respData = SendOtpResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<VerifyOtpResponse> VerifyOtp(VerifyOtpParams params) async {
    try {
      final data = {
        "mobile": params.mobile,
        "otp": params.otp,
      };

      final response = await _helper.execute(
        method: Method.post,
        url: ApiUrl.verifyOtp,
        data: data,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      final respData = VerifyOtpResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<RegisterResponse> Register(RegisterParams params) async {
    try {
      final data = {
        "name": params.name,
        if (params.email != null && params.email!.isNotEmpty) "email": params.email,
        "contact": params.contact,
      };

      final response = await _helper.execute(
        method: Method.post,
        url: ApiUrl.register,
        data: data,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      final respData = RegisterResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<AddressListResponse> AddressList() async {
    try {
      final response = await _helper.execute(
        method: Method.get,
        url: ApiUrl.addressList,
        options: Options(
          headers: {
            'accept': '*/*',
          },
        ),
      );

      final respData = AddressListResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<AddAddressResponse> AddAddress(AddAddressParams params) async {
    try {
      final response = await _helper.execute(
        method: Method.post,
        url: ApiUrl.addAddress,
        data: params.toJson(),
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      final respData = AddAddressResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<UpdateAddressResponse> EditAddress(EditAddressParams params) async {
    try {
      final response = await _helper.execute(
        method: Method.put,
        url: ApiUrl.updateAddress(params.publicId),
        data: params.toJson(),
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      final respData = UpdateAddressResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<DeleteAddressResponse> DeleteAddress(DeleteAddressParams params) async {
    try {
      final response = await _helper.execute(
        method: Method.delete,
        url: ApiUrl.deleteAddress(params.publicId),
        options: Options(
          headers: {
            'accept': '*/*',
          },
        ),
      );

      final respData = DeleteAddressResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException();
    }
  }


  // @override
  // Future<OtpRequestResponse> RequestOtp(RequestOtpParams params) async {
  //   try {
  //     final data = {
  //       "mobile_number": params.mobileNumber,
  //     };
  //
  //     final response = await _helper.execute(
  //       method: Method.post,
  //       url: ApiUrl.requestOtp,
  //       data: data,
  //       options: Options(
  //         headers: {
  //           'accept': '*/*',
  //           'Content-Type': 'application/json',
  //         },
  //       ),
  //     );
  //
  //     final respData = OtpRequestResponse.fromJson(response);
  //     return respData;
  //   } on EmptyException {
  //     throw AuthException();
  //   } catch (e) {
  //     logger.e(e);
  //     if (e is ApiException) {
  //       rethrow;
  //     }
  //     throw ServerException();
  //   }
  // }

}
