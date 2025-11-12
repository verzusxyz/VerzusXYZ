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

  Map<String, dynamic> toFirestore() {
    return {
      'matchId': matchId,
      'reason': reason,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
