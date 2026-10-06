part of 'send_otp_bloc.dart';

sealed class SendOtpState extends Equatable {
  const SendOtpState();

  @override
  List<Object?> get props => [];
}

class SendOtpInitialState extends SendOtpState {}

class SendOtpLoadingState extends SendOtpState {}

class SendOtpSuccessState extends SendOtpState {
  final SendOtpResponse data;

  const SendOtpSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class SendOtpFailureState extends SendOtpState {
  final String message;

  const SendOtpFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
