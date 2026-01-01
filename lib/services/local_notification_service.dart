import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const linux = LinuxInitializationSettings(
      defaultActionName: 'staybay notification',
    );
    const settings = InitializationSettings(android: android, linux: linux);
    await _plugin.initialize(settings);
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'notifications_channel',
      'Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.critical,
    );
    await _plugin.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails, linux: linuxDetails),
    );
  }
}
