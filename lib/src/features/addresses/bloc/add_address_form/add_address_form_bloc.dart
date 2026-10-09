import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';

part 'add_address_form_event.dart';
part 'add_address_form_state.dart';

/// Handles validation logic for **Add Address Form Inputs**.
class AddAddressFormBloc
    extends Bloc<AddAddressFormEvent, AddAddressFormState> {
  AddAddressFormBloc() : super(const AddAddressFormInitialState()) {
    on<AddAddressFormInitializeEvent>(_onInitialize);
    on<AddAddressFormLabelChangedEvent>(_onLabelChanged);
    on<AddAddressFormAddressLineChangedEvent>(_onAddressLineChanged);
    on<AddAddressFormLandmarkChangedEvent>(_onLandmarkChanged);
    on<AddAddressFormCityChangedEvent>(_onCityChanged);
    on<AddAddressFormPincodeChangedEvent>(_onPincodeChanged);
    on<AddAddressFormDefaultChangedEvent>(_onDefaultChanged);
    on<AddAddressFormCoordinatesChangedEvent>(_onCoordinatesChanged);
  }

  Future<void> _onInitialize(
    AddAddressFormInitializeEvent event,
    Emitter<AddAddressFormState> emit,
  ) async {
    final label = event.label ?? state.label;
    final addressLine = event.addressLine ?? state.addressLine;
    final landmark = event.landmark ?? state.landmark;
    final city = event.city ?? state.city;
    final pincode = event.pincode ?? state.pincode;
    final isDefault = event.isDefault ?? state.isDefault;
    final lat = event.lat ?? state.lat;
    final lng = event.lng ?? state.lng;
    final deliveryName = event.deliveryName ?? state.deliveryName;
    final deliveryPhone = event.deliveryPhone ?? state.deliveryPhone;

    emit(
      AddAddressFormDataState(
        inputLabel: label,
        inputAddressLine: addressLine,
        inputLandmark: landmark,
        inputCity: city,
        inputPincode: pincode,
        inputIsDefault: isDefault,
        inputLat: lat,
        inputLng: lng,
        inputDeliveryName: deliveryName,
        inputDeliveryPhone: deliveryPhone,
        inputIsValid: validateInputs(
          label: label,
          addressLine: addressLine,
          city: city,
          pincode: pincode,
          lat: lat,
          lng: lng,
        ),
      ),
    );
  }

  Future<void> _onLabelChanged(
    AddAddressFormLabelChangedEvent event,
    Emitter<AddAddressFormState> emit,
  ) async {
    emit(
      AddAddressFormDataState(
        inputLabel: event.label,
        inputAddressLine: state.addressLine,
        inputLandmark: state.landmark,
        inputCity: state.city,
        inputPincode: state.pincode,
        inputIsDefault: state.isDefault,
        inputLat: state.lat,
        inputLng: state.lng,
        inputDeliveryName: state.deliveryName,
        inputDeliveryPhone: state.deliveryPhone,
        inputIsValid: validateInputs(
          label: event.label,
          addressLine: state.addressLine,
          city: state.city,
          pincode: state.pincode,
          lat: state.lat,
          lng: state.lng,
        ),
      ),
    );
  }

  Future<void> _onAddressLineChanged(
    AddAddressFormAddressLineChangedEvent event,
    Emitter<AddAddressFormState> emit,
  ) async {
    emit(
      AddAddressFormDataState(
        inputLabel: state.label,
        inputAddressLine: event.addressLine,
        inputLandmark: state.landmark,
        inputCity: state.city,
        inputPincode: state.pincode,
        inputIsDefault: state.isDefault,
        inputLat: state.lat,
        inputLng: state.lng,
        inputDeliveryName: state.deliveryName,
        inputDeliveryPhone: state.deliveryPhone,
        inputIsValid: validateInputs(
          label: state.label,
          addressLine: event.addressLine,
          city: state.city,
          pincode: state.pincode,
          lat: state.lat,
          lng: state.lng,
        ),
      ),
    );
  }

  Future<void> _onLandmarkChanged(
    AddAddressFormLandmarkChangedEvent event,
    Emitter<AddAddressFormState> emit,
  ) async {
    emit(
      AddAddressFormDataState(
        inputLabel: state.label,
        inputAddressLine: state.addressLine,
        inputLandmark: event.landmark,
        inputCity: state.city,
        inputPincode: state.pincode,
        inputIsDefault: state.isDefault,
        inputLat: state.lat,
        inputLng: state.lng,
        inputDeliveryName: state.deliveryName,
        inputDeliveryPhone: state.deliveryPhone,
        inputIsValid: validateInputs(
          label: state.label,
          addressLine: state.addressLine,
          city: state.city,
          pincode: state.pincode,
          lat: state.lat,
          lng: state.lng,
        ),
      ),
    );
  }

  Future<void> _onCityChanged(
    AddAddressFormCityChangedEvent event,
    Emitter<AddAddressFormState> emit,
  ) async {
    emit(
      AddAddressFormDataState(
        inputLabel: state.label,
        inputAddressLine: state.addressLine,
        inputLandmark: state.landmark,
        inputCity: event.city,
        inputPincode: state.pincode,
        inputIsDefault: state.isDefault,
        inputLat: state.lat,
        inputLng: state.lng,
        inputDeliveryName: state.deliveryName,
        inputDeliveryPhone: state.deliveryPhone,
        inputIsValid: validateInputs(
          label: state.label,
          addressLine: state.addressLine,
          city: event.city,
          pincode: state.pincode,
          lat: state.lat,
          lng: state.lng,
        ),
      ),
    );
  }

  Future<void> _onPincodeChanged(
    AddAddressFormPincodeChangedEvent event,
    Emitter<AddAddressFormState> emit,
  ) async {
    emit(
      AddAddressFormDataState(
        inputLabel: state.label,
        inputAddressLine: state.addressLine,
        inputLandmark: state.landmark,
        inputCity: state.city,
        inputPincode: event.pincode,
        inputIsDefault: state.isDefault,
        inputLat: state.lat,
        inputLng: state.lng,
        inputDeliveryName: state.deliveryName,
        inputDeliveryPhone: state.deliveryPhone,
        inputIsValid: validateInputs(
          label: state.label,
          addressLine: state.addressLine,
          city: state.city,
          pincode: event.pincode,
          lat: state.lat,
          lng: state.lng,
        ),
      ),
    );
  }

  Future<void> _onDefaultChanged(
    AddAddressFormDefaultChangedEvent event,
    Emitter<AddAddressFormState> emit,
  ) async {
    emit(
      AddAddressFormDataState(
        inputLabel: state.label,
        inputAddressLine: state.addressLine,
        inputLandmark: state.landmark,
        inputCity: state.city,
        inputPincode: state.pincode,
        inputIsDefault: event.isDefault,
        inputLat: state.lat,
        inputLng: state.lng,
        inputDeliveryName: state.deliveryName,
        inputDeliveryPhone: state.deliveryPhone,
        inputIsValid: validateInputs(
          label: state.label,
          addressLine: state.addressLine,
          city: state.city,
          pincode: state.pincode,
          lat: state.lat,
          lng: state.lng,
        ),
      ),
    );
  }

  Future<void> _onCoordinatesChanged(
    AddAddressFormCoordinatesChangedEvent event,
    Emitter<AddAddressFormState> emit,
  ) async {
    emit(
      AddAddressFormDataState(
        inputLabel: state.label,
        inputAddressLine: state.addressLine,
        inputLandmark: state.landmark,
        inputCity: state.city,
        inputPincode: state.pincode,
        inputIsDefault: state.isDefault,
        inputLat: event.lat,
        inputLng: event.lng,
        inputDeliveryName: state.deliveryName,
        inputDeliveryPhone: state.deliveryPhone,
        inputIsValid: validateInputs(
          label: state.label,
          addressLine: state.addressLine,
          city: state.city,
          pincode: state.pincode,
          lat: event.lat,
          lng: event.lng,
        ),
      ),
    );
  }

  bool validateInputs({
    required String label,
    required String addressLine,
    required String city,
    required String pincode,
    required String lat,
    required String lng,
  }) {
    final cleanLabel = label.toLowerCase().trim();
    final isLabelValid = cleanLabel == 'home' ||
        cleanLabel == 'office' ||
        cleanLabel == 'other';
    final isAddressValid = addressLine.trim().isNotEmpty;
    final isCityValid = city.trim().isNotEmpty;
    final isPinValid =
        pincode.trim().length == 6 && int.tryParse(pincode.trim()) != null;
    final isCoordsValid = lat.trim().isNotEmpty && lng.trim().isNotEmpty;

    return isLabelValid &&
        isAddressValid &&
        isCityValid &&
        isPinValid &&
        isCoordsValid;
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE AddAddressFormBloc =====");
    return super.close();
  }
}
