part of 'delete_address_bloc.dart';

sealed class DeleteAddressState extends Equatable {
  const DeleteAddressState();

  @override
  List<Object?> get props => [];
}

class DeleteAddressInitialState extends DeleteAddressState {}

class DeleteAddressLoadingState extends DeleteAddressState {}

class DeleteAddressSuccessState extends DeleteAddressState {
  final DeleteAddressResponse data;

  const DeleteAddressSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class DeleteAddressFailureState extends DeleteAddressState {
  final String message;

  const DeleteAddressFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
