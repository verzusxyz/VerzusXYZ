import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  void showRecordingNotification() {
    AwesomeNotifications().createNotification(
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
    AwesomeNotifications().createNotification(
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
    AwesomeNotifications().dismiss(1);
  }

  void dismissRecording(int id) {
    AwesomeNotifications().dismiss(id);
  }

  void showMatchFinished(String matchId) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,
        channelKey: 'basic_channel',
        title: 'Match Finished',
        body: 'Your match has finished processing.',
        payload: {'matchId': matchId},
      ),
    );
  }
}
