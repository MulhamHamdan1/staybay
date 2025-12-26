import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/consetans.dart';
import 'package:staybay/models/user.dart';

class GetMeService {
  static Future<User?> getMe() async {
    Dio dio = Dio();
    dio.options.baseUrl = kBaseUrl;
    final prefs = await SharedPreferences.getInstance();
    dio.options.headers['Authorization'] = 'Bearer ${prefs.getString(kToken)}';
    try {
      final response = await dio.get(
        '/user/me',
        options: Options(headers: {'Accept': 'application/json'}),
      );
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
