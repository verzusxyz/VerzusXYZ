import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:verzus/features/matches/data/models/stake_model.dart';
import 'package:verzus/services/wallet_service.dart';

class StakingService {
  final Ref _ref;
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  StakingService(this._ref, this._firestore);

  Future<void> createStake({
    required String matchId,
    required String stakerId,
    required String playerStakedOnId,
    required double amount,
  }) async {
    // 1. Lock the funds in the staker's wallet
    await _ref.read(walletServiceProvider).lockFundsForEntry(stakerId, amount);

    // 2. Create the stake document
    final stake = StakeModel(
      stakeId: _uuid.v4(),
      matchId: matchId,
      stakerId: stakerId,
      playerStakedOnId: playerStakedOnId,
      amount: amount,
    );

    await _firestore
        .collection('stakes')
        .doc(stake.stakeId)
        .set(stake.toMap());
  }

  Future<void> processStakesForMatch(String matchId, String winningPlayerId) async {
    // In a real application, this would need more robust logic to handle
    // different payout odds. For simplicity, we'll assume a 2x payout.

    final stakesSnapshot = await _firestore
        .collection('stakes')
        .where('matchId', isEqualTo: matchId)
        .where('hasPaidOut', isEqualTo: false)
        .get();

    for (final doc in stakesSnapshot.docs) {
      final stake = StakeModel.fromMap(doc.data());

      final double payout = (stake.playerStakedOnId == winningPlayerId) ? stake.amount * 2 : 0;

      await _firestore.runTransaction((transaction) async {
        final walletRef = _firestore.collection('wallets').doc(stake.stakerId);
        final snapshot = await transaction.get(walletRef);

        if (!snapshot.exists) {
          throw Exception('Wallet for staker ${stake.stakerId} not found.');
        }

        final currentPendingBalance = snapshot.data()?['pendingBalance'] ?? 0.0;
        final newPendingBalance = currentPendingBalance - stake.amount;

        final currentAvailableBalance = snapshot.data()?['availableBalance'] ?? 0.0;
        final newAvailableBalance = currentAvailableBalance + payout;

        transaction.update(walletRef, {
          'pendingBalance': newPendingBalance,
          'availableBalance': newAvailableBalance,
        });

        transaction.update(doc.reference, {'hasPaidOut': true});
      });
    }
  }
}

final stakingServiceProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  return StakingService(ref, firestore);
});
