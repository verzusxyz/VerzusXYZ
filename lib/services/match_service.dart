import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/models/match_model.dart';
import 'package:verzus/services/wallet_service.dart';
import 'package:verzus/models/wallet_model.dart';

final matchServiceProvider = Provider<MatchService>((ref) {
  return MatchService();
});

final openMatchesProvider = StreamProvider<List<MatchModel>>((ref) {
  final service = ref.watch(matchServiceProvider);
  return service.streamOpenMatches();
});

final activeMatchesProvider = StreamProvider<List<MatchModel>>((ref) {
  final service = ref.watch(matchServiceProvider);
  return service.streamActiveMatches();
});

final disputedMatchesProvider = StreamProvider<List<MatchModel>>((ref) {
  final service = ref.watch(matchServiceProvider);
  return service.streamDisputedMatches();
});

class MatchService {
  MatchService();

  final _firestore = FirebaseFirestore.instance;

  Stream<List<MatchModel>> streamOpenMatches() {
    return _firestore
        .collection(FirestoreSchema.matches)
        .where(MatchDocument.status, isEqualTo: MatchStatus.pending.name)
        .orderBy(MatchDocument.createdAt, descending: true)
        .limit(50)
        .snapshots()
        .map((qs) => qs.docs.map((d) => MatchModel.fromFirestore(d)).toList());
  }

  Stream<List<MatchModel>> streamActiveMatches() {
    return _firestore
        .collection(FirestoreSchema.matches)
        .where(MatchDocument.status, isEqualTo: MatchStatus.active.name)
        .orderBy(MatchDocument.updatedAt, descending: true)
        .limit(50)
        .snapshots()
        .map((qs) => qs.docs.map((d) => MatchModel.fromFirestore(d)).toList());
  }

  Stream<List<MatchModel>> streamDisputedMatches() {
    return _firestore
        .collection(FirestoreSchema.matches)
        .where(MatchDocument.status, isEqualTo: MatchStatus.disputed.name)
        .orderBy(MatchDocument.updatedAt, descending: true)
        .limit(50)
        .snapshots()
        .map((qs) => qs.docs.map((d) => MatchModel.fromFirestore(d)).toList());
  }

  Future<String> createMatch({
    required String creatorId,
    required String skillTopic,
    required double wagerAmount,
    required WalletKind walletKind,
    MatchFormat matchFormat = MatchFormat.oneVOne,
    Map<String, dynamic>? gameData,
  }) async {
    final id = _firestore.collection(FirestoreSchema.matches).doc().id;
    final model = MatchModel(
      id: id,
      creatorId: creatorId,
      skillTopic: skillTopic,
      wagerAmount: wagerAmount,
      status: MatchStatus.pending,
      matchType: MatchType.quickPlay,
      matchFormat: matchFormat,
      gameMode: walletKind == WalletKind.demo ? 'demo' : 'live',
      participants: [creatorId],
      gameData: gameData,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Lock funds equal to wager from creator's selected wallet (only if > 0)
    if (wagerAmount > 0) {
      await WalletService().lockFunds(creatorId, wagerAmount, kind: walletKind);
    }

    await _firestore.collection(FirestoreSchema.matches).doc(id).set(model.toFirestore());
    return id;
  }

  Future<void> joinMatch({
    required String matchId,
    required String opponentId,
  }) async {
    await _firestore.runTransaction((txn) async {
      final matchRef = _firestore.collection(FirestoreSchema.matches).doc(matchId);
      final snap = await txn.get(matchRef);
      if (!snap.exists) {
        throw Exception('Match not found');
      }
      final match = MatchModel.fromFirestore(snap);
      if (!match.canJoin) {
        throw Exception('Match no longer open');
      }
      // Lock opponent funds if wager > 0
      if (match.wagerAmount > 0) {
        final isDemo = (match.gameMode == 'demo') || (match.gameData?['mode'] == 'demo');
        await WalletService().lockFunds(opponentId, match.wagerAmount, kind: isDemo ? WalletKind.demo : WalletKind.live);
      }
      
      if (match.matchFormat == MatchFormat.oneVOne) {
        // Classic 1v1: fill opponent and start
        txn.update(matchRef, {
          MatchDocument.opponentId: opponentId,
          MatchDocument.status: MatchStatus.active.name,
          MatchDocument.startTime: FieldValue.serverTimestamp(),
          MatchDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      } else {
        // FFA / Team-based: add to participants, keep pending for now
        txn.update(matchRef, {
          MatchDocument.participants: FieldValue.arrayUnion([opponentId]),
          MatchDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
