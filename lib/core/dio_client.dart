import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/constants.dart';

class DioClient {
  DioClient._();

  static Dio? _dio;
  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(kToken);

    _dio = Dio(
      BaseOptions(baseUrl: kBaseUrl, headers: {'Accept': 'application/json'}),
    );

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
      ),
    );

    log('Dio initialized with token: $_token');
  }

  /// Always use this Dio instance
  static Dio get dio {
    // log(_token!);
    if (_dio == null) {
      throw Exception(
        'DioClient not initialized. Call DioClient.init() in main().',
      );
    }
    return _dio!;
  }

  static get token {
    return _token;
  }

  /// Call this when user logs in
  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kToken, token);
    await prefs.setBool(kIsLoggedIn, true);
  }

  /// Call this when user logs out
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kToken);
    await prefs.setBool(kIsLoggedIn, false);
  }
}
