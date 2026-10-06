part of 'send_otp_bloc.dart';

sealed class SendOtpEvent extends Equatable {
  const SendOtpEvent();

  @override
  List<Object?> get props => [];
}

class SendOtpSubmitEvent extends SendOtpEvent {
  final String mobile;

  const SendOtpSubmitEvent(this.mobile);

  @override
  List<Object?> get props => [mobile];
}
