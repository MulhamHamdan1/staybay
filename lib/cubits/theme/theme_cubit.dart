import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staybay/consetans.dart';
import 'package:staybay/cubits/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial());

  late bool isDarkMode;
  void toggleTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool(kIsDark) ?? false;
    prefs.setBool(kIsDark, !isDarkMode);
    isDarkMode = prefs.getBool(kIsDark) ?? false;
    // log(message)
    if (isDarkMode) {
      emit(DarkModeState());
    } else {
      emit(LightModeState());
    }
  }
}
