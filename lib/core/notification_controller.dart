import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/services/api_notifications_service.dart';

class NotificationState {
  final int unreadCount;
  final List unread;
  final List all;

  NotificationState({
    this.unreadCount = 0,
    this.unread = const [],
    this.all = const [],
  });

  NotificationState copyWith({int? unreadCount, List? unread, List? all}) {
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
    final unread = await ApiNotificationService.fetchUnread();
    emit(state.copyWith(unreadCount: unread.length, unread: unread));
  }

  Future<void> fetchUnread() async {
    final unread = await ApiNotificationService.fetchUnread();
    emit(state.copyWith(unread: unread));
  }

  Future<void> fetchAll() async {
    final all = await ApiNotificationService.fetchAll();
    emit(state.copyWith(all: all));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
