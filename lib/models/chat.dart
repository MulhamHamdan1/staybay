class Chat {
  final int id;
  final int senderId;
  final int receiverId;

  Chat({required this.id, required this.senderId, required this.receiverId});

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: int.parse(json['id'].toString()),
    senderId: int.parse(json['sender_id'].toString()),
    receiverId: int.parse(json['receiver_id'].toString()),
  );
}
