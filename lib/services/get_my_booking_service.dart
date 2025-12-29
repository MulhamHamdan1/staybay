import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/consetans.dart';
import 'package:staybay/models/book_model.dart';

class GetMyBookingService {
  static Future<List<BookModel>> getMyBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kToken);
    
    try {
      Dio dio = Dio();
      dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      var response = await dio.get('$kBaseUrl/bookings');
       
      if (response.statusCode == 200) {
        final List<BookModel> myBooking = [];
        final Map<String, dynamic> jsonData = response.data;
        final List<dynamic> booksJson = jsonData['data'];

        for (var bookJson in booksJson) {
          try {
            myBooking.add(BookModel.fromJson(bookJson));
          } catch (itemError) {
            log('Error parsing a specific booking item: $itemError');
            log('Failing JSON: $bookJson');
          }
        }
        return myBooking;
      } else {
        log('Server returned status: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      log('Dio error: ${e.response?.data ?? e.message}');
      rethrow;  
    } catch (e) {
      log('General error in GetMyBookingService: $e');
      rethrow;
    }
  }
}
