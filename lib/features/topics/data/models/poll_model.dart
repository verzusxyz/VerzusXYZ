import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a user-created poll from the 'polls' collection.
class PollModel {
  final String id;
  final String question;
  final String type;
  final List<String> options;
  final double entryFee;
  final String walletKind;
  final String status;
  final Timestamp createdAt;

  PollModel({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.entryFee,
    required this.walletKind,
    required this.status,
    required this.createdAt,
  });

  factory PollModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PollModel(
      id: doc.id,
      question: data['question'] ?? '',
      type: data['type'] ?? 'yes_no',
      options: List<String>.from(data['options'] ?? []),
      entryFee: (data['entry_fee'] ?? 0.0).toDouble(),
      walletKind: data['wallet_kind'] ?? 'live',
      status: data['status'] ?? 'closed',
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'type': type,
      'options': options,
      'entry_fee': entryFee,
      'wallet_kind': walletKind,
      'status': status,
      'created_at': createdAt,
    };
  }
}
