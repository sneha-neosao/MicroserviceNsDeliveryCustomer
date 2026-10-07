import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../remote/models/address_model/address_list_response.dart';
import '../../../../remote/repositories/repository_impl.dart';

/// Use case for fetching the customer's saved address list.
class AddressListUseCase implements UseCase<AddressListResponse, NoParams> {
  final Repository _repository;

  const AddressListUseCase(this._repository);

  @override
  Future<Either<Failure, AddressListResponse>> call(NoParams params) async {
    return await _repository.address_list();
  }
}
