import 'package:dio/dio.dart';
import 'package:staybay/core/dio_client.dart';
import 'package:staybay/models/notification_model.dart';

class ApiNotificationService {
  static Dio dio = createDio();
  ApiNotificationService();
  static Future<List<NotificationModel>> fetchUnread() async {
    final response = await dio.get('/api/notifications');
    if (response.data == null || response.data['unread'] == null) {
      return [];
    }
    final List data = response.data['unread'];

    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  static Future<List<dynamic>> fetchAll() async {
    final response = await dio.get('/api/notifications');
    return [...response.data['unread'], ...response.data['read']];
  }

  static Future<void> markAllAsRead() async {
    await dio.post('/api/notifications/read-all');
  }
}
