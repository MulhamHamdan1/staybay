import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';

class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: json['id'], name: json['name']);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

extension CityLocalization on City {
  String localized(BuildContext context) {
    final locale = context
        .read<LocaleCubit>()
        .state
        .localizedStrings['searchFilters'];

    final cities = locale?['cities'] as Map<String, dynamic>?;

    return cities?[name.trim()] ?? name;
  }
}
