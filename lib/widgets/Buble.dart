import 'package:flutter/material.dart';
import 'package:staybay/models/message.dart';

class Bubble extends StatelessWidget {
  const Bubble({super.key, required this.message});
  final Message message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(left: 20, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(green: 0.7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(message.body),
        ),
      ),
    );
  }
}

class Bubblefriend extends StatelessWidget {
  const Bubblefriend({super.key, required this.message});
  final Message message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(left: 20, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(red: 0.7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(message.body),
        ),
      ),
    );
  }
}
