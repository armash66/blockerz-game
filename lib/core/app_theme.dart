import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoardTheme {
  final String name;
  final Color gridLight;
  final Color gridDark;
  final Color borderColor;
  final Color player1Color;
  final Color player2Color;
  final Color blockedColor;

  const BoardTheme({
    required this.name,
    required this.gridLight,
    required this.gridDark,
    required this.borderColor,
    required this.player1Color,
    required this.player2Color,
    required this.blockedColor,
  });

  // Preset Themes
  static const classic = BoardTheme(
    name: 'Classic',
    gridLight: Color(0xFFEEEED2),
    gridDark: Color(0xFF769656),
    borderColor: Color(0xFF302E2B),
    player1Color: Color(0xFF4C81B6), // Blue
    player2Color: Color(0xFFB64C81), // Red/Pink
    blockedColor: Color(0xFF262522),
  );

  static const neon = BoardTheme(
    name: 'Neon',
    gridLight: Color(0xFF1A1A1A),
    gridDark: Color(0xFF2A2A2A),
    borderColor: Color(0xFF00FFCC), // Cyan Border
    player1Color: Color(0xFF00FFCC), // Cyan
    player2Color: Color(0xFFFF00FF), // Magenta
    blockedColor: Color(0xFF555555),
  );

  static const ice = BoardTheme(
    name: 'Ice',
    gridLight: Color(0xFFE3F2FD),
    gridDark: Color(0xFF90CAF9),
    borderColor: Color(0xFF1565C0),
    player1Color: Color(0xFF1E88E5), // Blue
    player2Color: Color(0xFF0D47A1), // Dark Blue
    blockedColor: Color(0xFF455A64),
  );

  static const lava = BoardTheme(
    name: 'Lava',
    gridLight: Color(0xFFFFCCBC),
    gridDark: Color(0xFFD84315),
    borderColor: Color(0xFFBF360C),
    player1Color: Color(0xFFFF5722), // Orange
    player2Color: Color(0xFF8D6E63), // Brown
    blockedColor: Color(0xFF3E2723),
  );

  static const List<BoardTheme> all = [classic, neon, ice, lava];
}

class AppTheme {
  // Global App Colors
  static const Color background = Color(0xFF302E2B);
  static const Color surface = Color(0xFF262522);
  static const Color accent = Color(0xFF81B64C);
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFF989795);

  // Current Theme State (Simple static for now, ideally Provider)
  static BoardTheme currentBoardTheme = BoardTheme.classic;

  static TextStyle get display => GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      );

  static TextStyle get heading => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      );

  static TextStyle get body => GoogleFonts.outfit(
        fontSize: 16,
        color: textSecondary,
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: surface,
        background: background,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      typography: Typography.material2021(),
    );
  }
}
