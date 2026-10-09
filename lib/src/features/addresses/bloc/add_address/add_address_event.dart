part of 'add_address_bloc.dart';

sealed class AddAddressEvent extends Equatable {
  const AddAddressEvent();

  @override
  List<Object?> get props => [];
}

class AddAddressSubmitEvent extends AddAddressEvent {
  final AddAddressParams params;

  const AddAddressSubmitEvent(this.params);

  @override
  List<Object?> get props => [params];
}
