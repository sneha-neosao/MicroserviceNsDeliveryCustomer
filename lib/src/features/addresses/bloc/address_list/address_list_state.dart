part of 'address_list_bloc.dart';

sealed class AddressListState extends Equatable {
  const AddressListState();

  @override
  List<Object?> get props => [];
}

class AddressListInitialState extends AddressListState {}

class AddressListLoadingState extends AddressListState {}

class AddressListSuccessState extends AddressListState {
  final AddressListResponse data;

  const AddressListSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class AddressListFailureState extends AddressListState {
  final String message;

  const AddressListFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
