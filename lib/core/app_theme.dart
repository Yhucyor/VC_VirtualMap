import 'package:flutter/material.dart';

class AppTheme {
  // The primary color combinations with different tones/levels as requested
  static const Map<int, Color> primaryTones = {
    50: Color(0xFFE3F2FD),
    100: Color(0xFFBBDEFB),
    200: Color(0xFF90CAF9),
    300: Color(0xFF64B5F6),
    400: Color(0xFF42A5F5),
    500: Color(0xFF87CEEB),
    600: Color(0xFF64B5F6),
    700: Color(0xFF42A5F5),
    800: Color(0xFF2196F3),
    900: Color(0xFF1976D2),
  };

  static const Color primary = Color(0xFF87CEEB);
  static const Color secondary = Color(0xFFE53935); // Vibrant accent color
  static const Color background = Color(0xFFF5F7F4);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryTones[100]!,
        onPrimaryContainer: primaryTones[900]!,
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: secondary.withValues(alpha: 0.2),
        onSecondaryContainer: secondary,
        error: Colors.red,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: const Color(0xFF1C1B1F),
      ),
      scaffoldBackgroundColor: background,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryTones[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryTones[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
