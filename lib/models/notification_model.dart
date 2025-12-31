class NotificationModel {
  final String id;
  final String message;
  final Map<String, dynamic>? data;

  NotificationModel({required this.id, required this.message, this.data});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      message: json['message'],
      data: json['data'],
    );
  }
  @override
  String toString() {
    return message;
  }
}
