class NotificationModel {
  final String id;
  final String message;
  final Map<String, dynamic> data;

  NotificationModel({
    required this.id,
    required this.message,
    required this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'])
          : {},
    );
  }

  @override
  String toString() => message;
}
