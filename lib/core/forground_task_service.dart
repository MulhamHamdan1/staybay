import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:staybay/core/notification_worker.dart';

class ForegroundTaskService {
  static init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(2000),
        autoRunOnBoot: true,
      ),
    );
  }

  static void startNotificationForegroundService() {
    FlutterForegroundTask.startService(
      notificationTitle: 'StayBay Notifications',
      notificationText: 'Checking for new notifications...',
      callback: startCallback,
    );
  }

  // Callback links the TaskHandler
  static void startCallback() {
    FlutterForegroundTask.setTaskHandler(NotificationTaskHandler());
  }
}
