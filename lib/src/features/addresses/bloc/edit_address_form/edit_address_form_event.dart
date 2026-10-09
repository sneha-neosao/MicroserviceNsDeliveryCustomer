part of 'edit_address_form_bloc.dart';

/// Base class for all Edit Address form input events
sealed class EditAddressFormEvent extends Equatable {
  const EditAddressFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize form with existing address model and GPS/reverse-geocode coordinates
class EditAddressFormInitializeEvent extends EditAddressFormEvent {
  final String? publicId;
  final String? label;
  final String? deliveryName;
  final String? deliveryPhone;
  final String? addressLine;
  final String? landmark;
  final String? city;
  final String? pincode;
  final String? lat;
  final String? lng;
  final bool? isDefault;

  const EditAddressFormInitializeEvent({
    this.publicId,
    this.label,
    this.deliveryName,
    this.deliveryPhone,
    this.addressLine,
    this.landmark,
    this.city,
    this.pincode,
    this.lat,
    this.lng,
    this.isDefault,
  });

  @override
  List<Object?> get props => [
        publicId,
        label,
        deliveryName,
        deliveryPhone,
        addressLine,
        landmark,
        city,
        pincode,
        lat,
        lng,
        isDefault,
      ];
}

class EditAddressFormLabelChangedEvent extends EditAddressFormEvent {
  final String label;

  const EditAddressFormLabelChangedEvent(this.label);

  @override
  List<Object?> get props => [label];
}

class EditAddressFormAddressLineChangedEvent extends EditAddressFormEvent {
  final String addressLine;

  const EditAddressFormAddressLineChangedEvent(this.addressLine);

  @override
  List<Object?> get props => [addressLine];
}

class EditAddressFormLandmarkChangedEvent extends EditAddressFormEvent {
  final String landmark;

  const EditAddressFormLandmarkChangedEvent(this.landmark);

  @override
  List<Object?> get props => [landmark];
}

class EditAddressFormCityChangedEvent extends EditAddressFormEvent {
  final String city;

  const EditAddressFormCityChangedEvent(this.city);

  @override
  List<Object?> get props => [city];
}

class EditAddressFormPincodeChangedEvent extends EditAddressFormEvent {
  final String pincode;

  const EditAddressFormPincodeChangedEvent(this.pincode);

  @override
  List<Object?> get props => [pincode];
}

class EditAddressFormDefaultChangedEvent extends EditAddressFormEvent {
  final bool isDefault;

  const EditAddressFormDefaultChangedEvent(this.isDefault);

  @override
  List<Object?> get props => [isDefault];
}

class EditAddressFormCoordinatesChangedEvent extends EditAddressFormEvent {
  final String lat;
  final String lng;

  const EditAddressFormCoordinatesChangedEvent({
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [lat, lng];
}
