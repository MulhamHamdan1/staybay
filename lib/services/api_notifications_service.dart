import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:staybay/core/dio_client.dart';
import 'package:staybay/models/notification_model.dart';

class ApiNotificationService {
  static Dio dio = createDio();
  ApiNotificationService();

  static Future<List<NotificationModel>> fetchUnread() async {
    try {
      final response = await dio.get('/user/notifications');
      if (response.data == null || response.data['unread'] == null) return [];
      final List data = response.data['unread'];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      // Log error instead of throwing
      log('DioException fetchUnread: ${e.response?.data ?? e.message}');
      return [];
    } catch (e) {
      log('Unexpected error fetchUnread: $e');
      return [];
    }
  }

  static Future<List<dynamic>> fetchAll() async {
    try {
      final response = await dio.get('/user/notifications');
      return [...response.data['unread'] ?? [], ...response.data['read'] ?? []];
    } on DioException catch (e) {
      log('DioException fetchAll: ${e.response?.data ?? e.message}');
      return [];
    } catch (e) {
      log('Unexpected error fetchAll: $e');
      return [];
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      await dio.post('/user/notifications');
    } on DioException catch (e) {
      log('DioException markAllAsRead: ${e.response?.data ?? e.message}');
    } catch (e) {
      log('Unexpected error markAllAsRead: $e');
    }
  }
}
