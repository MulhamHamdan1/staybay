import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/constants.dart';

Future<Dio> createDio() async {
  final dio = Dio(
    BaseOptions(baseUrl: kBaseUrl, headers: {'Accept': 'application/json'}),
  );
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(kToken);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
    ),
  );

  return dio;
}
