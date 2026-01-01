import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';

class Governorate {
  final int id;
  final String name;

  Governorate({required this.id, required this.name});

  factory Governorate.fromJson(Map<String, dynamic> json) {
    return Governorate(id: json['id'], name: json['name']);
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Governorate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

extension GovernorateLocalization on Governorate {
  String localized(BuildContext context) {
    final locale = context
        .read<LocaleCubit>()
        .state
        .localizedStrings['searchFilters'];

    final governorates = locale?['governorates'] as Map<String, dynamic>?;

    return governorates?[name.trim()] ?? name;
  }
}
