import 'package:dio/dio.dart';
import 'package:staybay/constants.dart';

Dio createDio() {
  final dio = Dio(
    BaseOptions(baseUrl: kBaseUrl, headers: {'Accept': 'application/json'}),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $kToken';
        return handler.next(options);
      },
    ),
  );

  return dio;
}
