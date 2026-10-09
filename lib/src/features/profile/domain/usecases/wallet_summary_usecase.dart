import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../remote/models/wallet_model/wallet_summary_response.dart';
import '../../../../remote/repositories/repository_impl.dart';

/// Use case for fetching the customer's wallet summary matching:
/// GET /api/v1/web/summary
class WalletSummaryUseCase implements UseCase<WalletSummaryResponse, NoParams> {
  final Repository _repository;

  const WalletSummaryUseCase(this._repository);

  @override
  Future<Either<Failure, WalletSummaryResponse>> call(NoParams params) async {
    return await _repository.wallet_summary();
  }
}
