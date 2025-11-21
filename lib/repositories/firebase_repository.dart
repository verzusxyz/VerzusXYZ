import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/firebase_client_service.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/models/user_model.dart';
import 'package:verzus/models/match_model.dart';
import 'package:verzus/models/game_model.dart';

/// Repository pattern providers for Firebase data access
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firebaseClient = ref.read(firebaseClientServiceProvider);
  return UserRepository(firebaseClient);
});

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  final firebaseClient = ref.read(firebaseClientServiceProvider);
  return MatchRepository(firebaseClient);
});

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  final firebaseClient = ref.read(firebaseClientServiceProvider);
  return TournamentRepository(firebaseClient);
});

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final firebaseClient = ref.read(firebaseClientServiceProvider);
  return GameRepository(firebaseClient);
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final firebaseClient = ref.read(firebaseClientServiceProvider);
  return WalletRepository(firebaseClient);
});

/// Base repository with common Firebase operations
abstract class BaseRepository {
  final FirebaseClientService firebaseClient;

  BaseRepository(this.firebaseClient);

  /// Get current timestamp for Firestore
  Timestamp get currentTimestamp => Timestamp.now();

  /// Generate new document ID
  String generateDocumentId(String collection) {
    return FirebaseFirestore.instance.collection(collection).doc().id;
  }
}

/// User repository for user-related Firebase operations
class UserRepository extends BaseRepository {
  UserRepository(super.firebaseClient);

  /// Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    return await firebaseClient.getUserProfile(uid);
  }

  /// Update user profile
  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> updates) async {
    return await firebaseClient.updateUserProfile(uid, updates);
  }

  /// Search users
  Future<List<UserModel>> searchUsers(String searchTerm,
      {int limit = 10}) async {
    return await firebaseClient.searchUsers(searchTerm, limit: limit);
  }

  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final query = await firebaseClient.firestore
          .collection(FirestoreSchema.users)
          .where(UserDocument.username, isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return UserModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw RepositoryException(
          'Failed to get user by username: ${e.toString()}');
    }
  }

  /// Update user online status
  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    try {
      await firebaseClient.firestore
          .collection(FirestoreSchema.users)
          .doc(uid)
          .update({
        UserDocument.isOnline: isOnline,
        UserDocument.lastSeen: FieldValue.serverTimestamp(),
        UserDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw RepositoryException(
          'Failed to update online status: ${e.toString()}');
    }
  }

  /// Get users by IDs
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    try {
      final chunks = <List<String>>[];
      for (int i = 0; i < userIds.length; i += 10) {
        chunks.add(userIds.sublist(i, (i + 10).clamp(0, userIds.length)));
      }

      final List<UserModel> users = [];
      for (final chunk in chunks) {
        final query = await firebaseClient.firestore
            .collection(FirestoreSchema.users)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        users.addAll(query.docs.map((doc) => UserModel.fromFirestore(doc)));
      }

      return users;
    } catch (e) {
      throw RepositoryException('Failed to get users by IDs: ${e.toString()}');
    }
  }
}

/// Match repository for match-related Firebase operations
class MatchRepository extends BaseRepository {
  MatchRepository(super.firebaseClient);

  /// Create match
  Future<String> createMatch(MatchModel match) async {
    return await firebaseClient.createMatch(match);
  }

  /// Join match
  Future<void> joinMatch(String matchId, String userId) async {
    return await firebaseClient.joinMatch(matchId, userId);
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
    return await firebaseClient.submitMatchResult(
      matchId: matchId,
      winnerId: winnerId,
      loserId: loserId,
      winnerScore: winnerScore,
      loserScore: loserScore,
      gameData: gameData,
    );
  }

  /// Get available matches
  Stream<List<MatchModel>> getAvailableMatches({
    String? skillTopic,
    int limit = 20,
  }) {
    Query query = firebaseClient.firestore
        .collection(FirestoreSchema.matches)
        .where(MatchDocument.status,
            isEqualTo: FirestoreConstants.matchStatusPending)
        .orderBy(MatchDocument.createdAt, descending: true)
        .limit(limit);

    if (skillTopic != null) {
      query = query.where(MatchDocument.skillTopic, isEqualTo: skillTopic);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MatchModel.fromFirestore(doc)).toList();
    });
  }

  /// Get user matches
  Stream<List<MatchModel>> getUserMatches(String userId, {int limit = 50}) {
    return firebaseClient.getUserMatches(userId, limit: limit);
  }

  /// Listen to specific match
  Stream<MatchModel?> listenToMatch(String matchId) {
    return firebaseClient.listenToMatch(matchId);
  }

  /// Cancel match
  Future<void> cancelMatch(String matchId, String reason) async {
    try {
      await firebaseClient.firestore
          .collection(FirestoreSchema.matches)
          .doc(matchId)
          .update({
        MatchDocument.status: FirestoreConstants.matchStatusCancelled,
        MatchDocument.endTime: FieldValue.serverTimestamp(),
        MatchDocument.updatedAt: FieldValue.serverTimestamp(),
        'cancellation_reason': reason,
      });
    } catch (e) {
      throw RepositoryException('Failed to cancel match: ${e.toString()}');
    }
  }
}

