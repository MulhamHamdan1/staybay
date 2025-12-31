import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/constants.dart';
import 'package:staybay/models/apartment_model.dart';

class UpdateApartmentService {
  /// Updates an apartment
  /// [deletedImageIds] are the IDs of images to delete
  /// [newCoverImagePath] is the local path if the cover image changed
  static Future<Response?> updateApartment({
    required BuildContext context,
    required Apartment apartment,
    required int cityId,
    List<int> deletedImageIds = const [],
    String? newCoverImagePath,
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
      final Map<String, dynamic> dataMap = {
        '_method': 'PUT', // for file uploads compatibility
      };

      // Send fields only if changed / non-null
      if (apartment.title.isNotEmpty) dataMap['title'] = apartment.title;
      if (apartment.description.isNotEmpty)
        dataMap['description'] = apartment.description;
      dataMap['price'] = apartment.pricePerNight;
      dataMap['bathrooms'] = apartment.baths;
      dataMap['bedrooms'] = apartment.beds;
      dataMap['size'] = apartment.areaSqft.toInt();
      dataMap['city_id'] = cityId;
      dataMap['has_pool'] = apartment.amenities.contains('pool') ? 1 : 0;
      dataMap['has_wifi'] = apartment.amenities.contains('wifi') ? 1 : 0;

      // Handle cover image if changed
      if (newCoverImagePath != null && newCoverImagePath.isNotEmpty) {
        dataMap['cover_image'] = await MultipartFile.fromFile(
          newCoverImagePath,
          filename: newCoverImagePath.split('/').last,
        );
      }

      // Handle new images (local files only)
      final List<MultipartFile> newFiles = [];
      for (var path in apartment.imagesPaths) {
        if (!path.startsWith('http')) {
          newFiles.add(
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          );
        }
      }
      if (newFiles.isNotEmpty) {
        dataMap['new_images'] = newFiles;
      }

      // Handle deleted images (IDs from the database)
      if (deletedImageIds.isNotEmpty) {
        dataMap['delete_images'] = deletedImageIds;
      }

      if (dataMap.keys.length <= 1) {
        // Nothing to update
        _showError(context, 'No changes to update');
        return null;
      }

      final formData = FormData.fromMap(dataMap);

      log(
        'Updating apartment ID: ${apartment.id} with data keys: ${dataMap.keys}',
      );

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
