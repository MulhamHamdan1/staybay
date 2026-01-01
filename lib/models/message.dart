import 'dart:developer';

class Message {
  final String? id;
  final int? chatId;
  final String body;
  final int? senderId;
  final bool isRead;
  final DateTime? createdAt;

  Message({
    this.id,
    this.chatId,
    required this.body,
    this.senderId,
    this.isRead = false,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Log the raw JSON to see what’s null
    log('Message.fromJson: $json');

    return Message(
      id: json['id'] != null ? json['id'].toString() : null,
      chatId: json['chat_id'] is int
          ? json['chat_id'] as int
          : int.tryParse(json['chat_id']?.toString() ?? ''),
      body: json['body']?.toString() ?? '', // safest
      senderId: json['sender_id'] is int
          ? json['sender_id'] as int
          : int.tryParse(json['sender_id']?.toString() ?? ''),
      isRead: json['is_read'] == null ? false : json['is_read'] as bool,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'body': body,
    'chat_id': chatId,
    'sender_id': senderId,
  };
}
