part of 'wallet_summary_bloc.dart';

sealed class WalletSummaryEvent extends Equatable {
  const WalletSummaryEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to fetch the customer's wallet summary
class WalletSummaryGetEvent extends WalletSummaryEvent {}
