import 'package:flutter/services.dart';

class LocaleState {
  final String currentLanguage;
  final Map<String, dynamic> localizedStrings;
  final TextDirection textDirection;

  LocaleState({
    required this.currentLanguage,
    required this.localizedStrings,
    required this.textDirection,
  });

  LocaleState copyWith({
    String? currentLanguage,
    Map<String, dynamic>? localizedStrings,
    TextDirection? textDirection,
  }) {
    return LocaleState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      localizedStrings: localizedStrings ?? this.localizedStrings,
      textDirection: textDirection ?? this.textDirection,
    );
  }
}
