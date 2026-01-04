import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:staybay/core/dio_client.dart';

class AddFavoriteService {
  static Future<void> addFavorite(context, int apartmentId) async {
    Dio dio = DioClient.dio;
    try {
      await dio.post('/apartments/favorite/add/$apartmentId');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
