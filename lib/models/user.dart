import 'package:staybay/constants.dart';

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
    String avatar = json['avatar'];
    if (avatar.contains("https")) {
      avatar = avatar;
    } else {
      avatar = '$kBaseUrlImage/${json['avatar']}';
    }
    return User(
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      balance: double.parse(json['balance'].toString()),
      avatar: avatar,
    );
  }
}
