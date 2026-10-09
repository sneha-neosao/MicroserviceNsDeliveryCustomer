import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../remote/models/address_model/delete_address_response.dart';
import '../../../../remote/repositories/repository_impl.dart';

/// Parameters for deleting an address matching the cURL specification:
/// DELETE /api/v1/web/address/delete?public_id={public_id}
class DeleteAddressParams extends Equatable {
  final String publicId;

  const DeleteAddressParams({
    required this.publicId,
  });

  @override
  List<Object?> get props => [publicId];
}

/// UseCase handling delete address logic
class DeleteAddressUseCase
    implements UseCase<DeleteAddressResponse, DeleteAddressParams> {
  final Repository _repository;

  DeleteAddressUseCase(this._repository);

  @override
  Future<Either<Failure, DeleteAddressResponse>> call(
      DeleteAddressParams params) async {
    if (params.publicId.trim().isEmpty) {
      return Left(ApiFailure("Address public ID is required"));
    }

    return await _repository.delete_address(params);
  }
}
