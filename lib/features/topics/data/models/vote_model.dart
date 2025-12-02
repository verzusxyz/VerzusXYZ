//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';

class VoteModel {
  final String voteId;
  final String topicId;
  final String userId;
  final String optionIndex;
  final double entryFee;
  final WalletKind walletKind;
  final DateTime createdAt;

  VoteModel({
    required this.voteId,
    required this.topicId,
    required this.userId,
    required this.optionIndex,
    required this.entryFee,
    required this.createdAt,
    required this.walletKind,
  });

  factory VoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VoteModel(
      voteId: doc.id,
      topicId: data[VoteDocument.topicId] ?? '',
      userId: data[VoteDocument.userId] ?? '',
      optionIndex: data[VoteDocument.optionIndex] ?? '',
      entryFee: (data[VoteDocument.entryFee] ?? 0.0).toDouble(),
      walletKind: WalletKind.values.firstWhere(
        (e) => e.name == data[VoteDocument.walletKind],
        orElse: () => WalletKind.live,
      ),
      createdAt:
          FirestoreHelpers.timestampToDateTime(data[VoteDocument.createdAt]) ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      VoteDocument.topicId: topicId,
      VoteDocument.userId: userId,
      VoteDocument.optionIndex: optionIndex,
      VoteDocument.entryFee: entryFee,
      VoteDocument.walletKind: walletKind.name,
      VoteDocument.createdAt: FieldValue.serverTimestamp(),
    };
  }
}
