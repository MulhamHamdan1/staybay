import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/consetans.dart';
import 'package:staybay/models/city_model.dart';
import 'package:staybay/models/governorate_model.dart';

class GetGovernatesAndCities {
  final Dio _dio = Dio(BaseOptions(baseUrl: kBaseUrl));

  Future<List<Governorate>> getGovernorates() async {
    final prefs = await SharedPreferences.getInstance();
    _dio.options.headers['Authorization'] = 'Bearer ${prefs.getString(kToken)}';

    try {
      final response = await _dio.get('/governorates');
      if (response.statusCode == 200) {
        List data = response.data['data'];
        return data.map((json) => Governorate.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('there was a problem fetching governorates');
    }
  }

  Future<List<City>> getCities(int governorateId) async {
    try {
      final response = await _dio.get('/governorates/$governorateId');
      if (response.statusCode == 200) {
        List data = response.data['data']['cities'];
        return data.map((json) => City.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('there was a problem fetching cities');
    }
  }
}
