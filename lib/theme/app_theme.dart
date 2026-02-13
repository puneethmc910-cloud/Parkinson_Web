import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF2F80ED);
  static const Color softBackground = Color(0xFFF4F7FB);
  static const Color cardBackground = Colors.white;

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: softBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: primaryBlue,
        secondary: const Color(0xFF56CCF2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: softBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}


