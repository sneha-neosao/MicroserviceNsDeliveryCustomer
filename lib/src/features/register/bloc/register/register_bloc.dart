import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/utils/failure_converter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../remote/models/auth_model/register_response.dart';
import '../../domain/usecases/register_usecase.dart';

part 'register_event.dart';
part 'register_state.dart';

/// Handles state management for **Register** API execution.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase? _registerUseCase;

  RegisterUseCase get registerUseCase =>
      _registerUseCase ?? getIt<RegisterUseCase>();

  RegisterBloc([RegisterUseCase? registerUseCase])
      : _registerUseCase = registerUseCase,
        super(RegisterInitialState()) {
    on<RegisterSubmitEvent>(_onRegisterSubmit);
  }

  Future<void> _onRegisterSubmit(
    RegisterSubmitEvent event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoadingState());

    final result = await registerUseCase.call(
      RegisterParams(
        name: event.name,
        email: event.email,
        contact: event.contact,
      ),
    );

    result.fold(
      (failure) => emit(
        RegisterFailureState(
          failure.message.isNotEmpty
              ? failure.message
              : mapFailureToMessage(failure),
        ),
      ),
      (response) => emit(RegisterSuccessState(response)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE RegisterBloc =====");
    return super.close();
  }
}
