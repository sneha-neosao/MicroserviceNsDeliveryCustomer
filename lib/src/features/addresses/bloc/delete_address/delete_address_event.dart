part of 'delete_address_bloc.dart';

sealed class DeleteAddressEvent extends Equatable {
  const DeleteAddressEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user confirms deleting an address
class DeleteAddressSubmitEvent extends DeleteAddressEvent {
  final String publicId;

  const DeleteAddressSubmitEvent({required this.publicId});

  @override
  List<Object?> get props => [publicId];
}
