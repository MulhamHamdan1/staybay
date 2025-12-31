import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/constants.dart';
import 'package:staybay/core/dio_client.dart';

class LogoutService {
  static void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kIsLoggedIn, false);
    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer ${prefs.getString(kToken)}';
    try {
      await dio.post('${kBaseUrl}/user/logout');
      await DioClient.clearToken();
    } catch (e) {
      log('Logout error: $e');
    }
  }
}
