import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:staybay/constants.dart';
import 'package:staybay/models/apartment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateApartmentService {
  static Future<Response?> updateApartment({
    required BuildContext context,
    required Apartment apartment,
    required int cityId,
    required List<int> deletedImageIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kToken);

    if (token == null) return null;

    final Dio dio = Dio();
    dio.options.baseUrl = kBaseUrl;

    try {
      final Map<String, dynamic> data = {
        '_method': 'PUT',
        'city_id': cityId,
        'title': apartment.title,
        'description': apartment.description,
        'price': apartment.pricePerNight,
        'bathrooms': apartment.baths,
        'bedrooms': apartment.beds,
        'size': apartment.areaSqft.toInt(),
        'has_pool': apartment.amenities.contains('pool') ? 1 : 0,
        'has_wifi': apartment.amenities.contains('wifi') ? 1 : 0,
      };
 
      if (!apartment.imagePath.startsWith('http')) {
        data['cover_image'] = await MultipartFile.fromFile(
          apartment.imagePath,
          filename: apartment.imagePath.split('/').last,
        );
      }
 
      List<MultipartFile> galleryFiles = [];
      for (String path in apartment.imagesPaths) { 
        if (!path.startsWith('http')) {
          galleryFiles.add(
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          );
        }
      }
      
      if (galleryFiles.isNotEmpty) {
        data['new_images[]'] = galleryFiles;
      }
 
      if (deletedImageIds.isNotEmpty) {
        data['deleted_images[]'] = deletedImageIds;
      }

      final formData = FormData.fromMap(data);

      final response = await dio.post(
        '/apartments/${apartment.id}',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return response;
    } on DioException catch (e) {
      log('Update Error Response: ${e.response?.data}');
      return e.response;
    } catch (e) {
      log('Unexpected Service Error: $e');
      return null;
    }
  }
}
