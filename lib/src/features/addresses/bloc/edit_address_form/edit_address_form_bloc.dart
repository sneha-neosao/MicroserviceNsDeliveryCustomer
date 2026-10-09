import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';

part 'edit_address_form_event.dart';
part 'edit_address_form_state.dart';

/// Handles validation logic for **Edit Address Form Inputs**.
class EditAddressFormBloc
    extends Bloc<EditAddressFormEvent, EditAddressFormState> {
  EditAddressFormBloc() : super(const EditAddressFormInitialState()) {
    on<EditAddressFormInitializeEvent>(_onInitialize);
    on<EditAddressFormLabelChangedEvent>(_onLabelChanged);
    on<EditAddressFormAddressLineChangedEvent>(_onAddressLineChanged);
    on<EditAddressFormLandmarkChangedEvent>(_onLandmarkChanged);
    on<EditAddressFormCityChangedEvent>(_onCityChanged);
    on<EditAddressFormPincodeChangedEvent>(_onPincodeChanged);
    on<EditAddressFormDefaultChangedEvent>(_onDefaultChanged);
    on<EditAddressFormCoordinatesChangedEvent>(_onCoordinatesChanged);
  }

  Future<void> _onInitialize(
    EditAddressFormInitializeEvent event,
    Emitter<EditAddressFormState> emit,
  ) async {
    final publicId = event.publicId ?? state.publicId;
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
      EditAddressFormDataState(
        inputPublicId: publicId,
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
    EditAddressFormLabelChangedEvent event,
    Emitter<EditAddressFormState> emit,
  ) async {
    emit(
      EditAddressFormDataState(
        inputPublicId: state.publicId,
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
    EditAddressFormAddressLineChangedEvent event,
    Emitter<EditAddressFormState> emit,
  ) async {
    emit(
      EditAddressFormDataState(
        inputPublicId: state.publicId,
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
    EditAddressFormLandmarkChangedEvent event,
    Emitter<EditAddressFormState> emit,
  ) async {
    emit(
      EditAddressFormDataState(
        inputPublicId: state.publicId,
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
    EditAddressFormCityChangedEvent event,
    Emitter<EditAddressFormState> emit,
  ) async {
    emit(
      EditAddressFormDataState(
        inputPublicId: state.publicId,
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
    EditAddressFormPincodeChangedEvent event,
    Emitter<EditAddressFormState> emit,
  ) async {
    emit(
      EditAddressFormDataState(
        inputPublicId: state.publicId,
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
    EditAddressFormDefaultChangedEvent event,
    Emitter<EditAddressFormState> emit,
  ) async {
    emit(
      EditAddressFormDataState(
        inputPublicId: state.publicId,
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
    EditAddressFormCoordinatesChangedEvent event,
    Emitter<EditAddressFormState> emit,
  ) async {
    emit(
      EditAddressFormDataState(
        inputPublicId: state.publicId,
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
    final validLabel = label.trim().isNotEmpty;
    final validAddressLine = addressLine.trim().isNotEmpty && addressLine.trim().length >= 3;
    final validCity = city.trim().isNotEmpty;
    final validPin = pincode.trim().length == 6 && int.tryParse(pincode.trim()) != null;
    final validCoords = lat.trim().isNotEmpty && lng.trim().isNotEmpty;

    return validLabel && validAddressLine && validCity && validPin && validCoords;
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE EditAddressFormBloc =====");
    return super.close();
  }
}
