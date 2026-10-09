import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/wallet_summary_response.dart';
import '../../domain/usecases/wallet_summary_usecase.dart';

part 'wallet_summary_event.dart';
part 'wallet_summary_state.dart';

/// Handles state management for **Wallet Summary** API execution.
class WalletSummaryBloc extends Bloc<WalletSummaryEvent, WalletSummaryState> {
  final WalletSummaryUseCase _walletSummaryUseCase;

  WalletSummaryBloc(this._walletSummaryUseCase)
      : super(WalletSummaryInitialState()) {
    on<WalletSummaryGetEvent>(_onWalletSummaryGet);
  }

  Future<void> _onWalletSummaryGet(
    WalletSummaryGetEvent event,
    Emitter<WalletSummaryState> emit,
  ) async {
    emit(WalletSummaryLoadingState());

    final result = await _walletSummaryUseCase.call(NoParams());

    result.fold(
      (failure) => emit(WalletSummaryFailureState(failure.message)),
      (response) => emit(WalletSummarySuccessState(response)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE WalletSummaryBloc =====");
    return super.close();
  }
}
