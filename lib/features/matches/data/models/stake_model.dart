import 'package:flutter/foundation.dart';

@immutable
class StakeModel {
  final String stakeId;
  final String matchId;
  final String stakerId;
  final String playerStakedOnId;
  final double amount;
  final bool hasPaidOut;

  const StakeModel({
    required this.stakeId,
    required this.matchId,
    required this.stakerId,
    required this.playerStakedOnId,
    required this.amount,
    this.hasPaidOut = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'stakeId': stakeId,
      'matchId': matchId,
      'stakerId': stakerId,
      'playerStakedOnId': playerStakedOnId,
      'amount': amount,
      'hasPaidOut': hasPaidOut,
    };
  }

  factory StakeModel.fromMap(Map<String, dynamic> map) {
    return StakeModel(
      stakeId: map['stakeId'] ?? '',
      matchId: map['matchId'] ?? '',
      stakerId: map['stakerId'] ?? '',
      playerStakedOnId: map['playerStakedOnId'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      hasPaidOut: map['hasPaidOut'] ?? false,
    );
  }
}
