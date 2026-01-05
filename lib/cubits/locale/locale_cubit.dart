import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/constants.dart';
import 'package:staybay/cubits/locale/locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit()
    : super(
        LocaleState(
          currentLanguage: 'EN',
          localizedStrings: {},
          textDirection: TextDirection.ltr,
        ),
      );
  // Public initializer
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    String savedLanguage = prefs.getString(kLnaguage) ?? 'EN';
    await _loadLocalizedStrings(savedLanguage);
  }
  // New method this is for the first method remove if you want this
  // Future<void> loadInitial() async {
  //   await _loadLocalizedStrings();
  // }

  Future<void> _loadLocalizedStrings(String languageCode) async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/locales/$languageCode.json',
      );
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      emit(
        state.copyWith(
          currentLanguage: languageCode,
          localizedStrings: jsonMap,
          textDirection: languageCode == 'AR'
              ? TextDirection.rtl
              : TextDirection.ltr,
          isLoaded: true,
        ),
      );
    } on Exception catch (e) {
      log('error loading language: $e');
    }
  }

  void changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLnaguage, languageCode);
    // emit(state.copyWith(currentLanguage: languageCode));
    _loadLocalizedStrings(languageCode);
  }
}
