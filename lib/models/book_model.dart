import 'package:staybay/models/apartment_model.dart';

class BookModel {
  final Apartment apartment;
  final String startDate;
  final String endDate;
  final String status;
  final double totalePrice;
  final double rating;
  final String ratedAt;
  final bool userCanRate;
  final bool isPaid;
  final bool userCanPay;
  final String createdAt;
  final String updateAt;

  BookModel({
    required this.apartment,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalePrice,
    required this.rating,
    required this.ratedAt,
    required this.userCanRate,
    required this.isPaid,
    required this.userCanPay,
    required this.createdAt,
    required this.updateAt,
  });
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      apartment: Apartment.fromJson(json['apartment']),
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      totalePrice: json['total_price'],
      rating: json['rating'],
      ratedAt: json['rated_at'],
      userCanRate: json['user_can_rate'],
      isPaid: json['is_paid'],
      userCanPay: json['user_can_pay'],
      createdAt: json['created_at'],
      updateAt: json['updated_at'],
    );
  }
}
