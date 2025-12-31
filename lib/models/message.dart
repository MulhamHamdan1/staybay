class Message {
  final int id;
  final int chatId;
  final String message;
  final int senderId;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatId,
    required this.message,
    required this.senderId,
    this.isRead = false,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    chatId: json['chat_id'],
    message: json['message'],
    senderId: json['sender_id'],
    isRead: json['is_read'] ?? false,
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'message': message,
    'chat_id': chatId,
    'sender_id': senderId,
  };
}
