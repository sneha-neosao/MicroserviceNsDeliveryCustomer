import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../remote/models/address_model/update_address_response.dart';
import '../../../../remote/repositories/repository_impl.dart';

/// Parameters for updating an existing delivery address matching the cURL specification:
/// PUT /web/address/update?public_id={public_id}
class EditAddressParams extends Equatable {
  final String publicId;
  final String label;
  final String deliveryName;
  final String deliveryPhone;
  final String addressLine;
  final String? landmark;
  final String city;
  final String pincode;
  final double lat;
  final double lng;
  final bool isDefault;

  const EditAddressParams({
    required this.publicId,
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
        'lat': lat,
        'lng': lng,
        'is_default': isDefault,
      };

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

/// Use case for editing/updating an existing customer delivery address.
class EditAddressUseCase implements UseCase<UpdateAddressResponse, EditAddressParams> {
  final Repository _repository;

  const EditAddressUseCase(this._repository);

  @override
  Future<Either<Failure, UpdateAddressResponse>> call(
      EditAddressParams params) async {
    // 1. Validation for public_id
    if (params.publicId.trim().isEmpty) {
      return Left(ApiFailure("Address public_id is required"));
    }

    // 2. Validation for label: must be home, office, or other
    final cleanLabel = params.label.toLowerCase().trim();
    if (cleanLabel.isEmpty) {
      return Left(ApiFailure("Please select address type (Home, Office, or Other)"));
    }
    if (cleanLabel != 'home' &&
        cleanLabel != 'office' &&
        cleanLabel != 'other') {
      return Left(ApiFailure("Label must be either Home, Office, or Other"));
    }

    // 3. Validation for delivery name
    if (params.deliveryName.trim().isEmpty) {
      return Left(ApiFailure("Delivery customer name is required"));
    }

    // 4. Validation for delivery phone
    if (params.deliveryPhone.trim().isEmpty) {
      return Left(ApiFailure("Delivery phone number is required"));
    }

    // 5. Validation for address line
    if (params.addressLine.trim().isEmpty) {
      return Left(ApiFailure("Please enter House/Building No., Lane & Street"));
    }

    // 6. Validation for city
    if (params.city.trim().isEmpty) {
      return Left(ApiFailure("Please enter city"));
    }

    // 7. Validation for pincode (must be exactly 6 digits)
    final cleanPin = params.pincode.trim();
    if (cleanPin.isEmpty) {
      return Left(ApiFailure("Please enter pincode"));
    }
    if (cleanPin.length != 6 || int.tryParse(cleanPin) == null) {
      return Left(ApiFailure("Please enter a valid 6-digit pincode"));
    }

    // 8. Validation for coordinates
    if (params.lat == 0.0 || params.lng == 0.0) {
      return Left(ApiFailure("Valid pin location coordinates are required"));
    }

    return await _repository.edit_address(params);
  }
}
