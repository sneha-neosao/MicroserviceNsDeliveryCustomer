part of 'send_otp_form_bloc.dart';

/// Base state for Send OTP Form Validation BLoC.
sealed class SendOtpFormState extends Equatable {
  final String mobile;
  final bool isValid;

  const SendOtpFormState({
    required this.mobile,
    required this.isValid,
  });

  @override
  List<Object?> get props => [mobile, isValid];
}

/// Initial empty form state
class SendOtpFormInitialState extends SendOtpFormState {
  const SendOtpFormInitialState()
      : super(
          mobile: "",
          isValid: false,
        );
}

/// Validated form data state representing current input snapshot
class SendOtpFormDataState extends SendOtpFormState {
  final String inputMobile;
  final bool inputIsValid;

  const SendOtpFormDataState({
    required this.inputMobile,
    required this.inputIsValid,
  }) : super(
          mobile: inputMobile,
          isValid: inputIsValid,
        );

  @override
  List<Object?> get props => [inputMobile, inputIsValid];
}
