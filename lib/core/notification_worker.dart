import 'dart:async';
import 'dart:developer';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:staybay/core/notification_cache.dart';
import 'package:staybay/models/notification_model.dart';
import 'package:staybay/services/api_notifications_service.dart';
import 'package:staybay/services/local_notification_service.dart';

class NotificationTaskHandler extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('started service');
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
      List<NotificationModel> unreadNotificationsBackend =
          await ApiNotificationService.fetchUnread();

      List<NotificationModel> unreadNotifications =
          await NotificationCache.getNotShowedNotifications(
            unreadNotificationsBackend,
          );

      if (unreadNotifications.isNotEmpty) {
        LocalNotificationService.show(
          title: 'You have unread Notifications',
          body: unreadNotifications.toString(),
        );
      }
    } catch (e) {
      log('Error in NotificationTaskHandler: $e');
    }
  }
}
