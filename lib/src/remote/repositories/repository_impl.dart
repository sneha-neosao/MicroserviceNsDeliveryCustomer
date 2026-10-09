// ignore_for_file: non_constant_identifier_names

import 'package:fpdart/fpdart.dart';
import '../../configs/injector/injector.dart';
import '../../core/api/api_exception.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/failure_converter.dart';

/// Abstract Repository interface defining all data operations for the app

abstract class Repository {

  /// Authentication
  Future<Either<Failure, SendOtpResponse>> send_otp(SendOtpParams params);
  Future<Either<Failure, VerifyOtpResponse>> verify_otp(VerifyOtpParams params);
  Future<Either<Failure, RegisterResponse>> register(RegisterParams params);
  Future<Either<Failure, AddressListResponse>> address_list();
  Future<Either<Failure, AddAddressResponse>> add_address(AddAddressParams params);
  Future<Either<Failure, UpdateAddressResponse>> edit_address(EditAddressParams params);
  Future<Either<Failure, DeleteAddressResponse>> delete_address(DeleteAddressParams params);
}

class AuthRepositoryImpl implements Repository {
  final RemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  const AuthRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, SendOtpResponse>> send_otp(SendOtpParams params) {
    return _networkInfo.check<SendOtpResponse>(
      connected: () async {
        try {
          final respData = await _remoteDataSource.SendOtp(params);

          if (respData.status != 200 && respData.status != 201) {
            return Left(ApiFailure(respData.message.isNotEmpty ? respData.message : "Failed to send OTP"));
          }

          return Right(respData);
        } on ServerException {
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        } catch (e) {
          if (e is ApiException) {
            return Left(ApiFailure(e.message));
          }
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        }
      },
      notConnected: () async {
        try {
          return Left(InternetFailure(mapFailureToMessage(InternetFailure(""))));
        } on CacheException {
          return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
        }
      },
    );
  }

  @override
  Future<Either<Failure, VerifyOtpResponse>> verify_otp(VerifyOtpParams params) {
    return _networkInfo.check<VerifyOtpResponse>(
      connected: () async {
        try {
          final respData = await _remoteDataSource.VerifyOtp(params);

          if (respData.status != 200 && respData.status != 201) {
            return Left(ApiFailure(respData.message.isNotEmpty ? respData.message : "Failed to verify OTP"));
          }

          return Right(respData);
        } on ServerException {
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        } catch (e) {
          if (e is ApiException) {
            return Left(ApiFailure(e.message));
          }
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        }
      },
      notConnected: () async {
        try {
          return Left(InternetFailure(mapFailureToMessage(InternetFailure(""))));
        } on CacheException {
          return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
        }
      },
    );
  }

  @override
  Future<Either<Failure, RegisterResponse>> register(RegisterParams params) {
    return _networkInfo.check<RegisterResponse>(
      connected: () async {
        try {
          final respData = await _remoteDataSource.Register(params);

          if (respData.status != 200 && respData.status != 201) {
            return Left(ApiFailure(respData.message.isNotEmpty ? respData.message : "Failed to register"));
          }

          return Right(respData);
        } on ServerException {
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        } catch (e) {
          if (e is ApiException) {
            return Left(ApiFailure(e.message));
          }
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        }
      },
      notConnected: () async {
        try {
          return Left(InternetFailure(mapFailureToMessage(InternetFailure(""))));
        } on CacheException {
          return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
        }
      },
    );
  }

  @override
  Future<Either<Failure, AddressListResponse>> address_list() {
    return _networkInfo.check<AddressListResponse>(
      connected: () async {
        try {
          final respData = await _remoteDataSource.AddressList();

          if (respData.status != 200 && respData.status != 201) {
            return Left(ApiFailure(respData.message.isNotEmpty ? respData.message : "Failed to fetch addresses"));
          }

          return Right(respData);
        } on ServerException {
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        } catch (e) {
          if (e is ApiException) {
            return Left(ApiFailure(e.message));
          }
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        }
      },
      notConnected: () async {
        try {
          return Left(InternetFailure(mapFailureToMessage(InternetFailure(""))));
        } on CacheException {
          return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
        }
      },
    );
  }

  @override
  Future<Either<Failure, AddAddressResponse>> add_address(AddAddressParams params) {
    return _networkInfo.check<AddAddressResponse>(
      connected: () async {
        try {
          final respData = await _remoteDataSource.AddAddress(params);

          if (respData.status != 200 && respData.status != 201) {
            return Left(ApiFailure(respData.message.isNotEmpty ? respData.message : "Failed to add address"));
          }

          return Right(respData);
        } on ServerException {
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        } catch (e) {
          if (e is ApiException) {
            return Left(ApiFailure(e.message));
          }
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        }
      },
      notConnected: () async {
        try {
          return Left(InternetFailure(mapFailureToMessage(InternetFailure(""))));
        } on CacheException {
          return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
        }
      },
    );
  }

  @override
  Future<Either<Failure, UpdateAddressResponse>> edit_address(EditAddressParams params) {
    return _networkInfo.check<UpdateAddressResponse>(
      connected: () async {
        try {
          final respData = await _remoteDataSource.EditAddress(params);

          if (respData.status != 200 && respData.status != 201) {
            return Left(ApiFailure(respData.message.isNotEmpty ? respData.message : "Failed to update address"));
          }

          return Right(respData);
        } on ServerException {
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        } catch (e) {
          if (e is ApiException) {
            return Left(ApiFailure(e.message));
          }
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        }
      },
      notConnected: () async {
        try {
          return Left(InternetFailure(mapFailureToMessage(InternetFailure(""))));
        } on CacheException {
          return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
        }
      },
    );
  }

  @override
  Future<Either<Failure, DeleteAddressResponse>> delete_address(DeleteAddressParams params) {
    return _networkInfo.check<DeleteAddressResponse>(
      connected: () async {
        try {
           final respData = await _remoteDataSource.DeleteAddress(params);

          if (respData.status != 200 && respData.status != 201) {
            return Left(ApiFailure(respData.message.isNotEmpty ? respData.message : "Failed to delete address"));
          }

          return Right(respData);
        } on ServerException {
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        } catch (e) {
          if (e is ApiException) {
            return Left(ApiFailure(e.message));
          }
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        }
      },
      notConnected: () async {
        try {
          return Left(InternetFailure(mapFailureToMessage(InternetFailure(""))));
        } on CacheException {
          return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
        }
      },
    );
  }

  // @override
  // Future<Either<Failure, OtpRequestResponse>> request_otp(RequestOtpParams params) {
  //   return _networkInfo.check<OtpRequestResponse>(
  //     connected: () async {
  //       try {
  //         final respData = await _remoteDataSource.RequestOtp(params);
  //
  //         if (!respData.success) {
  //           return Left(ApiFailure(respData.message.isNotEmpty ? respData.message : "Failed to send OTP"));
  //         }
  //
  //         return Right(respData);
  //       } on ServerException {
  //         return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
  //       } catch (e) {
  //         if (e is ApiException) {
  //           return Left(ApiFailure(e.message)); // rethrow as-is
  //         }
  //         return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
  //       }
  //     },
  //     notConnected: () async {
  //       try {
  //         return Left(InternetFailure(mapFailureToMessage(InternetFailure(""))));
  //       } on CacheException {
  //         return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
  //       }
  //     },
  //   );
  // }

}
