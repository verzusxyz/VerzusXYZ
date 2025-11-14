import 'package:cloud_firestore/cloud_firestore.dart';

class ManualReviewModel {
  final String id;
  final String matchId;
  final String reason;
  final String? videoUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;

  const ManualReviewModel({
    required this.id,
    required this.matchId,
    required this.reason,
    this.videoUrl,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory ManualReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ManualReviewModel(
      id: doc.id,
      matchId: data['matchId'] ?? '',
      reason: data['reason'] ?? '',
      videoUrl: data['videoUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'matchId': matchId,
      'reason': reason,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
