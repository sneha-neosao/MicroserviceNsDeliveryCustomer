import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/string_validator_extension.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../remote/models/auth_model/verify_otp_response.dart';
import '../../../../remote/repositories/repository_impl.dart';

class VerifyOtpParams extends Equatable {
  final String mobile;
  final String otp;

  const VerifyOtpParams({
    required this.mobile,
    required this.otp,
  });

  @override
  List<Object?> get props => [mobile, otp];
}

/// Use case for verifying an OTP for a given mobile number.
/// Includes validations for mobile number format and 6-digit OTP.
class VerifyOtpUseCase implements UseCase<VerifyOtpResponse, VerifyOtpParams> {
  final Repository _repository;

  const VerifyOtpUseCase(this._repository);

  @override
  Future<Either<Failure, VerifyOtpResponse>> call(VerifyOtpParams params) async {
    final trimmedMobile = params.mobile.trim();
    final trimmedOtp = params.otp.trim();

    if (trimmedMobile.isEmpty) {
      return Left(EmptyFailure('enter_mobile_number_error'.tr()));
    }

    if (!trimmedMobile.isMobileNumberValid) {
      return Left(InvalidMobileNumberFailure('valid_mobile_number_error'.tr()));
    }

    if (trimmedOtp.isEmpty) {
      return Left(EmptyFailure('enter_valid_otp_error'.tr()));
    }

    if (trimmedOtp.length != 6 || int.tryParse(trimmedOtp) == null) {
      return Left(InvalidOtpFailure('enter_valid_otp_error'.tr()));
    }

    return await _repository.verify_otp(
      VerifyOtpParams(
        mobile: trimmedMobile,
        otp: trimmedOtp,
      ),
    );
  }
}
