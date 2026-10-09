import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../remote/models/home_model/home_response.dart';
import '../../../../remote/repositories/repository_impl.dart';

/// Parameters for fetching Home page data matching:
/// GET /web/home?offset=1&limit=10&lat=...&lng=...
class HomeParams extends Equatable {
  final int offset;
  final int limit;
  final double? lat;
  final double? lng;

  const HomeParams({
    this.offset = 1,
    this.limit = 10,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [offset, limit, lat, lng];
}

/// Use case for fetching Home page data
class HomeUseCase implements UseCase<HomeResponse, HomeParams> {
  final Repository _repository;

  const HomeUseCase(this._repository);

  @override
  Future<Either<Failure, HomeResponse>> call(HomeParams params) async {
    return await _repository.home_data(params);
  }
}
