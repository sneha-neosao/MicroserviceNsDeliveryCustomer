part of 'edit_address_bloc.dart';

sealed class EditAddressState extends Equatable {
  const EditAddressState();

  @override
  List<Object?> get props => [];
}

class EditAddressInitialState extends EditAddressState {}

class EditAddressLoadingState extends EditAddressState {}

class EditAddressSuccessState extends EditAddressState {
  final UpdateAddressResponse data;

  const EditAddressSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class EditAddressFailureState extends EditAddressState {
  final String message;

  const EditAddressFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
