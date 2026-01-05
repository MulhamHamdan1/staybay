import 'package:flutter/services.dart';

class LocaleState {
  final String currentLanguage;
  final Map<String, dynamic> localizedStrings;
  final TextDirection textDirection;
  final bool isLoaded;
  LocaleState({
    required this.currentLanguage,
    required this.localizedStrings,
    required this.textDirection,
    this.isLoaded = false,
  });

  LocaleState copyWith({
    String? currentLanguage,
    Map<String, dynamic>? localizedStrings,
    TextDirection? textDirection,
    bool? isLoaded,
  }) {
    return LocaleState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      localizedStrings: localizedStrings ?? this.localizedStrings,
      textDirection: textDirection ?? this.textDirection,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
