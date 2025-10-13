import 'package:flutter/material.dart';

ThemeData buildLightTheme(bool highContrast) {
  final seed = Color(highContrast ? 0xFFB58A51 : 0xFFD4B483);

  // Pełny ColorScheme (ma m.in. surfaceVariant/outline itp.)
  var cs = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  ).copyWith(
    primary: seed,
    onPrimary: Colors.black,
    secondary: const Color(0xFF4A6FA5),
    onSecondary: Colors.white,
    tertiary: const Color(0xFF2A9D8F),
    onTertiary: Colors.white,
    error: const Color(0xFFCB3A29),
    onError: Colors.white,
    surface: Colors.white,
    onSurface: const Color(0xFF111111),
    background: Colors.white,
    onBackground: const Color(0xFF111111),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: cs.surface,
    cardColor: const Color(0xFFF7F5F0),
    appBarTheme: AppBarTheme(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        minimumSize: const Size(200, 56),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: cs.secondary),
    ),
    dividerColor: const Color(0xFFD9D9D9),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cs.secondary,
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
  );
}

ThemeData buildDarkTheme(bool highContrast) {
  final seed = Color(highContrast ? 0xFFE2C08E : 0xFFD4B483);

  var cs = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
  ).copyWith(
    primary: seed,
    onPrimary: Colors.black,
    secondary: const Color(0xFF85A7D0),
    onSecondary: Colors.black,
    tertiary: const Color(0xFF57C2B6),
    onTertiary: Colors.black,
    error: const Color(0xFFE06A5B),
    onError: Colors.black,
    surface: const Color(0xFF111111),
    onSurface: const Color(0xFFF2F2F2),
    background: const Color(0xFF111111),
    onBackground: const Color(0xFFF2F2F2),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: cs.surface,
    cardColor: const Color(0xFF1A1A1A),
    appBarTheme: AppBarTheme(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        minimumSize: const Size(200, 56),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: cs.tertiary),
    ),
    dividerColor: const Color(0xFF3A3A3A),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cs.secondary,
      contentTextStyle: const TextStyle(color: Colors.black),
    ),
  );
}
