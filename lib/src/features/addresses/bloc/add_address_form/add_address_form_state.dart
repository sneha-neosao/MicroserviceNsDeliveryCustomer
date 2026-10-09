part of 'add_address_form_bloc.dart';

/// Base state for Add Address Form Validation BLoC.
sealed class AddAddressFormState extends Equatable {
  final String label;
  final String addressLine;
  final String landmark;
  final String city;
  final String pincode;
  final bool isDefault;
  final String lat;
  final String lng;
  final String deliveryName;
  final String deliveryPhone;
  final bool isValid;

  const AddAddressFormState({
    required this.label,
    required this.addressLine,
    required this.landmark,
    required this.city,
    required this.pincode,
    required this.isDefault,
    required this.lat,
    required this.lng,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.isValid,
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
        isValid,
      ];
}

/// Initial empty form state
class AddAddressFormInitialState extends AddAddressFormState {
  const AddAddressFormInitialState({
    String initialLabel = 'home',
    String initialDeliveryName = '',
    String initialDeliveryPhone = '',
    String initialAddressLine = '',
    String initialLandmark = '',
    String initialCity = '',
    String initialPincode = '',
    String initialLat = '',
    String initialLng = '',
    bool initialIsDefault = false,
  }) : super(
          label: initialLabel,
          addressLine: initialAddressLine,
          landmark: initialLandmark,
          city: initialCity,
          pincode: initialPincode,
          isDefault: initialIsDefault,
          lat: initialLat,
          lng: initialLng,
          deliveryName: initialDeliveryName,
          deliveryPhone: initialDeliveryPhone,
          isValid: false,
        );
}

/// Validated form data state representing current input snapshot
class AddAddressFormDataState extends AddAddressFormState {
  final String inputLabel;
  final String inputAddressLine;
  final String inputLandmark;
  final String inputCity;
  final String inputPincode;
  final bool inputIsDefault;
  final String inputLat;
  final String inputLng;
  final String inputDeliveryName;
  final String inputDeliveryPhone;
  final bool inputIsValid;

  const AddAddressFormDataState({
    required this.inputLabel,
    required this.inputAddressLine,
    required this.inputLandmark,
    required this.inputCity,
    required this.inputPincode,
    required this.inputIsDefault,
    required this.inputLat,
    required this.inputLng,
    required this.inputDeliveryName,
    required this.inputDeliveryPhone,
    required this.inputIsValid,
  }) : super(
          label: inputLabel,
          addressLine: inputAddressLine,
          landmark: inputLandmark,
          city: inputCity,
          pincode: inputPincode,
          isDefault: inputIsDefault,
          lat: inputLat,
          lng: inputLng,
          deliveryName: inputDeliveryName,
          deliveryPhone: inputDeliveryPhone,
          isValid: inputIsValid,
        );

  @override
  List<Object?> get props => [
        inputLabel,
        inputAddressLine,
        inputLandmark,
        inputCity,
        inputPincode,
        inputIsDefault,
        inputLat,
        inputLng,
        inputDeliveryName,
        inputDeliveryPhone,
        inputIsValid,
      ];
}
