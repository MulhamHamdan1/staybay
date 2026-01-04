import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:staybay/core/dio_client.dart';
import 'package:staybay/models/user.dart';

class GetMeService {
  static Future<User?> getMe() async {
    Dio dio = DioClient.dio;
    try {
      final response = await dio.get('/user/me');
      User user = User.fromJson(response.data['data']);
      log('User data: ${user.avatar}  ');
      return user;
    } on DioException catch (e) {
      log('Dio error: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      log('Unexpected error: $e');
      return null;
    }
  }
}
