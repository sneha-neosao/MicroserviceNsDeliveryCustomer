import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/failure_converter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../remote/models/auth_model/send_otp_response.dart';
import '../../domain/usecases/send_otp_usecase.dart';

part 'send_otp_event.dart';
part 'send_otp_state.dart';

/// Handles state management for **Send OTP** API execution.
class SendOtpBloc extends Bloc<SendOtpEvent, SendOtpState> {
  final SendOtpUseCase _sendOtpUseCase;

  SendOtpBloc(this._sendOtpUseCase) : super(SendOtpInitialState()) {
    on<SendOtpSubmitEvent>(_onSendOtp);
  }

  Future<void> _onSendOtp(
    SendOtpSubmitEvent event,
    Emitter<SendOtpState> emit,
  ) async {
    emit(SendOtpLoadingState());

    final result = await _sendOtpUseCase.call(
      SendOtpParams(mobile: event.mobile),
    );

    result.fold(
      (failure) => emit(
        SendOtpFailureState(
          failure.message.isNotEmpty ? failure.message : mapFailureToMessage(failure),
        ),
      ),
      (response) => emit(SendOtpSuccessState(response)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE SendOtpBloc =====");
    return super.close();
  }
}
