import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/utils/logger.dart';
import '../../../../remote/models/auth_model/verify_otp_response.dart';
import '../../../login/domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

part 'verify_otp_event.dart';
part 'verify_otp_state.dart';

/// Handles state management for **Verify OTP** and resend operations via UseCases.
class VerifyOtpBloc extends Bloc<VerifyOtpEvent, VerifyOtpState> {
  final VerifyOtpUseCase? _verifyOtpUseCase;
  final SendOtpUseCase? _sendOtpUseCase;

  VerifyOtpUseCase get verifyOtpUseCase =>
      _verifyOtpUseCase ?? getIt<VerifyOtpUseCase>();
  SendOtpUseCase get sendOtpUseCase =>
      _sendOtpUseCase ?? getIt<SendOtpUseCase>();

  VerifyOtpBloc([
    VerifyOtpUseCase? verifyOtpUseCase,
    SendOtpUseCase? sendOtpUseCase,
  ])  : _verifyOtpUseCase = verifyOtpUseCase,
        _sendOtpUseCase = sendOtpUseCase,
        super(VerifyOtpInitialState()) {
    on<VerifyOtpSubmitEvent>(_onVerifyOtp);
    on<VerifyOtpResendEvent>(_onResendOtp);
  }

  Future<void> _onVerifyOtp(
    VerifyOtpSubmitEvent event,
    Emitter<VerifyOtpState> emit,
  ) async {
    emit(VerifyOtpLoadingState());

    final result = await verifyOtpUseCase.call(
      VerifyOtpParams(
        mobile: event.mobile,
        otp: event.otp,
      ),
    );

    result.fold(
      (l) => emit(VerifyOtpFailureState(l.message)),
      (r) => emit(VerifyOtpSuccessState(r)),
    );
  }

  Future<void> _onResendOtp(
    VerifyOtpResendEvent event,
    Emitter<VerifyOtpState> emit,
  ) async {
    emit(VerifyOtpLoadingState());

    final result = await sendOtpUseCase.call(
      SendOtpParams(
        mobile: event.mobile,
      ),
    );

    result.fold(
      (l) => emit(VerifyOtpFailureState(l.message)),
      (r) => emit(
        VerifyOtpResendSuccessState(
          r.message.isNotEmpty ? r.message : 'OTP sent successfully',
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE VerifyOtpBloc =====");
    return super.close();
  }
}
