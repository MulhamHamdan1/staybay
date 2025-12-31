import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/models/message.dart';
import 'package:staybay/services/chat_service.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final int chatId;
  late final ChatApiService _api;
  Timer? _timer;

  ChatCubit({required this.chatId}) : super(ChatState()) {
    _api = ChatApiService();
  }

  /// Start polling every [intervalSeconds] seconds
  void startPolling({int intervalSeconds = 2}) {
    _timer ??= Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => fetchMessages(),
    );
  }

  /// Stop polling
  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  /// Fetch messages from API and update state incrementally
  Future<void> fetchMessages() async {
    try {
      final newMessages = await _api.getMessages(chatId);

      final currentMessages = state.messages;
      final updatedMessages = List<Message>.from(currentMessages);

      // Add new messages
      for (var msg in newMessages) {
        if (!currentMessages.any((m) => m.id == msg.id)) {
          updatedMessages.add(msg);
        }
      }

      // Remove deleted messages
      updatedMessages.removeWhere((m) => !newMessages.any((n) => n.id == m.id));

      emit(state.copyWith(messages: updatedMessages));

      // Mark visible messages as read
      for (var msg in updatedMessages) {
        if (!msg.isRead) {
          try {
            await _api.markRead(msg.id!);
          } catch (e) {
            // Ignore read errors
          }
        }
      }
    } on DioException catch (e) {
      // Handle Dio exceptions gracefully
      log('Chat fetchMessages error: ${e.message}');
    } catch (e) {
      log('Chat fetchMessages unexpected error: $e');
    }
  }

  /// Send a message and update state
  Future<void> sendMessage(String message, int receiverId) async {
    try {
      final sentMessage = await _api.sendMessage(chatId, message, receiverId);
      emit(state.copyWith(messages: [...state.messages, sentMessage]));
    } on DioException catch (e) {
      log('Chat sendMessage DioException: ${e.message}');
    } catch (e) {
      log('Chat sendMessage unexpected error: $e');
    }
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
