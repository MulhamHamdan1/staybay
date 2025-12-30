import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/constants.dart';

class GetApartmentNotAvailableDatesService {
  static Future<List<DateTime>> getDisabledDates(String? apartmentId) async {
    final List<DateTime> disabledDates = [];
    final prefs = await SharedPreferences.getInstance();

    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] =
          'Bearer ${prefs.getString(kToken)}';

      var response = await dio.get(
        '$kBaseUrl/apartments/$apartmentId/not-avaliable-dates',
      );

      List<dynamic> data = response.data['data'];

      for (var range in data) {
        DateTime start = DateTime.parse(range['start_date']);
        DateTime end = DateTime.parse(range['end_date']);

        for (int i = 0; i <= end.difference(start).inDays; i++) {
          disabledDates.add(start.add(Duration(days: i)));
        }
      }
      return disabledDates;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
}
