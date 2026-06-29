import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppConstants.primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.goldColor,
        secondary: AppConstants.goldDark,
        surface: AppConstants.surfaceColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppConstants.textPrimary,
        error: AppConstants.errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppConstants.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AppConstants.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.surfaceColor,
        selectedItemColor: AppConstants.goldColor,
        unselectedItemColor: AppConstants.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppConstants.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppConstants.borderColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.goldColor, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppConstants.textSecondary),
        hintStyle: const TextStyle(color: AppConstants.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.goldColor,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.goldColor,
          side: const BorderSide(color: AppConstants.goldColor),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppConstants.goldColor),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppConstants.card2Color,
        selectedColor: AppConstants.goldMuted,
        labelStyle: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: AppConstants.borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      dividerTheme: const DividerThemeData(
        color: AppConstants.borderColor,
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: AppConstants.textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: AppConstants.textPrimary),
        bodyMedium: TextStyle(color: AppConstants.textSecondary),
        bodySmall: TextStyle(color: AppConstants.textMuted, fontSize: 12),
        labelLarge: TextStyle(color: AppConstants.goldColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
