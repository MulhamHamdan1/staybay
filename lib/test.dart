import 'package:flutter/material.dart';
import 'package:staybay/widgets/rating_dialog.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              final selectedRating = await showDialog<int>(
                context: context,
                builder: (_) => const RatingDialog(),
              );
            },
            icon: Icon(Icons.access_alarm_rounded),
          ),
        ],
      ),
    );
  }
}
