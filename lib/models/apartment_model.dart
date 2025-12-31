import 'package:staybay/constants.dart';
import 'package:staybay/models/city_model.dart';
import 'package:staybay/models/governorate_model.dart';

class Apartment {
  String? id;
  final String title;
  final String? location;
  final double pricePerNight;
  final String imagePath;
  String rating;
  int ratingCount;
  final int beds;
  final int baths;
  final double areaSqft;
  final String? ownerName;
  final List<String> amenities;
  final String description;
  final List<String> imagesPaths;
  bool isFavorite;
  City? city;
  Governorate? governorate;
  List<int>? imagesIDs;
  final int? ownerId;

  Apartment({
    this.id,
    this.location,
    this.ownerName,
    required this.title,
    required this.pricePerNight,
    required this.imagePath,
    required this.rating,
    required this.ratingCount,
    required this.beds,
    required this.baths,
    required this.areaSqft,
    required this.description,
    required this.imagesPaths,
    this.imagesIDs,
    this.isFavorite = false,
    required this.amenities,
    this.city,
    this.governorate,
    this.ownerId,
  });
  factory Apartment.fromJson(Map<String, dynamic> json) {
    var hasWifi = json['has_wifi'] == 1 ? 'wifi' : null;
    var hasPool = json['has_pool'] == 1 ? 'pool' : null;
    List<String> amenities = [];
    amenities.addAll([
      if (hasWifi != null) hasWifi,
      if (hasPool != null) hasPool,
    ]);

    var governorate = json['governorate']['name'];
    var city = json['city']['name'];
    var location = '$city, $governorate';

    var images = json['images'] as List<dynamic>;
    List<String> imagesPaths = [];
    List<int> imagesIds = [];
    for (var image in images) {
      String path = image['path'];
      int id = image['id'];
      imagesIds.add(id);
      if (path.contains("https")) {
        imagesPaths.add(path);
      } else {
        imagesPaths.add('$kBaseUrlImage/$path');
      }
    }
    var ownerFirstName = json['owner']['first_name'];
    var ownerLastName = json['owner']['last_name'];
    var ownerName = '$ownerFirstName $ownerLastName';
    return Apartment(
      id: json['id'].toString(),
      title: json['title'],
      location: location,
      pricePerNight: (json['price'] ?? 0).toDouble(),
      imagePath: imagesPaths.first,
      rating: json['rating'].toString(),
      ratingCount: json['rating_count'],
      beds: json['bedrooms'],
      baths: json['bathrooms'],
      areaSqft: json['size'].toDouble(),
      ownerName: ownerName,
      amenities: amenities,
      description: json['description'] ?? '',
      imagesPaths: imagesPaths,
      isFavorite: json['is_favorite'],
      city: City.fromJson(json['city']),
      governorate: Governorate.fromJson(json['governorate']),
      imagesIDs: imagesIds,
      ownerId: json['owner_id'],
    );
  }
}
