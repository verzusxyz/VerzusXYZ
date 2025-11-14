import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/firebase_client_service.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/models/user_model.dart';
import 'package:verzus/models/match_model.dart';
import 'package:verzus/models/game_model.dart';
import 'package:verzus/repositories/game_result_repository.dart';
import 'package:verzus/repositories/manual_review_repository.dart';

/// Repository pattern providers for Firebase data access
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  return TournamentRepository();
});

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository();
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

final gameResultRepositoryProvider = Provider<GameResultRepository>((ref) {
  return GameResultRepository();
});

final manualReviewRepositoryProvider = Provider<ManualReviewRepository>((ref) {
  return ManualReviewRepository();
});

final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  return SystemRepository();
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

/// Base repository with common Firebase operations
abstract class BaseRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  /// Get current timestamp for Firestore
  Timestamp get currentTimestamp => Timestamp.now();
  
  /// Generate new document ID
  String generateDocumentId(String collection) {
    return FirebaseFirestore.instance.collection(collection).doc().id;
  }
}

/// User repository for user-related Firebase operations
class UserRepository extends BaseRepository {
  /// Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await firestore.collection(FirestoreSchema.users).doc(uid).get();
      return doc.exists ? UserModel.fromFirestore(doc) : null;
    } catch (e) {
      throw RepositoryException('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      updates[UserDocument.updatedAt] = FieldValue.serverTimestamp();
      await firestore.collection(FirestoreSchema.users).doc(uid).update(updates);
    } catch (e) {
      throw RepositoryException('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Search users
  Future<List<UserModel>> searchUsers(String searchTerm, {int limit = 10}) async {
    try {
      final query = await firestore
          .collection(FirestoreSchema.users)
          .where(UserDocument.username, isGreaterThanOrEqualTo: searchTerm.toLowerCase())
          .where(UserDocument.username, isLessThanOrEqualTo: '${searchTerm.toLowerCase()}\uf8ff')
          .limit(limit)
          .get();

      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw RepositoryException('Failed to search users: ${e.toString()}');
    }
  }
  
  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final query = await firestore
          .collection(FirestoreSchema.users)
          .where(UserDocument.username, isEqualTo: username.toLowerCase())
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) return null;
      return UserModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw RepositoryException('Failed to get user by username: ${e.toString()}');
    }
  }
  
  /// Update user online status
  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    try {
      await firestore
          .collection(FirestoreSchema.users)
          .doc(uid)
          .update({
        UserDocument.isOnline: isOnline,
        UserDocument.lastSeen: FieldValue.serverTimestamp(),
        UserDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw RepositoryException('Failed to update online status: ${e.toString()}');
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
        final query = await firestore
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
  /// Create match
  Future<String> createMatch(MatchModel match) async {
    try {
      final matchRef = firestore.collection(FirestoreSchema.matches).doc();
      final matchData = match.toFirestore();
      matchData['id'] = matchRef.id;
      await matchRef.set(matchData);
      return matchRef.id;
    } catch (e) {
      throw RepositoryException('Failed to create match: ${e.toString()}');
    }
  }

  /// Join match
  Future<void> joinMatch(String matchId, String userId) async {
    try {
      await firestore.collection(FirestoreSchema.matches).doc(matchId).update({
        MatchDocument.opponentId: userId,
        MatchDocument.status: FirestoreConstants.matchStatusActive,
        MatchDocument.startTime: FieldValue.serverTimestamp(),
        MatchDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw RepositoryException('Failed to join match: ${e.toString()}');
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
      await firestore.runTransaction((transaction) async {
        final matchRef = firestore.collection(FirestoreSchema.matches).doc(matchId);
        final matchDoc = await transaction.get(matchRef);

        if (!matchDoc.exists) {
          throw Exception('Match not found');
        }

        final match = MatchModel.fromFirestore(matchDoc);
        if (match.status != FirestoreConstants.matchStatusActive) {
          throw Exception('Match is not active');
        }

        // Update match with results
        transaction.update(matchRef, {
          MatchDocument.winnerId: winnerId,
          MatchDocument.loserId: loserId,
          MatchDocument.creatorScore: match.creatorId == winnerId ? winnerScore : loserScore,
          MatchDocument.opponentScore: match.creatorId == winnerId ? loserScore : winnerScore,
          MatchDocument.status: FirestoreConstants.matchStatusCompleted,
          MatchDocument.endTime: FieldValue.serverTimestamp(),
          MatchDocument.gameData: gameData,
          MatchDocument.updatedAt: FieldValue.serverTimestamp(),
        });

        // Update user statistics
        final winnerRef = firestore.collection(FirestoreSchema.users).doc(winnerId);
        final loserRef = firestore.collection(FirestoreSchema.users).doc(loserId);

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
      throw RepositoryException('Failed to submit match result: ${e.toString()}');
    }
  }

  /// Get available matches
  Stream<List<MatchModel>> getAvailableMatches({
    String? skillTopic,
    int limit = 20,
  }) {
    Query query = firestore
        .collection(FirestoreSchema.matches)
        .where(MatchDocument.status, isEqualTo: FirestoreConstants.matchStatusPending)
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
    return firestore
        .collection(FirestoreSchema.matches)
        .where(Filter.or(
          Filter(MatchDocument.creatorId, isEqualTo: userId),
          Filter(MatchDocument.opponentId, isEqualTo: userId),
        ))
        .orderBy(MatchDocument.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MatchModel.fromFirestore(doc)).toList());
  }

  /// Listen to specific match
  Stream<MatchModel?> listenToMatch(String matchId) {
    return firestore
        .collection(FirestoreSchema.matches)
        .doc(matchId)
        .snapshots()
        .map((doc) => doc.exists ? MatchModel.fromFirestore(doc) : null);
  }
  
  /// Cancel match
  Future<void> cancelMatch(String matchId, String reason) async {
    try {
      await firestore
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
  /// Create tournament
  Future<String> createTournament(Map<String, dynamic> tournament) async {
    try {
      final tournamentRef = firestore.collection(FirestoreSchema.tournaments).doc();
      tournament['id'] = tournamentRef.id;
      tournament[TournamentDocument.createdAt] = FieldValue.serverTimestamp();
      tournament[TournamentDocument.updatedAt] = FieldValue.serverTimestamp();
      await tournamentRef.set(tournament);
      return tournamentRef.id;
    } catch (e) {
      throw RepositoryException('Failed to create tournament: ${e.toString()}');
    }
  }

  /// Join tournament
  Future<void> joinTournament(String tournamentId, String userId) async {
    try {
      await firestore.runTransaction((transaction) async {
        final tournamentRef = firestore.collection(FirestoreSchema.tournaments).doc(tournamentId);
        final participantRef = firestore.collection(FirestoreSchema.tournamentParticipants).doc();

        final tournamentDoc = await transaction.get(tournamentRef);
        if (!tournamentDoc.exists) {
          throw Exception('Tournament not found');
        }

        final tournament = tournamentDoc.data() as Map<String, dynamic>;
        final currentParticipants = tournament[TournamentDocument.currentParticipants] ?? 0;
        final maxParticipants = tournament[TournamentDocument.maxParticipants] ?? 0;

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
      throw RepositoryException('Failed to join tournament: ${e.toString()}');
    }
  }
  
  /// Get tournaments
  Stream<List<Map<String, dynamic>>> getTournaments({
    String? status,
    String? skillTopic,
    int limit = 20,
  }) {
    Query query = firestore
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
      return snapshot.docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList();
    });
  }

  /// Get tournament participants
  Stream<List<Map<String, dynamic>>> getTournamentParticipants(String tournamentId) {
    return firestore
        .collection(FirestoreSchema.tournamentParticipants)
        .where(TournamentParticipantDocument.tournamentId, isEqualTo: tournamentId)
        .orderBy(TournamentParticipantDocument.joinedAt)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList());
  }

  /// Update tournament status
  Future<void> updateTournamentStatus(String tournamentId, String status) async {
    try {
      await firestore
          .collection(FirestoreSchema.tournaments)
          .doc(tournamentId)
          .update({
        TournamentDocument.status: status,
        TournamentDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw RepositoryException('Failed to update tournament status: ${e.toString()}');
    }
  }
}

/// Game repository for game-related Firebase operations
class GameRepository extends BaseRepository {
  /// Add game
  Future<String> addGame(GameModel game) async {
    try {
      final gameRef = firestore.collection('games').doc();
      final gameData = game.toFirestore();
      gameData['gameId'] = gameRef.id;
      await gameRef.set(gameData);
      return gameRef.id;
    } catch (e) {
      throw RepositoryException('Failed to add game: ${e.toString()}');
    }
  }

  /// Get games
  Stream<List<GameModel>> getGames({int limit = 50}) {
    return firestore
        .collection('games')
        .orderBy('popularityScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GameModel.fromFirestore(doc)).toList());
  }
  
  /// Get popular games
  Stream<List<GameModel>> getPopularGames({int limit = 20}) {
    return firestore
        .collection('games')
        .where('autoGenEnabled', isEqualTo: true)
        .orderBy('popularityScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GameModel.fromFirestore(doc)).toList());
  }

  /// Search games
  Future<List<GameModel>> searchGames(String searchTerm, {int limit = 10}) async {
    try {
      final query = await firestore
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
      await firestore
          .collection('games')
          .doc(gameId)
          .update({
        'popularityScore': popularityScore,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw RepositoryException('Failed to update game popularity: ${e.toString()}');
    }
  }
}

/// Wallet repository for wallet-related Firebase operations
class WalletRepository extends BaseRepository {
  /// Get user wallet
  Future<Map<String, dynamic>?> getUserWallet(String userId) async {
    try {
      final doc = await firestore.collection(FirestoreSchema.wallets).doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      throw RepositoryException('Failed to get wallet: ${e.toString()}');
    }
  }

  /// Listen to wallet updates
  Stream<Map<String, dynamic>?> listenToWallet(String userId) {
    return firestore
        .collection(FirestoreSchema.wallets)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() as Map<String, dynamic> : null);
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
    try {
      final transactionRef = firestore.collection(FirestoreSchema.walletTransactions).doc();
      await transactionRef.set({
        WalletTransactionDocument.id: transactionRef.id,
        WalletTransactionDocument.userId: userId,
        WalletTransactionDocument.type: type,
        WalletTransactionDocument.amount: amount,
        WalletTransactionDocument.status: FirestoreConstants.transactionStatusPending,
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
      throw RepositoryException('Failed to create wallet transaction: ${e.toString()}');
    }
  }

  /// Get user transactions
  Stream<List<Map<String, dynamic>>> getUserTransactions(String userId, {int limit = 50}) {
    return firestore
        .collection(FirestoreSchema.walletTransactions)
        .where(WalletTransactionDocument.userId, isEqualTo: userId)
        .orderBy(WalletTransactionDocument.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList());
  }
  
  /// Update wallet balance
  Future<void> updateWalletBalance({
    required String userId,
    required double amount,
    required String operation, // 'add' or 'subtract'
  }) async {
    try {
      final increment = operation == 'add' ? amount : -amount;
      await firestore
          .collection(FirestoreSchema.wallets)
          .doc(userId)
          .update({
        WalletDocument.balance: FieldValue.increment(increment),
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw RepositoryException('Failed to update wallet balance: ${e.toString()}');
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

/// System repository for system-level Firebase operations
class SystemRepository extends BaseRepository {
  /// Get system settings
  Future<Map<String, dynamic>?> getSystemSetting(String key) async {
    try {
      final doc = await firestore.collection(FirestoreSchema.systemSettings).doc(key).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      throw RepositoryException('Failed to get system setting: ${e.toString()}');
    }
  }

  /// Get all active skill topics
  Stream<List<Map<String, dynamic>>> getSkillTopics() {
    return firestore
        .collection(FirestoreSchema.skillTopics)
        .where(SkillTopicDocument.isActive, isEqualTo: true)
        .orderBy(SkillTopicDocument.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList());
  }
}

/// Leaderboard repository for leaderboard-related Firebase operations
class LeaderboardRepository extends BaseRepository {
  /// Get leaderboard entries
  Stream<List<Map<String, dynamic>>> getLeaderboard({
    String? skillTopic,
    int limit = 100,
  }) {
    Query query = firestore
        .collection(FirestoreSchema.leaderboardEntries)
        .orderBy(LeaderboardEntryDocument.skillRating, descending: true)
        .limit(limit);

    if (skillTopic != null) {
      query = query.where(LeaderboardEntryDocument.skillTopic, isEqualTo: skillTopic);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList();
    });
  }
}