part of 'send_otp_form_bloc.dart';

/// Base class for all send OTP form input events
sealed class SendOtpFormEvent extends Equatable {
  const SendOtpFormEvent();

  @override
  List<Object?> get props => [];
}

/// Listens for changes in mobile input
class SendOtpFormMobileChangedEvent extends SendOtpFormEvent {
  final String mobile;

  const SendOtpFormMobileChangedEvent(this.mobile);

  @override
  List<Object?> get props => [mobile];
}
