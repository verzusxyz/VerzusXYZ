import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/notifications/data/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _firestore
        .collection('users')
        .doc(notification.userId)
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}

final notificationRepositoryProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  return NotificationRepository(firestore);
});
