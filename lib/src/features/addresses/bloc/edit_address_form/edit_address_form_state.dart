part of 'edit_address_form_bloc.dart';

/// Base state for Edit Address Form Validation BLoC.
sealed class EditAddressFormState extends Equatable {
  final String publicId;
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

  const EditAddressFormState({
    required this.publicId,
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
        publicId,
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

/// Initial form state
class EditAddressFormInitialState extends EditAddressFormState {
  const EditAddressFormInitialState({
    String initialPublicId = '',
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
          publicId: initialPublicId,
          label: initialLabel,
          deliveryName: initialDeliveryName,
          deliveryPhone: initialDeliveryPhone,
          addressLine: initialAddressLine,
          landmark: initialLandmark,
          city: initialCity,
          pincode: initialPincode,
          lat: initialLat,
          lng: initialLng,
          isDefault: initialIsDefault,
          isValid: false,
        );
}

/// Validated form data state representing current snapshot
class EditAddressFormDataState extends EditAddressFormState {
  const EditAddressFormDataState({
    required String inputPublicId,
    required String inputLabel,
    required String inputAddressLine,
    required String inputLandmark,
    required String inputCity,
    required String inputPincode,
    required bool inputIsDefault,
    required String inputLat,
    required String inputLng,
    required String inputDeliveryName,
    required String inputDeliveryPhone,
    required bool inputIsValid,
  }) : super(
          publicId: inputPublicId,
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
}
