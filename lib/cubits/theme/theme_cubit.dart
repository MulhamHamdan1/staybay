import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial());
  bool isDarkMode = false;
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    if (isDarkMode) {
      emit(DarkModeState());
    } else {
      emit(LightModeState());
    }
  }
}
