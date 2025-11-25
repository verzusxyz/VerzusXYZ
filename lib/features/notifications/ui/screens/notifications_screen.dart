import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/features/notifications/data/models/notification_model.dart';
import 'package:verzus/features/notifications/data/repositories/notification_repository.dart';
import 'package:verzus/utils/responsive.dart';
import 'package:verzus/widgets/shimmers.dart';

final notificationsStreamProvider = StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final authUser = ref.watch(authRepositoryProvider).currentUser;
  if (authUser == null) return Stream.value([]);
  return ref.watch(notificationRepositoryProvider).getUserNotifications(authUser.uid);
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'You have no notifications.',
                style: TextStyle(fontSize: responsive.diagonalPercent(0.018)),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(responsive.widthPercent(0.04)),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: EdgeInsets.only(bottom: responsive.heightPercent(0.015)),
                child: ListTile(
                  leading: Icon(
                    notification.isRead ? Icons.notifications : Icons.notifications_active,
                    color: notification.isRead
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: responsive.diagonalPercent(0.019),
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    notification.body,
                    style: TextStyle(fontSize: responsive.diagonalPercent(0.016)),
                  ),
                  onTap: () {
                    if (!notification.isRead) {
                      ref.read(notificationRepositoryProvider).markAsRead(notification.userId, notification.id);
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: EdgeInsets.all(responsive.widthPercent(0.04)),
          itemCount: 10,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(bottom: responsive.heightPercent(0.015)),
            child: VerzusShimmers.listTile(),
          ),
        ),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
