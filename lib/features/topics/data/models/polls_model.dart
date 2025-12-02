//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';

class PollsModel {
  final String pollId;
  final String userId;
  final String optionIndex;
  final double entryFee;
  final WalletKind walletKind;
  final DateTime createdAt;

  PollsModel({
    required this.pollId,
    required this.userId,
    required this.optionIndex,
    required this.entryFee,
    required this.createdAt,
    required this.walletKind,
  });

  factory PollsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PollsModel(
      pollId: doc.id,
      userId: data[PollsDocument.userId] ?? '',
      optionIndex: data[PollsDocument.optionIndex] ?? '',
      entryFee: (data[PollsDocument.entryFee] ?? 0.0).toDouble(),
      walletKind: WalletKind.values.firstWhere(
        (e) => e.name == data[PollsDocument.walletKind],
        orElse: () => WalletKind.live,
      ),
      createdAt:
          FirestoreHelpers.timestampToDateTime(data[PollsDocument.createdAt]) ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      PollsDocument.userId: userId,
      PollsDocument.optionIndex: optionIndex,
      PollsDocument.entryFee: entryFee,
      PollsDocument.walletKind: walletKind.name,
      PollsDocument.createdAt: FieldValue.serverTimestamp(),
    };
  }
}
