import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';
import 'package:staybay/cubits/locale/locale_state.dart';
import 'package:staybay/models/chat.dart';
import 'package:staybay/services/chat_service.dart';
import 'package:staybay/screens/chat_screen.dart';

class ChatButton extends StatelessWidget {
  final int? ownerId;
  final String buttonText;
  final Color? buttonColor;
  final TextStyle? textStyle;

  const ChatButton({
    super.key,
    required this.ownerId,
    required this.buttonText,
    this.buttonColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        Map<String, dynamic> locale = state.localizedStrings['ChatButton'];
        return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: buttonColor ?? Theme.of(context).primaryColor,
          ),
          onPressed: () async {
            if (ownerId == null) {
              log("Owner ID is null, cannot initiate chat.");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    locale['errorMissingID'] ??
                        'Cannot start chat: Owner ID is missing.',
                  ),
                ),
              );
              return;
            }

            try {
              Chat chat = await ChatApiService.getChat(ownerId!);

              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChatScreen(chatId: chat.id, receiverId: chat.receiverId),
                ),
              );
            } catch (e, st) {
              log("Error fetching or creating chat: $e\n$st");
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    locale['errorCreating'] ??
                        'Error creating or fetching chat.',
                  ),
                ),
              );
            }
          },
          child: Text(buttonText, style: textStyle),
        );
      },
    );
  }
}
