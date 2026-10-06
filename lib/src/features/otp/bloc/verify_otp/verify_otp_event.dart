part of 'verify_otp_bloc.dart';

/// Sealed class defining the event hierarchy for Verify OTP.
sealed class VerifyOtpEvent extends Equatable {
  const VerifyOtpEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the user taps "Verify OTP".
class VerifyOtpSubmitEvent extends VerifyOtpEvent {
  final String mobile;
  final String otp;

  const VerifyOtpSubmitEvent({
    required this.mobile,
    required this.otp,
  });

  @override
  List<Object?> get props => [mobile, otp];
}

/// Event triggered when the user taps "Resend OTP".
class VerifyOtpResendEvent extends VerifyOtpEvent {
  final String mobile;

  const VerifyOtpResendEvent({
    required this.mobile,
  });

  @override
  List<Object?> get props => [mobile];
}
