import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/constants.dart';

class GetApartmentService {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: kBaseUrl, headers: {'Accept': 'application/json'}),
  );

  static Future<Map<String, dynamic>> getApartments({
    int page = 1,
    int perPage = 10,
    int? governorateId,
    int? cityId,
    String? bedrooms,
    String? bathrooms,
    double? priceMin,
    double? priceMax,
    double? sizeMin,
    double? sizeMax,
    double? ratingMin,
    double? ratingMax,
    bool? hasPool,
    bool? hasWifi,
    String? search,
    int? rooms,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kToken);

    final response = await _dio.get(
      '/apartments',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'governorate_id': governorateId,
        'city_id': cityId,
        'rooms': rooms,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'price_min': priceMin,
        'price_max': priceMax,
        'size_min': sizeMin,
        'size_max': sizeMax,
        'rating_min': ratingMin,
        'rating_max': ratingMax,
        'has_pool': hasPool == null ? null : (hasPool ? 1 : 0),
        'has_wifi': hasWifi == null ? null : (hasWifi ? 1 : 0),
        'search': search,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      }..removeWhere((k, v) => v == null),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }
}
