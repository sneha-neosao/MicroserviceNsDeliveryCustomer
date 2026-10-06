part of 'verify_otp_bloc.dart';

/// Sealed class defining the state hierarchy for Verify OTP.
sealed class VerifyOtpState extends Equatable {
  const VerifyOtpState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the Verify OTP screen.
class VerifyOtpInitialState extends VerifyOtpState {}

/// State emitted when an OTP operation is in progress.
class VerifyOtpLoadingState extends VerifyOtpState {}

/// State emitted when the OTP is successfully verified.
class VerifyOtpSuccessState extends VerifyOtpState {
  final VerifyOtpResponse data;

  const VerifyOtpSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

/// State emitted when OTP verification fails.
class VerifyOtpFailureState extends VerifyOtpState {
  final String message;

  const VerifyOtpFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

/// State emitted when the OTP is successfully resent.
class VerifyOtpResendSuccessState extends VerifyOtpState {
  final String message;

  const VerifyOtpResendSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}
