part of 'register_form_bloc.dart';

/// Base class for all register form input events
sealed class RegisterFormEvent extends Equatable {
  const RegisterFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initializer event to populate fields if needed (e.g. contact from previous screen)
class RegisterFormInitializeEvent extends RegisterFormEvent {
  final String? name;
  final String? email;
  final String? contact;

  const RegisterFormInitializeEvent({
    this.name,
    this.email,
    this.contact,
  });

  @override
  List<Object?> get props => [name, email, contact];
}

/// Listens for changes in name input
class RegisterFormNameChangedEvent extends RegisterFormEvent {
  final String name;

  const RegisterFormNameChangedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

/// Listens for changes in email input
class RegisterFormEmailChangedEvent extends RegisterFormEvent {
  final String email;

  const RegisterFormEmailChangedEvent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Listens for changes in contact/mobile input
class RegisterFormContactChangedEvent extends RegisterFormEvent {
  final String contact;

  const RegisterFormContactChangedEvent(this.contact);

  @override
  List<Object?> get props => [contact];
}
