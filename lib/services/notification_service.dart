import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:verzus/features/auth/data/models/user_model.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/features/matches/data/models/match_model.dart';
import 'package:verzus/features/matches/data/repositories/match_repository.dart';
import 'package:verzus/features/notifications/data/models/notification_model.dart';
import 'package:verzus/features/notifications/data/repositories/notification_repository.dart';

class NotificationService {
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  NotificationService(this._ref);

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationModel(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      data: data,
    );
    await _ref.read(notificationRepositoryProvider).createNotification(notification);
  }

  Future<void> sendMatchStartingNotification(String userId, String opponentName) async {
    await sendNotification(
      userId: userId,
      title: 'Your Match is Starting!',
      body: 'Your match against $opponentName is about to begin. Good luck!',
      data: {'type': 'match_starting'},
    );
  }

  Future<void> _sendPersonalizedMatchNotification({
    required String winnerId,
    required String loserId,
    required double prizeAmount,
    required MatchModel match,
  }) async {
    final winner = await _ref.read(authRepositoryProvider).getUser(winnerId);
    final loser = await _ref.read(authRepositoryProvider).getUser(loserId);

    if (winner != null && loser != null) {
      final winnerScore = match.creatorId == winnerId ? match.creatorScore : match.opponentScore;
      final loserScore = match.creatorId == loserId ? match.creatorScore : match.opponentScore;
      final scoreLead = (winnerScore ?? 0) - (loserScore ?? 0);

      final winnerMessage =
          'Congratulations, ${winner.displayName}! You won $$prizeAmount in your match against ${loser.displayName} with a score of $winnerScore-$loserScore (+$scoreLead lead).';
      final loserMessage =
          'You lost to ${winner.displayName} with a score of $loserScore-$winnerScore. Better luck next time!';

      await sendNotification(
        userId: winnerId,
        title: 'Match Result: You Won!',
        body: winnerMessage,
        data: {'type': 'match_won', 'matchId': match.id},
      );

      await sendNotification(
        userId: loserId,
        title: 'Match Result: You Lost',
        body: loserMessage,
        data: {'type': 'match_lost', 'matchId': match.id},
      );
    }
  }

  Future<void> sendMatchResultNotification(
      {required String winnerId,
      required String loserId,
      required double prizeAmount,
      required String matchId}) async {
    final match = await _ref.read(matchRepositoryProvider).getMatch(matchId);
    if (match != null) {
      await _sendPersonalizedMatchNotification(
        winnerId: winnerId,
        loserId: loserId,
        prizeAmount: prizeAmount,
        match: match,
      );
    }
  }
}

final notificationServiceProvider = Provider((ref) => NotificationService(ref));