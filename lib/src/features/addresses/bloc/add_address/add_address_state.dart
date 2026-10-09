part of 'add_address_bloc.dart';

sealed class AddAddressState extends Equatable {
  const AddAddressState();

  @override
  List<Object?> get props => [];
}

class AddAddressInitialState extends AddAddressState {}

class AddAddressLoadingState extends AddAddressState {}

class AddAddressSuccessState extends AddAddressState {
  final AddAddressResponse data;

  const AddAddressSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class AddAddressFailureState extends AddAddressState {
  final String message;

  const AddAddressFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
