import 'package:staybay/consetans.dart';

class User {
  final String firstName;
  final String lastName;
  final String phone;
  final String avatar;
  final double balance;
  User({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.avatar,
    required this.balance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'] != null ? json['first_name'] : "",
      lastName: json['last_name'] != null ? json['last_name'] : "",
      phone: json['phone'] != null ? json['phone'] : "",
      balance: json['balance'] != null
          ? double.parse(json['balance'].toString())
          : 0.0,
      avatar: json['avatar'] != null ? '$kBaseUrlImage/${json['avatar']}' : '',
    );
  }
}
