import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  final AwesomeNotifications _awesomeNotifications;

  NotificationService(this._awesomeNotifications);

  void showRecordingNotification() {
    _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: 'Recording in Progress',
        body: 'Your match is being recorded.',
        locked: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'STOP_RECORDING',
          label: 'Stop Recording',
        ),
      ],
    );
  }

  void showResultNotification(String matchId) {
    _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'basic_channel',
        title: 'Match Finished 🎯',
        body: 'Results captured — tap to review on VerzusXYZ',
        payload: {'matchId': matchId},
      ),
    );
  }

  void dismissRecordingNotification() {
    _awesomeNotifications.dismiss(1);
  }
}
