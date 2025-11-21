import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/models/user_model.dart';
import 'package:verzus/models/match_model.dart';
import 'package:verzus/models/game_model.dart';

/// Complete Firebase client service provider
final firebaseClientServiceProvider = Provider<FirebaseClientService>((ref) {
  return FirebaseClientService();
});

/// Comprehensive Firebase client service that orchestrates all Firebase operations
/// This service provides a centralized interface for all Firebase interactions
class FirebaseClientService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Core Firebase instances
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  /// ==== USER MANAGEMENT ====

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get user profile by UID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc =
          await _firestore.collection(FirestoreSchema.users).doc(uid).get();
      return doc.exists ? UserModel.fromFirestore(doc) : null;
    } catch (e) {
      throw FirebaseClientException(
          'Failed to get user profile: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> updates) async {
    try {
      updates[UserDocument.updatedAt] = FieldValue.serverTimestamp();
      await _firestore
          .collection(FirestoreSchema.users)
          .doc(uid)
          .update(updates);
    } catch (e) {
      throw FirebaseClientException(
          'Failed to update user profile: ${e.toString()}');
    }
  }

  /// Search users by username
  Future<List<UserModel>> searchUsers(String searchTerm,
      {int limit = 10}) async {
    try {
      final query = await _firestore
          .collection(FirestoreSchema.users)
          .where(UserDocument.username,
              isGreaterThanOrEqualTo: searchTerm.toLowerCase())
          .where(UserDocument.username,
              isLessThanOrEqualTo: '${searchTerm.toLowerCase()}\uf8ff')
          .limit(limit)
          .get();

      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw FirebaseClientException('Failed to search users: ${e.toString()}');
    }
  }

  /// ==== MATCH MANAGEMENT ====

  /// Create a new match
  Future<String> createMatch(MatchModel match) async {
    try {
      final matchRef = _firestore.collection(FirestoreSchema.matches).doc();
      final matchData = match.toFirestore();
      matchData['id'] = matchRef.id;
      await matchRef.set(matchData);
      return matchRef.id;
    } catch (e) {
      throw FirebaseClientException('Failed to create match: ${e.toString()}');
    }
  }

  /// Join an existing match
  Future<void> joinMatch(String matchId, String userId) async {
    try {
      await _firestore.collection(FirestoreSchema.matches).doc(matchId).update({
        MatchDocument.opponentId: userId,
        MatchDocument.status: FirestoreConstants.matchStatusActive,
        MatchDocument.startTime: FieldValue.serverTimestamp(),
        MatchDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebaseClientException('Failed to join match: ${e.toString()}');
    }
  }

  /// Submit match result
  Future<void> submitMatchResult({
    required String matchId,
    required String winnerId,
    required String loserId,
    required int winnerScore,
    required int loserScore,
    Map<String, dynamic>? gameData,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final matchRef =
            _firestore.collection(FirestoreSchema.matches).doc(matchId);
        final matchDoc = await transaction.get(matchRef);

        if (!matchDoc.exists) {
          throw Exception('Match not found');
        }

        final match = MatchModel.fromFirestore(matchDoc);
        // ignore: unrelated_type_equality_checks
        if (match.status != FirestoreConstants.matchStatusActive) {
          throw Exception('Match is not active');
        }

        // Update match with results
        transaction.update(matchRef, {
          MatchDocument.winnerId: winnerId,
          MatchDocument.loserId: loserId,
          MatchDocument.creatorScore:
              match.creatorId == winnerId ? winnerScore : loserScore,
          MatchDocument.opponentScore:
              match.creatorId == winnerId ? loserScore : winnerScore,
          MatchDocument.status: FirestoreConstants.matchStatusCompleted,
          MatchDocument.endTime: FieldValue.serverTimestamp(),
          MatchDocument.gameData: gameData,
          MatchDocument.updatedAt: FieldValue.serverTimestamp(),
        });

        // Update user statistics
        final winnerRef =
            _firestore.collection(FirestoreSchema.users).doc(winnerId);
        final loserRef =
            _firestore.collection(FirestoreSchema.users).doc(loserId);

        transaction.update(winnerRef, {
          UserDocument.totalWins: FieldValue.increment(1),
          UserDocument.totalMatches: FieldValue.increment(1),
          UserDocument.updatedAt: FieldValue.serverTimestamp(),
        });

        transaction.update(loserRef, {
          UserDocument.totalLosses: FieldValue.increment(1),
          UserDocument.totalMatches: FieldValue.increment(1),
          UserDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw FirebaseClientException(
          'Failed to submit match result: ${e.toString()}');
    }
  }

  /// Get matches for a user
  Stream<List<MatchModel>> getUserMatches(String userId, {int limit = 50}) {
    return _firestore
        .collection(FirestoreSchema.matches)
        .where(Filter.or(
          Filter(MatchDocument.creatorId, isEqualTo: userId),
          Filter(MatchDocument.opponentId, isEqualTo: userId),
        ))
        .orderBy(MatchDocument.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MatchModel.fromFirestore(doc)).toList());
  }

  /// ==== TOURNAMENT MANAGEMENT ====

  /// Create tournament
  Future<String> createTournament(Map<String, dynamic> tournament) async {
    try {
      final tournamentRef =
          _firestore.collection(FirestoreSchema.tournaments).doc();
      tournament['id'] = tournamentRef.id;
      tournament[TournamentDocument.createdAt] = FieldValue.serverTimestamp();
      tournament[TournamentDocument.updatedAt] = FieldValue.serverTimestamp();
      await tournamentRef.set(tournament);
      return tournamentRef.id;
    } catch (e) {
      throw FirebaseClientException(
          'Failed to create tournament: ${e.toString()}');
    }
  }

  /// Join tournament
  Future<void> joinTournament(String tournamentId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final tournamentRef = _firestore
            .collection(FirestoreSchema.tournaments)
            .doc(tournamentId);
        final participantRef =
            _firestore.collection(FirestoreSchema.tournamentParticipants).doc();

        final tournamentDoc = await transaction.get(tournamentRef);
        if (!tournamentDoc.exists) {
          throw Exception('Tournament not found');
        }

        final tournament = tournamentDoc.data() as Map<String, dynamic>;
        final currentParticipants =
            tournament[TournamentDocument.currentParticipants] ?? 0;
        final maxParticipants =
            tournament[TournamentDocument.maxParticipants] ?? 0;

        if (currentParticipants >= maxParticipants) {
          throw Exception('Tournament is full');
        }

        // Add participant
        transaction.set(participantRef, {
          TournamentParticipantDocument.id: participantRef.id,
          TournamentParticipantDocument.tournamentId: tournamentId,
          TournamentParticipantDocument.userId: userId,
          TournamentParticipantDocument.status: 'active',
          TournamentParticipantDocument.joinedAt: FieldValue.serverTimestamp(),
        });

        // Update tournament participant count
        transaction.update(tournamentRef, {
          TournamentDocument.currentParticipants: FieldValue.increment(1),
          TournamentDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw FirebaseClientException(
          'Failed to join tournament: ${e.toString()}');
    }
  }

  /// ==== GAME MANAGEMENT ====

  /// Add game to Firestore for reuse
  Future<String> addGame(GameModel game) async {
    try {
      final gameRef = _firestore.collection('games').doc();
      final gameData = game.toFirestore();
      gameData['gameId'] = gameRef.id;
      await gameRef.set(gameData);
      return gameRef.id;
    } catch (e) {
      throw FirebaseClientException('Failed to add game: ${e.toString()}');
    }
  }

  /// Get available games
  Stream<List<GameModel>> getGames({int limit = 50}) {
    return _firestore
        .collection('games')
        .orderBy('popularityScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GameModel.fromFirestore(doc)).toList());
  }

  /// ==== WALLET OPERATIONS ====

  /// Get user wallet
  Future<Map<String, dynamic>?> getUserWallet(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreSchema.wallets)
          .doc(userId)
          .get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      throw FirebaseClientException('Failed to get wallet: ${e.toString()}');
    }
  }

  /// Create wallet transaction
  Future<String> createWalletTransaction({
    required String userId,
    required String type,
    required double amount,
    required String description,
    String? relatedMatchId,
    String? relatedTournamentId,
    String? paymentMethod,
    String? externalTransactionId,
  }) async {
    try {
      final transactionRef =
          _firestore.collection(FirestoreSchema.walletTransactions).doc();
      await transactionRef.set({
        WalletTransactionDocument.id: transactionRef.id,
        WalletTransactionDocument.userId: userId,
        WalletTransactionDocument.type: type,
        WalletTransactionDocument.amount: amount,
        WalletTransactionDocument.status:
            FirestoreConstants.transactionStatusPending,
        WalletTransactionDocument.description: description,
        WalletTransactionDocument.relatedMatchId: relatedMatchId,
        WalletTransactionDocument.relatedTournamentId: relatedTournamentId,
        WalletTransactionDocument.paymentMethod: paymentMethod,
        WalletTransactionDocument.externalTransactionId: externalTransactionId,
        WalletTransactionDocument.createdAt: FieldValue.serverTimestamp(),
        WalletTransactionDocument.updatedAt: FieldValue.serverTimestamp(),
      });
      return transactionRef.id;
    } catch (e) {
      throw FirebaseClientException(
          'Failed to create wallet transaction: ${e.toString()}');
    }
  }

  /// ==== STORAGE OPERATIONS ====

  /// Upload file to Firebase Storage
  Future<String> uploadFile(String path, Uint8List fileBytes,
      {String? contentType}) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(contentType: contentType);
      final uploadTask = ref.putData(fileBytes, metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw FirebaseClientException('Failed to upload file: ${e.toString()}');
    }
  }

  /// Delete file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      throw FirebaseClientException('Failed to delete file: ${e.toString()}');
    }
  }

  /// ==== LEADERBOARD OPERATIONS ====

  /// Get leaderboard entries
  Stream<List<Map<String, dynamic>>> getLeaderboard({
    String? skillTopic,
    int limit = 100,
  }) {
    Query query = _firestore
        .collection(FirestoreSchema.leaderboardEntries)
        .orderBy(LeaderboardEntryDocument.skillRating, descending: true)
        .limit(limit);

    if (skillTopic != null) {
      query = query.where(LeaderboardEntryDocument.skillTopic,
          isEqualTo: skillTopic);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    });
  }

  /// Update leaderboard entry
  Future<void> updateLeaderboard({
    required String userId,
    required String skillTopic,
    required double skillRating,
    required Map<String, dynamic> stats,
  }) async {
    try {
      final entryId = '${userId}_$skillTopic';
      await _firestore
          .collection(FirestoreSchema.leaderboardEntries)
          .doc(entryId)
          .set({
        LeaderboardEntryDocument.id: entryId,
        LeaderboardEntryDocument.userId: userId,
        LeaderboardEntryDocument.skillTopic: skillTopic,
        LeaderboardEntryDocument.skillRating: skillRating,
        ...stats,
        LeaderboardEntryDocument.updatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw FirebaseClientException(
          'Failed to update leaderboard: ${e.toString()}');
    }
  }

  /// ==== SYSTEM OPERATIONS ====

  /// Get system settings
  Future<Map<String, dynamic>?> getSystemSetting(String key) async {
    try {
      final doc = await _firestore
          .collection(FirestoreSchema.systemSettings)
          .doc(key)
          .get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      throw FirebaseClientException(
          'Failed to get system setting: ${e.toString()}');
    }
  }

  /// Get all active skill topics
  Stream<List<Map<String, dynamic>>> getSkillTopics() {
    return _firestore
        .collection(FirestoreSchema.skillTopics)
        .where(SkillTopicDocument.isActive, isEqualTo: true)
        .orderBy(SkillTopicDocument.name)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// ==== BATCH OPERATIONS ====

  /// Execute batch write
  Future<void> executeBatch(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();

      for (final op in operations) {
        final type = op['type'] as String;
        final collection = op['collection'] as String;
        final docId = op['docId'] as String?;
        final data = op['data'] as Map<String, dynamic>?;

        final docRef = docId != null
            ? _firestore.collection(collection).doc(docId)
            : _firestore.collection(collection).doc();

        switch (type) {
          case 'set':
            batch.set(docRef, data!);
            break;
          case 'update':
            batch.update(docRef, data!);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw FirebaseClientException('Failed to execute batch: ${e.toString()}');
    }
  }

  /// ==== REALTIME LISTENERS ====

  /// Listen to match updates
  Stream<MatchModel?> listenToMatch(String matchId) {
    return _firestore
        .collection(FirestoreSchema.matches)
        .doc(matchId)
        .snapshots()
        .map((doc) => doc.exists ? MatchModel.fromFirestore(doc) : null);
  }

  /// Listen to user updates
  Stream<UserModel?> listenToUser(String userId) {
    return _firestore
        .collection(FirestoreSchema.users)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Listen to wallet updates
  Stream<Map<String, dynamic>?> listenToWallet(String userId) {
    return _firestore
        .collection(FirestoreSchema.wallets)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() as Map<String, dynamic> : null);
  }
}

/// Firebase client exception
class FirebaseClientException implements Exception {
  final String message;

  const FirebaseClientException(this.message);

  @override
  String toString() => message;
}
