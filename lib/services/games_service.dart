import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/models/game_model.dart';

final gamesServiceProvider = Provider<GamesService>((ref) => GamesService());

final gamesStreamProvider = StreamProvider<List<GameModel>>((ref) {
  return ref.read(gamesServiceProvider).streamGames();
});

final gameSubmissionsStreamProvider = StreamProvider<List<GameSubmissionModel>>((ref) {
  return ref.read(gamesServiceProvider).streamSubmissions();
});

class GamesService {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference get _gamesCol => _firestore.collection('games');
  // Align to spec: games_user_submissions
  CollectionReference get _submissionsCol => _firestore.collection('games_user_submissions');
  CollectionReference _usernameMappingsCol(String uid) => _firestore.collection('username_mappings').doc(uid).collection('games');

  Stream<List<GameModel>> streamGames() {
    return _gamesCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((qs) => qs.docs.map((d) => GameModel.fromFirestore(d)).toList());
  }

  Future<String> addGame(GameModel game, {String? id}) async {
    final doc = id != null ? _gamesCol.doc(id) : _gamesCol.doc();
    await doc.set(game.toFirestore());
    return doc.id;
  }

  Future<String> upsertGameByCanonicalKey(GameModel game) async {
    final key = canonicalGameKey(
      platform: game.platform,
      packageId: game.packageId,
      bundleId: game.bundleId,
      webUrl: game.webUrl,
    );
    final doc = _gamesCol.doc(key);
    await doc.set(game.toFirestore(), SetOptions(merge: true));
    return doc.id;
  }

  Future<void> deleteGame(String gameId) async {
    await _gamesCol.doc(gameId).delete();
  }

  Stream<List<GameSubmissionModel>> streamSubmissions({List<String>? statuses}) {
    Query query = _submissionsCol.orderBy('createdAt', descending: true);
    if (statuses != null && statuses.isNotEmpty) {
      query = query.where('status', whereIn: statuses);
    }
    return query.snapshots().map((qs) => qs.docs.map((d) => GameSubmissionModel.fromFirestore(d)).toList());
  }

  Future<String> reserveSubmissionId() async {
    final doc = _submissionsCol.doc();
    // Write a minimal stub so path exists (optional); we can rely on client-side id only
    await doc.set({
      'createdAt': FieldValue.serverTimestamp(),
      'status': GameSubmissionStatus.pending.name,
    }, SetOptions(merge: true));
    return doc.id;
  }

  Future<void> createSubmissionWithId(String id, GameSubmissionModel submission) async {
    await _submissionsCol.doc(id).set(submission.toFirestore());
  }

  Future<String> submitGame(GameSubmissionModel submission) async {
    final doc = _submissionsCol.doc();
    await doc.set(submission.toFirestore());
    return doc.id;
  }

  String canonicalGameKey({required String platform, String? packageId, String? bundleId, String? webUrl}) {
    switch (platform) {
      case 'android':
        return 'android:${(packageId ?? '').trim()}';
      case 'ios':
        return 'ios:${(bundleId ?? '').trim()}';
      case 'web':
        final url = (webUrl ?? '').trim();
        return 'web:$url';
      default:
        return '${platform.trim()}:${(packageId ?? bundleId ?? webUrl ?? 'unknown').trim()}';
    }
  }

  Future<void> approveSubmission(String submissionId, {required String approvedBy}) async {
    // Promote approved submission into games collection and mark submission reviewed

    final subRef = _submissionsCol.doc(submissionId);
    final snap = await subRef.get();
    if (!snap.exists) return;
    final sub = GameSubmissionModel.fromFirestore(snap);

    final gameKey = canonicalGameKey(
      platform: sub.platform,
      packageId: sub.packageId,
      bundleId: sub.bundleId,
      webUrl: sub.webUrl,
    );

    final gameDoc = _gamesCol.doc(gameKey);

    final game = GameModel(
      gameId: gameDoc.id,
      title: sub.gameName,
      platform: sub.platform,
      packageId: sub.packageId,
      bundleId: sub.bundleId,
      webUrl: sub.webUrl,
      iconUrl: sub.sampleImageUrls.isNotEmpty ? sub.sampleImageUrls.first : null,
      defaultCropData: sub.defaultCropData,
      autoGenEnabled: true,
      popularityScore: 0,
      supportsRoomUrl: false,
      supportsRoomCode: false,
      supportsBoardState: false,
      roomIdPatterns: const [],
      createdAt: DateTime.now(),
      approvedBy: approvedBy,
    );

    // If a game doc for this key already exists, just mark submission as merged
    final existing = await gameDoc.get();
    final batch = _firestore.batch();
    if (!existing.exists) {
      batch.set(gameDoc, game.toFirestore());
    }
    batch.update(subRef, {
      'status': existing.exists ? GameSubmissionStatus.merged.name : GameSubmissionStatus.approved.name,
      'reviewedBy': approvedBy,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> rejectSubmission(String submissionId, {required String reviewedBy, String? notes}) async {
    await _submissionsCol.doc(submissionId).update({
      'status': GameSubmissionStatus.rejected.name,
      'reviewedBy': reviewedBy,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewNotes': notes,
    });
  }

  Future<void> setUsernameMapping({
    required String uid,
    required String gameKey,
    required String handle,
  }) async {
    final ref = _usernameMappingsCol(uid).doc(gameKey);
    await ref.set({
      'uid': uid,
      'game_key': gameKey,
      'handle': handle,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
