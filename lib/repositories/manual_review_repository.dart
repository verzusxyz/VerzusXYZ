import 'package:verzus/models/manual_review_model.dart';
import 'package:verzus/repositories/firebase_repository.dart';
import 'package:verzus/services/firebase_client_service.dart';

class ManualReviewRepository extends BaseRepository {
  ManualReviewRepository(super.firebaseClient);

  Future<String> createManualReview(ManualReviewModel review) async {
    try {
      final docRef = firebaseClient.firestore.collection('manual_reviews').doc();
      await docRef.set(review.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create manual review: $e');
    }
  }
}
