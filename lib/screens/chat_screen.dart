import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/chat/chat_cubit.dart';
import 'package:staybay/cubits/chat/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final int receiverId;

  const ChatScreen({super.key, required this.chatId, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatCubit cubit;

  @override
  void initState() {
    super.initState();
    // Create cubit if not already provided
    cubit = ChatCubit(chatId: widget.chatId);
    cubit.startPolling();
  }

  @override
  void dispose() {
    cubit.stopPolling();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: AppBar(title: Text('Chat')),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      return ListTile(
                        title: Align(
                          alignment: msg.senderId == widget.receiverId
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: msg.senderId == widget.receiverId
                                  ? Colors.grey[300]
                                  : Colors.blue[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(msg.message),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(child: TextField(controller: _controller)),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    cubit.sendMessage(text, widget.receiverId);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
