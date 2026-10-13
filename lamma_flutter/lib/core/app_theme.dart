import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF101215);
  static const surface = Color(0xFF1C1F24);
  static const border = Color(0xFF30343B);
  static const muted = Color(0xFF9CA3AF);
  static const ink = Color(0xFF181D12);
  static const lime = Color(0xFFD5F85A);
  static const purple = Color(0xFFB5A0FF);
  static const blue = Color(0xFF8FD6F5);
  static const peach = Color(0xFFFFB68F);
  static const gold = Color(0xFFFFCD6A);
  static const white = Color(0xFFF4F4F0);
}

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Tajawal',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.lime,
      onPrimary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.white,
      outline: AppColors.border,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(fontSize: 16, height: 1.6),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      contentPadding: const EdgeInsets.all(18),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surface,
      contentTextStyle: TextStyle(
        fontFamily: 'Tajawal',
        color: AppColors.white,
      ),
    ),
  );
}
