part of 'register_bloc.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitialState extends RegisterState {}

class RegisterLoadingState extends RegisterState {}

class RegisterSuccessState extends RegisterState {
  final RegisterResponse data;

  const RegisterSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class RegisterFailureState extends RegisterState {
  final String message;

  const RegisterFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
