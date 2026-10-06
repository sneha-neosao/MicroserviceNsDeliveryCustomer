part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitEvent extends RegisterEvent {
  final String name;
  final String? email;
  final String contact;

  const RegisterSubmitEvent({
    required this.name,
    this.email,
    required this.contact,
  });

  @override
  List<Object?> get props => [name, email, contact];
}
