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
                    BlocBuilder<NotificationCubit, NotificationState>(
                      builder: (_, state) =>
                          NotificationList(items: state.unread),
                    ),
                    BlocBuilder<NotificationCubit, NotificationState>(
                      builder: (_, state) {
                        cubit.fetchAll();
                        return NotificationList(items: state.all);
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
