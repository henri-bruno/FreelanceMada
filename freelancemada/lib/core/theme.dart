import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      primaryColor: AppConstants.goldColor,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.goldColor,
        secondary: AppConstants.goldDark,
        surface: AppConstants.cardColor,
        error: AppConstants.errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.goldColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppConstants.goldColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A4A), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.secondaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.goldColor, width: 2),
        ),
        labelStyle: const TextStyle(color: AppConstants.textMuted),
        hintStyle: const TextStyle(color: AppConstants.textMuted),
        prefixIconColor: AppConstants.goldColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.goldColor,
          foregroundColor: AppConstants.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppConstants.goldColor),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppConstants.secondaryColor,
        selectedColor: AppConstants.goldColor.withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: AppConstants.textLight),
        side: const BorderSide(color: AppConstants.goldColor, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.primaryColor,
        selectedItemColor: AppConstants.goldColor,
        unselectedItemColor: AppConstants.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      dividerColor: const Color(0xFF2A2A4A),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppConstants.textLight, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppConstants.textLight, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: AppConstants.textLight, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppConstants.textLight),
        bodyLarge: TextStyle(color: AppConstants.textLight),
        bodyMedium: TextStyle(color: AppConstants.textMuted),
        labelLarge: TextStyle(color: AppConstants.goldColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
