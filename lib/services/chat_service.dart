import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:staybay/core/dio_client.dart';
import 'package:staybay/models/chat.dart';
import 'package:staybay/models/message.dart';

class ChatApiService {
  static Dio dio = DioClient.dio;

  ChatApiService();

  ChatApiService._();

  static Future<ChatApiService> create() async {
    final service = ChatApiService._();
    return service;
  }

  // Get all chats
  Future<List<Chat>> getChats() async {
    final response = await dio.get('/chat');
    return (response.data as List).map((e) => Chat.fromJson(e)).toList();
  }

  static Future<Chat> getChat(int receiverId) async {
    try {
      final response = await dio.get(
        '/chat/show',
        queryParameters: {'receiver_id': receiverId},
      );
      // Assuming the response contains a valid Chat object
      return Chat.fromJson(response.data);
    } catch (e) {
      // Handle error
      log('Error fetching chat: $e');
      rethrow; // Optionally rethrow or handle the error as needed
    }
  }

  // Get single chat messages
  Future<List<Message>> getMessages(int chatId) async {
    final response = await dio.get('/chat/$chatId');
    return (response.data as List).map((e) => Message.fromJson(e)).toList();
  }

  // Send message
  Future<Message> sendMessage(
    int chatId,
    String message,
    int receiverId,
  ) async {
    final response = await dio.post(
      '/chat/send',
      data: {'chat_id': chatId, 'message': message, 'receiver_id': receiverId},
    );
    return Message.fromJson(response.data);
  }

  // Delete message
  Future<void> deleteMessage(int messageId) async {
    await dio.delete('/message/$messageId');
  }

  // Edit message
  Future<Message> editMessage(int messageId, String message) async {
    final response = await dio.patch(
      '/message/$messageId',
      data: {'message': message},
    );
    return Message.fromJson(response.data);
  }

  // Mark as read
  Future<void> markRead(int messageId) async {
    await dio.patch('/message/$messageId/read');
  }
}
