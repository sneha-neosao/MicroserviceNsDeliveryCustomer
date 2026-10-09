part of 'add_address_form_bloc.dart';

sealed class AddAddressFormEvent extends Equatable {
  const AddAddressFormEvent();

  @override
  List<Object?> get props => [];
}

class AddAddressFormInitializeEvent extends AddAddressFormEvent {
  final String? label;
  final String? addressLine;
  final String? landmark;
  final String? city;
  final String? pincode;
  final bool? isDefault;
  final String? lat;
  final String? lng;
  final String? deliveryName;
  final String? deliveryPhone;

  const AddAddressFormInitializeEvent({
    this.label,
    this.addressLine,
    this.landmark,
    this.city,
    this.pincode,
    this.isDefault,
    this.lat,
    this.lng,
    this.deliveryName,
    this.deliveryPhone,
  });

  @override
  List<Object?> get props => [
        label,
        addressLine,
        landmark,
        city,
        pincode,
        isDefault,
        lat,
        lng,
        deliveryName,
        deliveryPhone,
      ];
}

class AddAddressFormLabelChangedEvent extends AddAddressFormEvent {
  final String label;
  const AddAddressFormLabelChangedEvent(this.label);

  @override
  List<Object?> get props => [label];
}

class AddAddressFormAddressLineChangedEvent extends AddAddressFormEvent {
  final String addressLine;
  const AddAddressFormAddressLineChangedEvent(this.addressLine);

  @override
  List<Object?> get props => [addressLine];
}

class AddAddressFormLandmarkChangedEvent extends AddAddressFormEvent {
  final String landmark;
  const AddAddressFormLandmarkChangedEvent(this.landmark);

  @override
  List<Object?> get props => [landmark];
}

class AddAddressFormCityChangedEvent extends AddAddressFormEvent {
  final String city;
  const AddAddressFormCityChangedEvent(this.city);

  @override
  List<Object?> get props => [city];
}

class AddAddressFormPincodeChangedEvent extends AddAddressFormEvent {
  final String pincode;
  const AddAddressFormPincodeChangedEvent(this.pincode);

  @override
  List<Object?> get props => [pincode];
}

class AddAddressFormDefaultChangedEvent extends AddAddressFormEvent {
  final bool isDefault;
  const AddAddressFormDefaultChangedEvent(this.isDefault);

  @override
  List<Object?> get props => [isDefault];
}

class AddAddressFormCoordinatesChangedEvent extends AddAddressFormEvent {
  final String lat;
  final String lng;
  const AddAddressFormCoordinatesChangedEvent(this.lat, this.lng);

  @override
  List<Object?> get props => [lat, lng];
}
