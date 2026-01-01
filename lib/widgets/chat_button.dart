import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:staybay/models/chat.dart';
import 'package:staybay/services/chat_service.dart';
import 'package:staybay/screens/chat_screen.dart';

class ChatButton extends StatelessWidget {
  final int? receiverId;
  final String buttonText;
  final Color? buttonColor;
  final TextStyle? textStyle;

  const ChatButton({
    super.key,
    required this.receiverId,
    this.buttonText = "Chat",
    this.buttonColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: buttonColor ?? Theme.of(context).primaryColor,
      ),
      onPressed: () async {
        if (receiverId == null) {
          log("Owner ID is null, cannot initiate chat.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cannot start chat: Owner ID is missing."),
            ),
          );
          return;
        }

        try {
          Chat chat = await ChatApiService.getChat(receiverId!);

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChatScreen(chatId: chat.id, receiverId: receiverId!),
            ),
          );
        } catch (e, st) {
          log("Error fetching or creating chat: $e\n$st");
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error creating or fetching chat.")),
          );
        }
      },
      child: Text(buttonText, style: textStyle),
    );
  }
}
