import 'package:flutter/material.dart';

class NotificationList extends StatelessWidget {
  final List items;

  const NotificationList({super.key, required this.items});

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

        return ListTile(
          title: Text(n.title ?? 'Notification'),
          subtitle: Text(n.message ?? ''),
          leading: const Icon(Icons.notifications),
        );
      },
    );
  }
}
