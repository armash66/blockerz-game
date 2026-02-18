import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/audio_manager.dart';
import 'glass_card.dart';
import 'primary_button.dart';

void showSettingsDialog(BuildContext context) {
  final audio = AudioManager();
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("SETTINGS", style: AppTheme.heading),
                  const SizedBox(height: 24),

                  // Music Toggle
                  _buildSettingRow(
                    "Music",
                    Icons.music_note_rounded,
                    audio.isMusicEnabled,
                    (val) {
                      setDialogState(() {
                        audio.toggleMusic();
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // SFX & Haptics Toggle
                  _buildSettingRow(
                    "Sound & Haptics",
                    Icons.volume_up_rounded,
                    audio.isSfxEnabled,
                    (val) {
                      setDialogState(() {
                        audio.toggleSfx();
                      });
                    },
                  ),

                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: "CLOSE",
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildSettingRow(
    String label, IconData icon, bool value, Function(bool) onChanged) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon, color: AppTheme.textPrimary),
          const SizedBox(width: 12),
          Text(label,
              style: AppTheme.body.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
      Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.accent,
      ),
    ],
  );
}
