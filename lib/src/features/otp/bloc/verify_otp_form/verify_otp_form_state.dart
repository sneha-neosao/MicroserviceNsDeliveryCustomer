part of 'verify_otp_form_bloc.dart';

/// Base state for Verify OTP Form Validation BLoC.
sealed class VerifyOtpFormState extends Equatable {
  final String otp;
  final bool isValid;

  const VerifyOtpFormState({
    required this.otp,
    required this.isValid,
  });

  @override
  List<Object?> get props => [otp, isValid];
}

/// Initial empty form state
class VerifyOtpFormInitialState extends VerifyOtpFormState {
  const VerifyOtpFormInitialState()
      : super(
          otp: "",
          isValid: false,
        );
}

/// Validated form data state representing current input snapshot
class VerifyOtpFormDataState extends VerifyOtpFormState {
  final String inputOtp;
  final bool inputIsValid;

  const VerifyOtpFormDataState({
    required this.inputOtp,
    required this.inputIsValid,
  }) : super(
          otp: inputOtp,
          isValid: inputIsValid,
        );

  @override
  List<Object?> get props => [inputOtp, inputIsValid];
}
