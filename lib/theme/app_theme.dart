import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getTheme(Brightness brightness, Color primaryColor) {
    final bool isLight = brightness == Brightness.light;
    final Color backgroundColor = isLight ? const Color(0xFFFAF5FF) : const Color(0xFF1A1A2E);
    final Color cardColor = isLight ? Colors.white : const Color(0xFF2A2A3E);
    final Color textColor = isLight ? Colors.black : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: const Color(0xFFA7F3D0),
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        surface: cardColor,
        onSurface: textColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          bodyLarge: TextStyle(fontSize: 16, color: textColor),
          bodyMedium: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: cardColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  static final ThemeData lightTheme = getTheme(Brightness.light, const Color(0xFF8B5CF6));
  static final ThemeData darkTheme = getTheme(Brightness.dark, const Color(0xFF8B5CF6));
}