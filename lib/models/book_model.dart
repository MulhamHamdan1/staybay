import 'package:staybay/models/apartment_model.dart';

class BookModel {
  final String? id;
  final Apartment apartment;
  final String startDate;
  final String endDate;
  final String status;
  final double totalPrice;
  final double totalPaid;
  final double rating;
  final String? ratedAt;
  final bool userCanRate;
  final bool isPaid;
  final bool canUserPay;
  final bool canUserEdit;
  final bool canOwnerEdit;
  final String createdAt;
  final String updatedAt;
  final int userId;

  BookModel({
    required this.id,
    required this.apartment,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalPrice,
    required this.totalPaid,
    required this.rating,
    this.ratedAt,
    required this.userCanRate,
    required this.isPaid,
    required this.canUserPay,
    required this.canUserEdit,
    required this.canOwnerEdit,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'].toString(),
      apartment: Apartment.fromJson(json['apartment']),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'],
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      ratedAt: json['rated_at'],
      userCanRate: json['user_can_rate'] ?? false,
      isPaid: json['is_paid'] ?? false,
      canUserPay: json['can_user_pay'] ?? false,
      canUserEdit: json['can_user_edit'] ?? false,
      canOwnerEdit: json['can_owner_edit'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }
}
