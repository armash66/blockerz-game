import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors (Chess.com / Ludo inspired)
  static const Color background = Color(0xFF302E2B); // Gunmetal
  static const Color surface = Color(0xFF262522); // Darker Surface
  static const Color accent = Color(0xFF81B64C); // Neon Green (Success/Primary)
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFF989795);
  static const Color error = Color(0xFFFA412D);

  // Text Styles
  static TextStyle get display => GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: 1.5,
      );

  static TextStyle get heading => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get body => GoogleFonts.outfit(
        fontSize: 16,
        color: textSecondary,
      );

  // ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: surface,
        background: background,
        error: error,
      ),
      textTheme: TextTheme(
        displayLarge: display,
        titleLarge: heading,
        bodyMedium: body,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: heading,
        iconTheme: const IconThemeData(color: textPrimary),
      ),
    );
  }
}
