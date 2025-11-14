import 'package:verzus/models/manual_review_model.dart';
import 'package:verzus/repositories/firebase_repository.dart';

class ManualReviewRepository extends BaseRepository {
  Future<String> createManualReview(ManualReviewModel review) async {
    try {
      final docRef = firestore.collection('manual_reviews').doc();
      await docRef.set(review.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create manual review: $e');
    }
  }
}
