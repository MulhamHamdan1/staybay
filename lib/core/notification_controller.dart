import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/services/api_notifications_service.dart';
import 'package:staybay/models/notification_model.dart';

class NotificationState {
  final int unreadCount;
  final List<NotificationModel> unread;
  final List<dynamic> all;

  NotificationState({
    this.unreadCount = 0,
    this.unread = const [],
    this.all = const [],
  });

  NotificationState copyWith({
    int? unreadCount,
    List<NotificationModel>? unread,
    List<dynamic>? all,
  }) {
    return NotificationState(
      unreadCount: unreadCount ?? this.unreadCount,
      unread: unread ?? this.unread,
      all: all ?? this.all,
    );
  }
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationState());

  Timer? _timer;

  void startPolling() {
    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) {
      fetchUnreadCount();
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> fetchUnreadCount() async {
    try {
      final unread = await ApiNotificationService.fetchUnread();
      emit(state.copyWith(unreadCount: unread.length, unread: unread));
    } catch (e) {
      log('Error fetchUnreadCount: $e');
    }
  }

  Future<void> fetchUnread() async {
    try {
      final unread = await ApiNotificationService.fetchUnread();
      emit(state.copyWith(unread: unread));
    } catch (e) {
      log('Error fetchUnread: $e');
    }
  }

  Future<void> fetchAll() async {
    try {
      final all = await ApiNotificationService.fetchAll();
      emit(state.copyWith(all: all));
    } catch (e) {
      log('Error fetchAll: $e');
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
