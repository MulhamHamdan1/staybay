import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/consetans.dart';
import 'package:staybay/models/apartment_model.dart';

class UpdateApartmentService {
  static Future<Response?> updateApartment({
    required BuildContext context,
    required Apartment apartment,
    required int cityId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kToken);

    if (token == null) {
      _showError(context, 'Not authenticated');
      return null;
    }

    final Dio dio = Dio();
    dio.options.baseUrl = kBaseUrl;

    try {
      // 1. Separate existing URLs from new local Files
      List<String> existingImages = [];
      List<MultipartFile> newFiles = [];

      for (var path in apartment.imagesPaths) {
        if (path.startsWith('http')) {
          existingImages.add(path);
        } else {
          newFiles.add(
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          );
        }
      }

      // 2. Determine the cover image
      // If the first image is a URL, send the string. If it's a local path, send a MultipartFile.
      dynamic coverImageData;
      String firstPath = apartment.imagesPaths.first;
      if (firstPath.startsWith('http')) {
        coverImageData = firstPath;
      } else {
        coverImageData = await MultipartFile.fromFile(
          firstPath,
          filename: firstPath.split('/').last,
        );
      }

      // 3. Build the Map for FormData
      final Map<String, dynamic> dataMap = {
        '_method':
            'PUT', // Method spoofing for backends that don't like PUT + Multipart
        'city_id': cityId,
        'title': apartment.title,
        'description': apartment.description,
        'price': apartment.pricePerNight,
        'bathrooms': apartment.baths,
        'bedrooms': apartment.beds,
        'size': apartment.areaSqft.toInt(),
        'has_pool': apartment.amenities.contains('pool') ? 1 : 0,
        'has_wifi': apartment.amenities.contains('wifi') ? 1 : 0,
        'cover_image': coverImageData,
        'existing_images[]': existingImages, // Send the list of URLs to keep
        'new_images[]': newFiles, // Send the actual new files
      };

      final formData = FormData.fromMap(dataMap);

      log('Updating apartment ID: ${apartment.id}');

      // Use POST with _method: PUT for better compatibility with file uploads
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Apartment updated'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return response;
    } on DioException catch (e) {
      log('Dio error: ${e.response?.data ?? e.message}');
      if (context.mounted) {
        _showError(
          context,
          e.response?.data['message'] ?? 'Failed to update apartment',
        );
      }
      return null;
    } catch (e) {
      log('Unexpected error: $e');
      if (context.mounted) {
        _showError(context, 'Unexpected error occurred');
      }
      return null;
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
