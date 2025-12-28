import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/consetans.dart';
import 'package:staybay/models/book_model.dart';

class GetMyBookingService {
  static Future<List<BookModel>> getMyBooking() async {
    List<BookModel> myBooking = [];
    final prefs = await SharedPreferences.getInstance();

    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] =
          'Bearer ${prefs.getString(kToken)}';

      var response = await dio.get('${kBaseUrl}/bookings');
      dynamic jsonData = response.data;
      List<dynamic> booksJson = jsonData['data'];
      for (var bookJson in booksJson) {
        BookModel book = BookModel.fromJson(bookJson);
        myBooking.add(book);
      }
      return myBooking;
    } on DioException catch (e) {
      log('Dio error: ${e.response?.data ?? e.message}');
      return myBooking;
    } catch (e) {
      return myBooking;
    }
  }
}
