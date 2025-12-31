import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/core/notification_controller.dart';
import 'package:staybay/widgets/notificaiton_list.dart';

void showNotificationPopup(BuildContext context) {
  final cubit = context.read<NotificationCubit>();

  cubit.fetchUnread();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return DefaultTabController(
        length: 2,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Unread'),
                  Tab(text: 'All'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Unread tab
                    BlocBuilder<NotificationCubit, NotificationState>(
                      builder: (_, state) {
                        return Column(
                          children: [
                            if (state.unread.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await context
                                        .read<NotificationCubit>()
                                        .markAllAsRead();
                                  },
                                  icon: const Icon(Icons.done_all),
                                  label: const Text('Mark all as read'),
                                ),
                              ),
                            Expanded(
                              child: NotificationList(
                                items: state.unread,
                                isRead: true,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // All tab
                    BlocBuilder<NotificationCubit, NotificationState>(
                      builder: (_, state) {
                        // You can still fetchAll here if needed
                        cubit.fetchAll();
                        return NotificationList(
                          items: state.all,
                          isRead: false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
