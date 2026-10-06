import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/string_validator_extension.dart';
import '../../../../core/utils/logger.dart';

part 'send_otp_form_event.dart';
part 'send_otp_form_state.dart';

/// Handles validation logic for **Send OTP Form Inputs**.
class SendOtpFormBloc extends Bloc<SendOtpFormEvent, SendOtpFormState> {
  SendOtpFormBloc() : super(const SendOtpFormInitialState()) {
    on<SendOtpFormMobileChangedEvent>(_onMobileChanged);
  }

  Future<void> _onMobileChanged(
    SendOtpFormMobileChangedEvent event,
    Emitter<SendOtpFormState> emit,
  ) async {
    emit(
      SendOtpFormDataState(
        inputMobile: event.mobile,
        inputIsValid: inputValidator(event.mobile),
      ),
    );
  }

  bool inputValidator(String mobile) {
    final trimmed = mobile.trim();
    return trimmed.isNotEmpty && trimmed.isMobileNumberValid;
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE SendOtpFormBloc =====");
    return super.close();
  }
}
