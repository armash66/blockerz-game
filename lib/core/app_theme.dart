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

  static BoardTheme next(BoardTheme current) {
    final index = all.indexOf(current);
    final nextIndex = (index + 1) % all.length;
    return all[nextIndex];
  }
}

class AppTheme {
  // Global App Colors (Dark Mode - Default)
  static const Color backgroundDark = Color(0xFF302E2B);
  static const Color surfaceDark = Color(0xFF262522);
  static const Color textPrimaryDark = Color(0xFFEEEEEE);
  static const Color textSecondaryDark = Color(0xFF989795);

  // Global App Colors (Light Mode)
  static const Color backgroundLight = Color(0xFFF1F0E9); // White/Beige
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF302E2B);
  static const Color textSecondaryLight = Color(0xFF706E6B);

  static const Color accent = Color(0xFF81B64C); // Green

  // Current Theme State
  static bool isDark = true;
  static BoardTheme currentBoardTheme = BoardTheme.classic;

  static void toggleTheme() {
    isDark = !isDark;
  }

  // Dynamic getters based on isDark
  static Color get background => isDark ? backgroundDark : backgroundLight;
  static Color get surface => isDark ? surfaceDark : surfaceLight;
  static Color get textPrimary => isDark ? textPrimaryDark : textPrimaryLight;
  static Color get textSecondary =>
      isDark ? textSecondaryDark : textSecondaryLight;

  static Color get borderColor => isDark ? Colors.white10 : Colors.black12;
  static Color get glassBorder =>
      isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

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

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: accent, surface: surface, background: background)
          : ColorScheme.light(
              primary: accent, surface: surface, background: background),
      iconTheme: IconThemeData(color: textPrimary),
      typography: Typography.material2021(),
    );
  }
}
