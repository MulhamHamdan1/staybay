class NotificationModel {
  final int id;
  final String message;

  NotificationModel({required this.id, required this.message});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(id: json['id'], message: json['message']);
  }
  @override
  String toString() {
    return message;
  }
}
