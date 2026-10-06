part of 'register_form_bloc.dart';

/// Base state for Register Form Validation BLoC.
sealed class RegisterFormState extends Equatable {
  final String name;
  final String email;
  final String contact;
  final bool isValid;

  const RegisterFormState({
    required this.name,
    required this.email,
    required this.contact,
    required this.isValid,
  });

  @override
  List<Object?> get props => [name, email, contact, isValid];
}

/// Initial empty form state
class RegisterFormInitialState extends RegisterFormState {
  const RegisterFormInitialState({
    String initialContact = "",
  }) : super(
          name: "",
          email: "",
          contact: initialContact,
          isValid: false,
        );
}

/// Validated form data state representing current input snapshot
class RegisterFormDataState extends RegisterFormState {
  final String inputName;
  final String inputEmail;
  final String inputContact;
  final bool inputIsValid;

  const RegisterFormDataState({
    required this.inputName,
    required this.inputEmail,
    required this.inputContact,
    required this.inputIsValid,
  }) : super(
          name: inputName,
          email: inputEmail,
          contact: inputContact,
          isValid: inputIsValid,
        );

  @override
  List<Object?> get props => [inputName, inputEmail, inputContact, inputIsValid];
}
