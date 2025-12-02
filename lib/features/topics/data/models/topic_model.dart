//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';

class TopicModel {
  final String id;
  final String question;
  final String pollType;
  final double entryFee;
  final List<String> options;
  final WalletKind walletKind;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  TopicModel({
    required this.id,
    required this.question,
    required this.pollType,
    required this.entryFee,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
    required this.walletKind,
    required this.status,
  });

  factory TopicModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TopicModel(
      id: doc.id,
      question: data[SkillTopicDocument.question] ?? '',
      pollType: data[SkillTopicDocument.pollType] ?? '',
      options: List<String>.from(data[SkillTopicDocument.options] ?? []),
      walletKind: WalletKind.values.firstWhere(
        (e) => e.name == data['walletKind'],
        orElse: () => WalletKind.live,
      ),
      status: data[SkillTopicDocument.status] ?? '',
      entryFee: (data[SkillTopicDocument.entryFee] ?? 0.0).toDouble(),
      createdAt: FirestoreHelpers.timestampToDateTime(
              data[SkillTopicDocument.createdAt]) ??
          DateTime.now(),
      updatedAt: FirestoreHelpers.timestampToDateTime(
              data[SkillTopicDocument.updatedAt]) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      SkillTopicDocument.question: question,
      SkillTopicDocument.pollType: pollType,
      SkillTopicDocument.entryFee: entryFee,
      SkillTopicDocument.options: options,
      SkillTopicDocument.walletKind: walletKind.name,
      SkillTopicDocument.status: status,
      SkillTopicDocument.createdAt: FieldValue.serverTimestamp(),
      SkillTopicDocument.updatedAt: FieldValue.serverTimestamp(),
    };
  }
}