/// Tournament repository for tournament-related Firebase operations
class TournamentRepository extends BaseRepository {
  TournamentRepository(super.firebaseClient);

  /// Create tournament
  Future<String> createTournament(Map<String, dynamic> tournament) async {
    return await firebaseClient.createTournament(tournament);
  }

  /// Join tournament
  Future<void> joinTournament(String tournamentId, String userId) async {
    return await firebaseClient.joinTournament(tournamentId, userId);
  }

  /// Get tournaments
  Stream<List<Map<String, dynamic>>> getTournaments({
    String? status,
    String? skillTopic,
    int limit = 20,
  }) {
    Query query = firebaseClient.firestore
        .collection(FirestoreSchema.tournaments)
        .orderBy(TournamentDocument.startDate, descending: false)
        .limit(limit);

    if (status != null) {
      query = query.where(TournamentDocument.status, isEqualTo: status);
    }
    if (skillTopic != null) {
      query = query.where(TournamentDocument.skillTopic, isEqualTo: skillTopic);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    });
  }

  /// Get tournament participants
  Stream<List<Map<String, dynamic>>> getTournamentParticipants(
      String tournamentId) {
    return firebaseClient.firestore
        .collection(FirestoreSchema.tournamentParticipants)
        .where(TournamentParticipantDocument.tournamentId,
            isEqualTo: tournamentId)
        .orderBy(TournamentParticipantDocument.joinedAt)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// Update tournament status
  Future<void> updateTournamentStatus(
      String tournamentId, String status) async {
    try {
      await firebaseClient.firestore
          .collection(FirestoreSchema.tournaments)
          .doc(tournamentId)
          .update({
        TournamentDocument.status: status,
        TournamentDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw RepositoryException(
          'Failed to update tournament status: ${e.toString()}');
    }
  }
}

/// Game repository for game-related Firebase operations
class GameRepository extends BaseRepository {
  GameRepository(super.firebaseClient);

  /// Add game
  Future<String> addGame(GameModel game) async {
    return await firebaseClient.addGame(game);
  }

  /// Get games
  Stream<List<GameModel>> getGames({int limit = 50}) {
    return firebaseClient.getGames(limit: limit);
  }

  /// Get popular games
  Stream<List<GameModel>> getPopularGames({int limit = 20}) {
    return firebaseClient.firestore
        .collection('games')
        .where('autoGenEnabled', isEqualTo: true)
        .orderBy('popularityScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GameModel.fromFirestore(doc)).toList());
  }

  /// Search games
  Future<List<GameModel>> searchGames(String searchTerm,
      {int limit = 10}) async {
    try {
      final query = await firebaseClient.firestore
          .collection('games')
          .where('title', isGreaterThanOrEqualTo: searchTerm)
          .where('title', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .limit(limit)
          .get();

      return query.docs.map((doc) => GameModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw RepositoryException('Failed to search games: ${e.toString()}');
    }
  }

  /// Update game popularity
  Future<void> updateGamePopularity(String gameId, int popularityScore) async {
    try {
      await firebaseClient.firestore.collection('games').doc(gameId).update({
        'popularityScore': popularityScore,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw RepositoryException(
          'Failed to update game popularity: ${e.toString()}');
    }
  }
}

/// Wallet repository for wallet-related Firebase operations
class WalletRepository extends BaseRepository {
  WalletRepository(super.firebaseClient);

  /// Get user wallet
  Future<Map<String, dynamic>?> getUserWallet(String userId) async {
    return await firebaseClient.getUserWallet(userId);
  }

  /// Listen to wallet updates
  Stream<Map<String, dynamic>?> listenToWallet(String userId) {
    return firebaseClient.listenToWallet(userId);
  }

  /// Create wallet transaction
  Future<String> createTransaction({
    required String userId,
    required String type,
    required double amount,
    required String description,
    String? relatedMatchId,
    String? relatedTournamentId,
    String? paymentMethod,
    String? externalTransactionId,
  }) async {
    return await firebaseClient.createWalletTransaction(
      userId: userId,
      type: type,
      amount: amount,
      description: description,
      relatedMatchId: relatedMatchId,
      relatedTournamentId: relatedTournamentId,
      paymentMethod: paymentMethod,
      externalTransactionId: externalTransactionId,
    );
  }

  /// Get user transactions
  Stream<List<Map<String, dynamic>>> getUserTransactions(String userId,
      {int limit = 50}) {
    return firebaseClient.firestore
        .collection(FirestoreSchema.walletTransactions)
        .where(WalletTransactionDocument.userId, isEqualTo: userId)
        .orderBy(WalletTransactionDocument.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// Update wallet balance
  Future<void> updateWalletBalance({
    required String userId,
    required double amount,
    required String operation, // 'add' or 'subtract'
  }) async {
    try {
      final increment = operation == 'add' ? amount : -amount;
      await firebaseClient.firestore
          .collection(FirestoreSchema.wallets)
          .doc(userId)
          .update({
        WalletDocument.balance: FieldValue.increment(increment),
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw RepositoryException(
          'Failed to update wallet balance: ${e.toString()}');
    }
  }
}

/// Repository exception class
class RepositoryException implements Exception {
  final String message;

  const RepositoryException(this.message);

  @override
  String toString() => message;
}
