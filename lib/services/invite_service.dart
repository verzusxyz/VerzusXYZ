import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final inviteServiceProvider = Provider<InviteService>((ref) => InviteService());

class InviteService {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  /// Create an invite for a match and return inviteId.
  Future<String> sendInvite({
    required String matchId,
    required String fromUserId,
    required String toUserId,
    Duration ttl = const Duration(hours: 12),
  }) async {
    final id = _fs.collection(FirestoreSchema.matchInvitations).doc().id;
    final now = FieldValue.serverTimestamp();
    final expiresAt = DateTime.now().add(ttl);
    await _fs.collection(FirestoreSchema.matchInvitations).doc(id).set({
      MatchInvitationDocument.id: id,
      MatchInvitationDocument.matchId: matchId,
      MatchInvitationDocument.creatorId: fromUserId,
      MatchInvitationDocument.invitedUserId: toUserId,
      MatchInvitationDocument.status: FirestoreConstants.invitationStatusPending,
      MatchInvitationDocument.expiresAt: Timestamp.fromDate(expiresAt),
      MatchInvitationDocument.createdAt: now,
      MatchInvitationDocument.updatedAt: now,
    });
    return id;
  }

  Future<void> acceptInvite({required String inviteId, required String userId}) async {
    final ref = _fs.collection(FirestoreSchema.matchInvitations).doc(inviteId);
    await _fs.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) throw Exception('Invite not found');
      final data = snap.data() as Map<String, dynamic>;
      if (data[MatchInvitationDocument.status] != FirestoreConstants.invitationStatusPending) {
        throw Exception('Invite already processed');
      }
      txn.update(ref, {
        MatchInvitationDocument.status: FirestoreConstants.invitationStatusAccepted,
        MatchInvitationDocument.updatedAt: FieldValue.serverTimestamp(),
      });

      // Also attach the invited user to the match if slot is free
      final matchId = data[MatchInvitationDocument.matchId] as String;
      final matchRef = _fs.collection(FirestoreSchema.matches).doc(matchId);
      final mSnap = await txn.get(matchRef);
      if (mSnap.exists) {
        final m = mSnap.data() as Map<String, dynamic>;
        final opponent = m[MatchDocument.opponentId];
        if (opponent == null || (opponent as String).isEmpty) {
          txn.update(matchRef, {
            MatchDocument.opponentId: userId,
            MatchDocument.status: FirestoreConstants.matchStatusActive,
            MatchDocument.startTime: FieldValue.serverTimestamp(),
            MatchDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  Future<void> declineInvite({required String inviteId}) async {
    await _fs.collection(FirestoreSchema.matchInvitations).doc(inviteId).update({
      MatchInvitationDocument.status: FirestoreConstants.invitationStatusDeclined,
      MatchInvitationDocument.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  String buildInviteDeepLink(String matchId) {
    // Basic scheme; the app/router can parse this string.
    return 'verzusxyz://invite/match/$matchId';
  }
}