part of 'address_list_bloc.dart';

sealed class AddressListEvent extends Equatable {
  const AddressListEvent();

  @override
  List<Object?> get props => [];
}

/// Event to trigger fetching the user's addresses
class AddressListGetEvent extends AddressListEvent {}
