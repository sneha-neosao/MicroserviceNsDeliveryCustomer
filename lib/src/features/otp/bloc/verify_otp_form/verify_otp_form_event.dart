part of 'verify_otp_form_bloc.dart';

/// Base class for all Verify OTP form input events
sealed class VerifyOtpFormEvent extends Equatable {
  const VerifyOtpFormEvent();

  @override
  List<Object?> get props => [];
}

/// Listens for changes in OTP input
class VerifyOtpFormOtpChangedEvent extends VerifyOtpFormEvent {
  final String otp;

  const VerifyOtpFormOtpChangedEvent(this.otp);

  @override
  List<Object?> get props => [otp];
}
