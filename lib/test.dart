import 'package:flutter/material.dart';
import 'package:staybay/widgets/filter_dialog.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return FilterDialog();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
