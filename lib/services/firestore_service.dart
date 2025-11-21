import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/models/match_model.dart';
// import 'package:verzus/models/user_model.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Match operations
  Future<void> createMatch(MatchModel match) async {
    try {
      await _firestore
          .collection(FirestoreSchema.matches)
          .doc(match.id)
          .set(match.toFirestore());
    } catch (e) {
      throw FirestoreException('Failed to create match: ${e.toString()}');
    }
  }

  Future<MatchModel?> getMatch(String matchId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreSchema.matches)
          .doc(matchId)
          .get();
      return doc.exists ? MatchModel.fromFirestore(doc) : null;
    } catch (e) {
      throw FirestoreException('Failed to get match: ${e.toString()}');
    }
  }

  Stream<List<MatchModel>> getAvailableMatches({
    String? skillTopic,
    int limit = 20,
  }) {
    try {
      Query query = _firestore
          .collection(FirestoreSchema.matches)
          .where(MatchDocument.status,
              isEqualTo: FirestoreConstants.matchStatusPending)
          .orderBy(MatchDocument.createdAt, descending: true)
          .limit(limit);

      if (skillTopic != null) {
        query = query.where(MatchDocument.skillTopic, isEqualTo: skillTopic);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => MatchModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw FirestoreException(
          'Failed to get available matches: ${e.toString()}');
    }
  }

  Stream<List<MatchModel>> getUserMatches(String userId, {int limit = 50}) {
    try {
      return _firestore
          .collection(FirestoreSchema.matches)
          .where(MatchDocument.creatorId, isEqualTo: userId)
          .orderBy(MatchDocument.createdAt, descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MatchModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw FirestoreException('Failed to get user matches: ${e.toString()}');
    }
  }

  Future<void> updateMatchStatus(String matchId, String status,
      {String? winnerId, String? loserId}) async {
    try {
      final updates = <String, dynamic>{
        MatchDocument.status: status,
        MatchDocument.updatedAt: FieldValue.serverTimestamp(),
      };

      if (winnerId != null) updates[MatchDocument.winnerId] = winnerId;
      if (loserId != null) updates[MatchDocument.loserId] = loserId;
      if (status == FirestoreConstants.matchStatusCompleted) {
        updates[MatchDocument.endTime] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection(FirestoreSchema.matches)
          .doc(matchId)
          .update(updates);
    } catch (e) {
      throw FirestoreException(
          'Failed to update match status: ${e.toString()}');
    }
  }

  /// Tournament operations
  Stream<List<Map<String, dynamic>>> getTournaments({
    String? status,
    String? skillTopic,
    int limit = 20,
  }) {
    try {
      Query query = _firestore
          .collection(FirestoreSchema.tournaments)
          .orderBy(TournamentDocument.startDate, descending: false)
          .limit(limit);

      if (status != null) {
        query = query.where(TournamentDocument.status, isEqualTo: status);
      }
      if (skillTopic != null) {
        query =
            query.where(TournamentDocument.skillTopic, isEqualTo: skillTopic);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
            .toList();
      });
    } catch (e) {
      throw FirestoreException('Failed to get tournaments: ${e.toString()}');
    }
  }

  /// Skill topics operations
  Stream<List<Map<String, dynamic>>> getSkillTopics() {
    try {
      return _firestore
          .collection(FirestoreSchema.skillTopics)
          .where(SkillTopicDocument.isActive, isEqualTo: true)
          .orderBy(SkillTopicDocument.name)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      });
    } catch (e) {
      throw FirestoreException('Failed to get skill topics: ${e.toString()}');
    }
  }

  /// Leaderboard operations
  Stream<List<Map<String, dynamic>>> getLeaderboard({
    String? skillTopic,
    int limit = 100,
  }) {
    try {
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
    } catch (e) {
      throw FirestoreException('Failed to get leaderboard: ${e.toString()}');
    }
  }

  /// Transaction operations
  Future<void> createWalletTransaction({
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
      final transactionId = FirestoreHelpers.generateDocumentId();
      await _firestore
          .collection(FirestoreSchema.walletTransactions)
          .doc(transactionId)
          .set({
        WalletTransactionDocument.id: transactionId,
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
    } catch (e) {
      throw FirestoreException('Failed to create transaction: ${e.toString()}');
    }
  }

  Stream<List<Map<String, dynamic>>> getUserTransactions(String userId,
      {int limit = 50}) {
    try {
      return _firestore
          .collection(FirestoreSchema.walletTransactions)
          .where(WalletTransactionDocument.userId, isEqualTo: userId)
          .orderBy(WalletTransactionDocument.createdAt, descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      });
    } catch (e) {
      throw FirestoreException(
          'Failed to get user transactions: ${e.toString()}');
    }
  }

  /// System settings operations
  Future<Map<String, dynamic>?> getSystemSetting(String key) async {
    try {
      final doc = await _firestore
          .collection(FirestoreSchema.systemSettings)
          .doc(key)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw FirestoreException('Failed to get system setting: ${e.toString()}');
    }
  }

  /// User operations (additional to auth service)
  Future<void> updateUserStats(
    String userId, {
    int? wins,
    int? losses,
    Map<String, double>? skillRatings,
  }) async {
    try {
      final updates = <String, dynamic>{
        UserDocument.updatedAt: FieldValue.serverTimestamp(),
      };

      if (wins != null) {
        updates[UserDocument.totalWins] = FieldValue.increment(wins);
      }
      if (losses != null) {
        updates[UserDocument.totalLosses] = FieldValue.increment(losses);
      }
      if (skillRatings != null) {
        updates[UserDocument.skillRatings] = skillRatings;
      }

      await _firestore
          .collection(FirestoreSchema.users)
          .doc(userId)
          .update(updates);
    } catch (e) {
      throw FirestoreException('Failed to update user stats: ${e.toString()}');
    }
  }

  /// Initialize default skill topics (call once during setup)
  Future<void> initializeSkillTopics() async {
    try {
      final topics = [
        {
          SkillTopicDocument.id: 'math_basic',
          SkillTopicDocument.name: 'Basic Math',
          SkillTopicDocument.description:
              'Addition, subtraction, multiplication, division',
          SkillTopicDocument.category: 'Mathematics',
          SkillTopicDocument.isActive: true,
          SkillTopicDocument.minWager: 1.0,
          SkillTopicDocument.maxWager: 1000.0,
          SkillTopicDocument.gameConfig: {
            'timeLimit': 60,
            'questionCount': 10,
            'difficulty': 'basic',
          },
          SkillTopicDocument.createdAt: FieldValue.serverTimestamp(),
          SkillTopicDocument.updatedAt: FieldValue.serverTimestamp(),
        },
        {
          SkillTopicDocument.id: 'trivia_general',
          SkillTopicDocument.name: 'General Trivia',
          SkillTopicDocument.description: 'Random knowledge questions',
          SkillTopicDocument.category: 'Trivia',
          SkillTopicDocument.isActive: true,
          SkillTopicDocument.minWager: 1.0,
          SkillTopicDocument.maxWager: 1000.0,
          SkillTopicDocument.gameConfig: {
            'timeLimit': 30,
            'questionCount': 15,
            'difficulty': 'mixed',
          },
          SkillTopicDocument.createdAt: FieldValue.serverTimestamp(),
          SkillTopicDocument.updatedAt: FieldValue.serverTimestamp(),
        },
        {
          SkillTopicDocument.id: 'typing_speed',
          SkillTopicDocument.name: 'Typing Speed',
          SkillTopicDocument.description: 'Test your typing speed and accuracy',
          SkillTopicDocument.category: 'Skills',
          SkillTopicDocument.isActive: true,
          SkillTopicDocument.minWager: 1.0,
          SkillTopicDocument.maxWager: 500.0,
          SkillTopicDocument.gameConfig: {
            'timeLimit': 60,
            'minWPM': 20,
            'minAccuracy': 85,
          },
          SkillTopicDocument.createdAt: FieldValue.serverTimestamp(),
          SkillTopicDocument.updatedAt: FieldValue.serverTimestamp(),
        },
      ];

      final batch = _firestore.batch();
      for (final topic in topics) {
        final docRef = _firestore
            .collection(FirestoreSchema.skillTopics)
            .doc(topic[SkillTopicDocument.id] as String);
        batch.set(docRef, topic);
      }
      await batch.commit();
    } catch (e) {
      throw FirestoreException(
          'Failed to initialize skill topics: ${e.toString()}');
    }
  }

  /// Initialize system settings (call once during setup)
  Future<void> initializeSystemSettings() async {
    try {
      final settings = [
        {
          SystemSettingsDocument.key: FirestoreConstants.settingPlatformFeeRate,
          SystemSettingsDocument.value: '0.10',
          SystemSettingsDocument.description: 'Platform fee rate (10%)',
          SystemSettingsDocument.updatedAt: FieldValue.serverTimestamp(),
        },
        {
          SystemSettingsDocument.key: FirestoreConstants.settingMinWagerAmount,
          SystemSettingsDocument.value: '1.00',
          SystemSettingsDocument.description: 'Minimum wager amount in USD',
          SystemSettingsDocument.updatedAt: FieldValue.serverTimestamp(),
        },
        {
          SystemSettingsDocument.key: FirestoreConstants.settingMaxWagerAmount,
          SystemSettingsDocument.value: '1000.00',
          SystemSettingsDocument.description: 'Maximum wager amount in USD',
          SystemSettingsDocument.updatedAt: FieldValue.serverTimestamp(),
        },
        {
          SystemSettingsDocument.key:
              FirestoreConstants.settingMinWithdrawalAmount,
          SystemSettingsDocument.value: '10.00',
          SystemSettingsDocument.description:
              'Minimum withdrawal amount in USD',
          SystemSettingsDocument.updatedAt: FieldValue.serverTimestamp(),
        },
        {
          SystemSettingsDocument.key: FirestoreConstants.settingMaintenanceMode,
          SystemSettingsDocument.value: 'false',
          SystemSettingsDocument.description: 'Maintenance mode status',
          SystemSettingsDocument.updatedAt: FieldValue.serverTimestamp(),
        },
      ];

      final batch = _firestore.batch();
      for (final setting in settings) {
        final docRef = _firestore
            .collection(FirestoreSchema.systemSettings)
            .doc(setting[SystemSettingsDocument.key] as String);
        batch.set(docRef, setting);
      }
      await batch.commit();
    } catch (e) {
      throw FirestoreException(
          'Failed to initialize system settings: ${e.toString()}');
    }
  }
}

class FirestoreException implements Exception {
  final String message;

  const FirestoreException(this.message);

  @override
  String toString() => message;
}
