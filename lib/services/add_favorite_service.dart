import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/constants.dart';

class AddFavoriteService {
  static Future<void> addFavorite(context, int apartmentId) async {
    Dio dio = Dio();
    dio.options.baseUrl = kBaseUrl;
    final prefs = await SharedPreferences.getInstance();
    dio.options.headers['Authorization'] = 'Bearer ${prefs.getString(kToken)}';
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
