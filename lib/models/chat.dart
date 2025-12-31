class Chat {
  final int id;
  final int senderId;
  final int receiverId;

  Chat({required this.id, required this.senderId, required this.receiverId});

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'],
    senderId: json['sender_id'],
    receiverId: json['receiver_id'],
  );
}
