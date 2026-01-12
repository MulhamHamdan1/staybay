import 'dart:async';
import 'dart:developer';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:staybay/core/dio_client.dart';
import 'package:staybay/core/notification_cache.dart';
import 'package:staybay/models/notification_model.dart';
import 'package:staybay/services/api_notifications_service.dart';
import 'package:staybay/services/local_notification_service.dart';

class NotificationTaskHandler extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('started service');
    await DioClient.init();
    // _timer = Timer.periodic(const Duration(seconds: 15), (_) async {
    //   try {
    //     List<NotificationModel> unreadNotificationsBackend =
    //         await ApiNotificationService.fetchUnread();

    //     List<NotificationModel> unreadNotifications =
    //         await NotificationCache.getNotShowedNotifications(
    //           unreadNotificationsBackend,
    //         );

    //     if (unreadNotifications.isNotEmpty) {
    //       LocalNotificationService.show(
    //         title: 'You have unread Notifications',
    //         body: unreadNotifications.toString(),
    //       );
    //     }
    //   } catch (e) {
    //     log('Error in NotificationTaskHandler: $e');
    //   }
    // });
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _timer?.cancel();
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    try {
      if (!DioClient.isInitialized) {
        await DioClient.init();
      }
      log('repeating');
      List<NotificationModel> unreadNotificationsBackend =
          await ApiNotificationService.fetchUnread();

      List<NotificationModel> unreadNotifications =
          await NotificationCache.getNotShowedNotifications(
            unreadNotificationsBackend,
          );

      if (unreadNotifications.isNotEmpty) {
        LocalNotificationService.show(
          title: 'StayBay unread Notifications',
          body: unreadNotifications.toString(),
        );
      }
    } catch (e) {
      log('Error in NotificationTaskHandler: $e');
    }
  }
}
