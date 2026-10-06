import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';

part 'verify_otp_form_event.dart';
part 'verify_otp_form_state.dart';

/// Handles validation logic for **Verify OTP Form Inputs**.
class VerifyOtpFormBloc extends Bloc<VerifyOtpFormEvent, VerifyOtpFormState> {
  VerifyOtpFormBloc() : super(const VerifyOtpFormInitialState()) {
    on<VerifyOtpFormOtpChangedEvent>(_otpChanged);
  }

  /// Listens to changes in OTP input
  Future<void> _otpChanged(
    VerifyOtpFormOtpChangedEvent event,
    Emitter<VerifyOtpFormState> emit,
  ) async {
    final isValid = inputValidator(event.otp);
    emit(
      VerifyOtpFormDataState(
        inputOtp: event.otp,
        inputIsValid: isValid,
      ),
    );
  }

  bool inputValidator(String otp) {
    final trimmed = otp.trim();
    if (trimmed.length == 6 && int.tryParse(trimmed) != null) {
      return true;
    }
    return false;
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE VerifyOtpFormBloc =====");
    return super.close();
  }
}
