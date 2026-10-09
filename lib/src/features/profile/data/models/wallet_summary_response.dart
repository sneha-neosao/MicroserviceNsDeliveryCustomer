import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Response model for Wallet Summary API:
/// GET /api/v1/web/summary
///
/// Example:
/// {
///   "status": 200,
///   "message": "Wallet summary fetched successfully",
///   "data": {
///     "wallet_balance_points": 0,
///     "wallet_balance_rupees": 0,
///     "total_earned_points": 0,
///     "total_used_points": 0
///   }
/// }
class WalletSummaryResponse extends Equatable {
  final int status;
  final String message;
  final WalletSummaryData? data;

  const WalletSummaryResponse({
    this.status = 0,
    this.message = '',
    this.data,
  });

  factory WalletSummaryResponse.fromRawJson(String str) =>
      WalletSummaryResponse.fromJson(json.decode(str) as Map<String, dynamic>?);

  String toRawJson() => json.encode(toJson());

  factory WalletSummaryResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WalletSummaryResponse();
    return WalletSummaryResponse(
      status: (json['status'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? WalletSummaryData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };

  @override
  List<Object?> get props => [status, message, data];
}

class WalletSummaryData extends Equatable {
  final num walletBalancePoints;
  final num walletBalanceRupees;
  final num totalEarnedPoints;
  final num totalUsedPoints;

  const WalletSummaryData({
    this.walletBalancePoints = 0,
    this.walletBalanceRupees = 0,
    this.totalEarnedPoints = 0,
    this.totalUsedPoints = 0,
  });

  factory WalletSummaryData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WalletSummaryData();
    return WalletSummaryData(
      walletBalancePoints: (json['wallet_balance_points'] as num?) ?? 0,
      walletBalanceRupees: (json['wallet_balance_rupees'] as num?) ?? 0,
      totalEarnedPoints: (json['total_earned_points'] as num?) ?? 0,
      totalUsedPoints: (json['total_used_points'] as num?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'wallet_balance_points': walletBalancePoints,
        'wallet_balance_rupees': walletBalanceRupees,
        'total_earned_points': totalEarnedPoints,
        'total_used_points': totalUsedPoints,
      };

  @override
  List<Object?> get props => [
        walletBalancePoints,
        walletBalanceRupees,
        totalEarnedPoints,
        totalUsedPoints,
      ];
}
