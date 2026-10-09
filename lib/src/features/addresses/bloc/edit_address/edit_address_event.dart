part of 'edit_address_bloc.dart';

sealed class EditAddressEvent extends Equatable {
  const EditAddressEvent();

  @override
  List<Object?> get props => [];
}

class EditAddressSubmitEvent extends EditAddressEvent {
  final EditAddressParams params;

  const EditAddressSubmitEvent(this.params);

  @override
  List<Object?> get props => [params];
}
