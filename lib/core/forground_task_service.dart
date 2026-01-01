import 'dart:developer';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'notification_task_callback.dart';

class ForegroundTaskService {
  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'staybay_notifications',
        channelName: 'StayBay Notifications',
        channelDescription: 'Background notification service',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
      ),
    );
  }

  static Future<void> start() async {
    log('started service');
    await FlutterForegroundTask.startService(
      notificationTitle: 'StayBay',
      notificationText: 'Listening for notifications',
      callback: notificationTaskCallback,
    );
  }

  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }
}
