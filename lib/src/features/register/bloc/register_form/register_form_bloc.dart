import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/string_validator_extension.dart';
import '../../../../core/utils/logger.dart';

part 'register_form_event.dart';
part 'register_form_state.dart';

/// Handles validation logic for **Register Form Inputs**.
class RegisterFormBloc extends Bloc<RegisterFormEvent, RegisterFormState> {
  RegisterFormBloc() : super(const RegisterFormInitialState()) {
    on<RegisterFormInitializeEvent>(_onInitialize);
    on<RegisterFormNameChangedEvent>(_onNameChanged);
    on<RegisterFormEmailChangedEvent>(_onEmailChanged);
    on<RegisterFormContactChangedEvent>(_onContactChanged);
  }

  Future<void> _onInitialize(
    RegisterFormInitializeEvent event,
    Emitter<RegisterFormState> emit,
  ) async {
    final name = event.name ?? state.name;
    final email = event.email ?? state.email;
    final contact = event.contact ?? state.contact;

    emit(
      RegisterFormDataState(
        inputName: name,
        inputEmail: email,
        inputContact: contact,
        inputIsValid: validateInputs(name, email, contact),
      ),
    );
  }

  Future<void> _onNameChanged(
    RegisterFormNameChangedEvent event,
    Emitter<RegisterFormState> emit,
  ) async {
    emit(
      RegisterFormDataState(
        inputName: event.name,
        inputEmail: state.email,
        inputContact: state.contact,
        inputIsValid: validateInputs(event.name, state.email, state.contact),
      ),
    );
  }

  Future<void> _onEmailChanged(
    RegisterFormEmailChangedEvent event,
    Emitter<RegisterFormState> emit,
  ) async {
    emit(
      RegisterFormDataState(
        inputName: state.name,
        inputEmail: event.email,
        inputContact: state.contact,
        inputIsValid: validateInputs(state.name, event.email, state.contact),
      ),
    );
  }

  Future<void> _onContactChanged(
    RegisterFormContactChangedEvent event,
    Emitter<RegisterFormState> emit,
  ) async {
    emit(
      RegisterFormDataState(
        inputName: state.name,
        inputEmail: state.email,
        inputContact: event.contact,
        inputIsValid: validateInputs(state.name, state.email, event.contact),
      ),
    );
  }

  bool validateInputs(String name, String email, String contact) {
    final isNameValid = name.trim().isNotEmpty;
    final isContactValid = contact.trim().isNotEmpty && contact.trim().isMobileNumberValid;
    final isEmailValid = email.trim().isEmpty || email.trim().isEmailValid;

    return isNameValid && isContactValid && isEmailValid;
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE RegisterFormBloc =====");
    return super.close();
  }
}
