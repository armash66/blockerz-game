import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/audio_manager.dart';

class ThemeToggleBtn extends StatelessWidget {
  final VoidCallback onToggle;

  const ThemeToggleBtn({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'theme_toggle', // Unique tag for hero animation
      mini:
          true, // Make it smaller for game screens? Or keep regular. Let's keep regular but maybe bottom right.
      backgroundColor: AppTheme.accent,
      onPressed: () {
        AudioManager().playClick();
        AppTheme.toggleTheme();
        onToggle(); // Notify parent to rebuild

        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Switched to ${AppTheme.isDark ? 'Dark' : 'Light'} Mode"),
          duration: const Duration(milliseconds: 1000),
          backgroundColor: AppTheme.accent,
        ));
      },
      child: Icon(
        AppTheme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: Colors.white,
      ),
    );
  }
}
