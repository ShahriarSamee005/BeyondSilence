import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color bg = Color(0xFF080C14);
  static const Color surface = Color(0xFF0F1623);
  static const Color card = Color(0xFF151D2E);
  static const Color border = Color(0xFF1E2A42);
  static const Color teal = Color(0xFF00D4B4);
  static const Color blue = Color(0xFF1E90FF);
  static const Color text = Color(0xFFEAEEF6);
  static const Color textMuted = Color(0xFF6B7A99);
  static const Color textDim = Color(0xFF3D4F6E);
  static const Color error = Color(0xFFFF4D6D);
  static const Color success = Color(0xFF00D4B4);
  static const Color warning = Color(0xFFFFB347);
  static const Color adminGold = Color(0xFFFFD166);
}

class AppConstants {
  AppConstants._();
  static const String appName = 'Bangla Sign Translator';
  static const String version = '1.0.0';
  static const String developer = 'BST Dev Team';
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.teal,
      secondary: AppColors.blue,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.bg,
      onSurface: AppColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w700,
        color: AppColors.text, letterSpacing: 0.8,
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      hintStyle: TextStyle(color: AppColors.textDim, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.card,
      contentTextStyle: const TextStyle(color: AppColors.text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}