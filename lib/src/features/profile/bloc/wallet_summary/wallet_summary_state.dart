part of 'wallet_summary_bloc.dart';

sealed class WalletSummaryState extends Equatable {
  const WalletSummaryState();

  @override
  List<Object?> get props => [];
}

class WalletSummaryInitialState extends WalletSummaryState {}

class WalletSummaryLoadingState extends WalletSummaryState {}

class WalletSummarySuccessState extends WalletSummaryState {
  final WalletSummaryResponse data;

  const WalletSummarySuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class WalletSummaryFailureState extends WalletSummaryState {
  final String message;

  const WalletSummaryFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
