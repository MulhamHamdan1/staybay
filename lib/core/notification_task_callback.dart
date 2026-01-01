import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:staybay/core/notification_worker.dart';

@pragma('vm:entry-point')
void notificationTaskCallback() {
  print('setted task handler san');
  FlutterForegroundTask.setTaskHandler(NotificationTaskHandler());
}
