import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:staybay/core/dio_client.dart';

class RemoveFavoriteService {
  static Future<void> removeFavorite(context, int apartmentId) async {
    Dio dio = DioClient.dio;
    try {
      await dio.delete('/apartments/favorite/remove/$apartmentId');
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
