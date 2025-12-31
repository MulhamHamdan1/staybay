import 'package:flutter/material.dart';
import 'package:staybay/services/api_notifications_service.dart';

class NotificationList extends StatelessWidget {
  final List items;
  final bool isRead;
  const NotificationList({
    super.key,
    required this.items,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No notifications'));
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final n = items[index];
        if (isRead) {
          return Dismissible(
            key: ValueKey(n.id),
            direction: DismissDirection.endToStart, // swipe LEFT
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.done, color: Colors.white),
            ),
            onDismissed: (_) async {
              await ApiNotificationService.markAsRead(n.id);

              // setState(() {
              //   notifications.removeWhere((item) => item.id == n.id);
              // });
            },
            child: ListTile(
              title: Text(n.data?['type'] ?? 'Notification'),
              subtitle: Text(n.message),
              leading: const Icon(Icons.notifications),
            ),
          );
        } else {
          return ListTile(
            title: Text(n.data?['type'] ?? 'Notification'),
            subtitle: Text(n.message),
            leading: const Icon(Icons.notifications),
          );
        }
      },
    );
  }
}
