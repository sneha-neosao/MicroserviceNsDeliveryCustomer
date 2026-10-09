import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../remote/models/address_model/add_address_response.dart';
import '../../../../remote/repositories/repository_impl.dart';

/// Parameters for adding a new delivery address.
class AddAddressParams extends Equatable {
  final String label;
  final String deliveryName;
  final String deliveryPhone;
  final String addressLine;
  final String? landmark;
  final String city;
  final String pincode;
  final String lat;
  final String lng;
  final bool isDefault;

  const AddAddressParams({
    required this.label,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.addressLine,
    this.landmark,
    required this.city,
    required this.pincode,
    required this.lat,
    required this.lng,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'label': label.toLowerCase().trim(),
        'delivery_name': deliveryName.trim(),
        'delivery_phone': deliveryPhone.trim(),
        'address_line': addressLine.trim(),
        'landmark': landmark?.trim() ?? '',
        'city': city.trim(),
        'pincode': pincode.trim(),
        'lat': lat.trim(),
        'lng': lng.trim(),
        'is_default': isDefault,
      };

  @override
  List<Object?> get props => [
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

/// Use case for adding a new customer delivery address with strict business validation.
class AddAddressUseCase implements UseCase<AddAddressResponse, AddAddressParams> {
  final Repository _repository;

  const AddAddressUseCase(this._repository);

  @override
  Future<Either<Failure, AddAddressResponse>> call(
      AddAddressParams params) async {
    // 1. Validation for label: must be home, office, or other
    final cleanLabel = params.label.toLowerCase().trim();
    if (cleanLabel.isEmpty) {
      return Left(ApiFailure("Please select address type (Home, Office, or Other)"));
    }
    if (cleanLabel != 'home' &&
        cleanLabel != 'office' &&
        cleanLabel != 'other') {
      return Left(ApiFailure("Label must be either Home, Office, or Other"));
    }

    // 2. Validation for delivery name
    if (params.deliveryName.trim().isEmpty) {
      return Left(ApiFailure("Delivery customer name is required"));
    }

    // 3. Validation for delivery phone
    if (params.deliveryPhone.trim().isEmpty) {
      return Left(ApiFailure("Delivery phone number is required"));
    }

    // 4. Validation for address line
    if (params.addressLine.trim().isEmpty) {
      return Left(ApiFailure("Please enter House/Building No., Lane & Street"));
    }

    // 5. Validation for city
    if (params.city.trim().isEmpty) {
      return Left(ApiFailure("Please enter city"));
    }

    // 6. Validation for pincode (must be exactly 6 digits)
    final cleanPin = params.pincode.trim();
    if (cleanPin.isEmpty) {
      return Left(ApiFailure("Please enter pincode"));
    }
    if (cleanPin.length != 6 || int.tryParse(cleanPin) == null) {
      return Left(ApiFailure("Please enter a valid 6-digit pincode"));
    }

    // 7. Validation for coordinates
    if (params.lat.trim().isEmpty || params.lng.trim().isEmpty) {
      return Left(ApiFailure("Pin location coordinates are required"));
    }

    return await _repository.add_address(params);
  }
}
