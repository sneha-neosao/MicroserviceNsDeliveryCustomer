import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../remote/models/profile_model/profile_response.dart';
import '../../../../remote/repositories/repository_impl.dart';

/// Use case for fetching the customer's profile details matching:
/// GET /api/v1/web/profile
class ProfileDetailsUseCase implements UseCase<ProfileResponse, NoParams> {
  final Repository _repository;

  const ProfileDetailsUseCase(this._repository);

  @override
  Future<Either<Failure, ProfileResponse>> call(NoParams params) async {
    return await _repository.profile_details();
  }
}
