import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
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

  // Example of a specific notification trigger
  Future<void> sendMatchStartingNotification(String userId, String opponentName) async {
    await sendNotification(
      userId: userId,
      title: 'Your Match is Starting!',
      body: 'Your match against $opponentName is about to begin. Good luck!',
      data: {'type': 'match_starting'},
    );
  }
}

final notificationServiceProvider = Provider((ref) => NotificationService(ref));
