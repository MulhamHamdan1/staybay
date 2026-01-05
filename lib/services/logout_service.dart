import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:staybay/core/dio_client.dart';
import 'package:staybay/core/forground_task_service.dart';

class LogoutService {
  static void logout() async {
    Dio dio = DioClient.dio;
    try {
      await dio.post('/user/logout');
      await DioClient.clearToken();
      await ForegroundTaskService.stop();
    } catch (e) {
      log('Logout error: $e');
    }
  }
}
