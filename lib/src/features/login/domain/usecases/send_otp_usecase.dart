import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/string_validator_extension.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../remote/models/auth_model/send_otp_response.dart';
import '../../../../remote/repositories/repository_impl.dart';

class SendOtpParams extends Equatable {
  final String mobile;

  const SendOtpParams({required this.mobile});

  @override
  List<Object?> get props => [mobile];
}

/// Use case for sending an OTP to the given mobile number.
/// Includes validation for empty and valid 10-digit mobile number.
class SendOtpUseCase implements UseCase<SendOtpResponse, SendOtpParams> {
  final Repository _repository;

  const SendOtpUseCase(this._repository);

  @override
  Future<Either<Failure, SendOtpResponse>> call(SendOtpParams params) async {
    final trimmedMobile = params.mobile.trim();

    if (trimmedMobile.isEmpty) {
      return Left(EmptyFailure('enter_mobile_number_error'.tr()));
    }

    if (!trimmedMobile.isMobileNumberValid) {
      return Left(InvalidMobileNumberFailure('valid_mobile_number_error'.tr()));
    }

    return await _repository.send_otp(SendOtpParams(mobile: trimmedMobile));
  }
}
