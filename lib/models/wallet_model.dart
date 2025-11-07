import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

/// Wallet types
enum WalletKind { live, demo }

class WalletModel {
  final String userId;

  // Live wallet (real money)
  final double balance; // live available
  final double pendingBalance; // live pending
  final double totalDeposited;
  final double totalWithdrawn;
  final double totalWon;
  final double totalLost;

  // Demo wallet (practice funds)
  final double demoBalance;
  final double demoPendingBalance;

  final int loyaltyPoints;
  final String currency;
  final DateTime updatedAt;

  const WalletModel({
    required this.userId,
    required this.balance,
    required this.pendingBalance,
    required this.totalDeposited,
    required this.totalWithdrawn,
    required this.totalWon,
    required this.totalLost,
    required this.demoBalance,
    required this.demoPendingBalance,
    required this.loyaltyPoints,
    this.currency = 'USD',
    required this.updatedAt,
  });

  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel(
      userId: data[WalletDocument.userId] ?? doc.id,
      balance: (data[WalletDocument.balance] ?? 0.0).toDouble(),
      pendingBalance: (data[WalletDocument.pendingBalance] ?? 0.0).toDouble(),
      totalDeposited: (data[WalletDocument.totalDeposited] ?? 0.0).toDouble(),
      totalWithdrawn: (data[WalletDocument.totalWithdrawn] ?? 0.0).toDouble(),
      totalWon: (data[WalletDocument.totalWon] ?? 0.0).toDouble(),
      totalLost: (data[WalletDocument.totalLost] ?? 0.0).toDouble(),
      demoBalance: (data['demo_balance'] ?? 0.0).toDouble(),
      demoPendingBalance: (data['demo_pending_balance'] ?? 0.0).toDouble(),
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      currency: data['currency'] ?? 'USD',
      updatedAt: FirestoreHelpers.timestampToDateTime(data[WalletDocument.updatedAt]) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      WalletDocument.userId: userId,
      WalletDocument.balance: balance,
      WalletDocument.pendingBalance: pendingBalance,
      WalletDocument.totalDeposited: totalDeposited,
      WalletDocument.totalWithdrawn: totalWithdrawn,
      WalletDocument.totalWon: totalWon,
      WalletDocument.totalLost: totalLost,
      'demo_balance': demoBalance,
      'demo_pending_balance': demoPendingBalance,
      'loyaltyPoints': loyaltyPoints,
      'currency': currency,
      WalletDocument.updatedAt: FirestoreHelpers.dateTimeToTimestamp(updatedAt),
    };
  }

  double liveTotalFunds() => balance + pendingBalance;
  double demoTotalFunds() => demoBalance + demoPendingBalance;
  double get liveAvailable => balance;
  double get demoAvailable => demoBalance;
  bool get hasLivePending => pendingBalance > 0;
  bool get hasDemoPending => demoPendingBalance > 0;
  double get netEarnings => totalWon - totalLost;

  WalletModel copyWith({
    double? balance,
    double? pendingBalance,
    double? totalDeposited,
    double? totalWithdrawn,
    double? totalWon,
    double? totalLost,
    double? demoBalance,
    double? demoPendingBalance,
    int? loyaltyPoints,
    String? currency,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      userId: userId,
      balance: balance ?? this.balance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalDeposited: totalDeposited ?? this.totalDeposited,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      totalWon: totalWon ?? this.totalWon,
      totalLost: totalLost ?? this.totalLost,
      demoBalance: demoBalance ?? this.demoBalance,
      demoPendingBalance: demoPendingBalance ?? this.demoPendingBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final double grossAmount;
  final double gatewayFee;
  final double platformCommission;
  final double affiliatePayout;
  final double netAmount;
  final String? relatedId; // matchId, tournamentId, topicId
  final String currency;
  final TransactionStatus status;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.grossAmount,
    this.gatewayFee = 0.0,
    this.platformCommission = 0.0,
    this.affiliatePayout = 0.0,
    required this.netAmount,
    this.relatedId,
    this.currency = 'USD',
    this.status = TransactionStatus.completed,
    this.metadata = const {},
    required this.createdAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.deposit,
      ),
      grossAmount: (data['grossAmount'] ?? 0.0).toDouble(),
      gatewayFee: (data['gatewayFee'] ?? 0.0).toDouble(),
      platformCommission: (data['platformCommission'] ?? 0.0).toDouble(),
      affiliatePayout: (data['affiliatePayout'] ?? 0.0).toDouble(),
      netAmount: (data['netAmount'] ?? 0.0).toDouble(),
      relatedId: data['relatedId'],
      currency: data['currency'] ?? 'USD',
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.completed,
      ),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'grossAmount': grossAmount,
      'gatewayFee': gatewayFee,
      'platformCommission': platformCommission,
      'affiliatePayout': affiliatePayout,
      'netAmount': netAmount,
      'relatedId': relatedId,
      'currency': currency,
      'status': status.name,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum TransactionType {
  deposit,
  withdrawal,
  lock,
  unlock,
  payout,
  affiliateCredit,
  loyaltyBonus,
  commission,
}

enum TransactionStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

extension TransactionTypeX on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.lock:
        return 'Funds Locked';
      case TransactionType.unlock:
        return 'Funds Unlocked';
      case TransactionType.payout:
        return 'Prize Payout';
      case TransactionType.affiliateCredit:
        return 'Affiliate Bonus';
      case TransactionType.loyaltyBonus:
        return 'Loyalty Bonus';
      case TransactionType.commission:
        return 'Platform Fee';
    }
  }

  bool get isCredit {
    switch (this) {
      case TransactionType.deposit:
      case TransactionType.payout:
      case TransactionType.affiliateCredit:
      case TransactionType.loyaltyBonus:
        return true;
      default:
        return false;
    }
  }
}