import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/audio_manager.dart';
import '../widgets/primary_button.dart';
import '../widgets/theme_toggle_btn.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/tutorial_overlay.dart';
import 'mode_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showTutorial = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.background,
                  AppTheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo / Title Section
                    const Icon(
                      Icons.grid_4x4_rounded,
                      size: 80,
                      color: AppTheme.accent,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'BLOCKERZ',
                      style: AppTheme.display,
                    ),
                    Text(
                      'STRATEGY BOARD GAME',
                      style: AppTheme.body.copyWith(
                        letterSpacing: 3.0,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Main Action
                    PrimaryButton(
                      label: 'New Game',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ModeSelectScreen(),
                          ),
                        ).then((_) => setState(
                            () {})); // Rebuild on return in case theme changed
                      },
                    ),

                    const SizedBox(height: 20),

                    // Secondary Action (Rules)
                    TextButton(
                      onPressed: () {
                        AudioManager().playClick();
                        setState(() => _showTutorial = true);
                      },
                      child: Text(
                        'HOW TO PLAY',
                        style: AppTheme.body.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Theme Toggle (Top Right)
          Positioned(
            top: 24,
            right: 24,
            child: SafeArea(
              // Ensure it respects notch/status bar
              child: ThemeToggleBtn(onToggle: () => setState(() {})),
            ),
          ),

          // Settings Button (Top Left)
          Positioned(
            top: 24,
            left: 24,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.settings, color: AppTheme.textPrimary),
                onPressed: () {
                  AudioManager().playClick();
                  showSettingsDialog(context);
                },
              ),
            ),
          ),

          if (_showTutorial)
            TutorialOverlay(
                onFinish: () => setState(() => _showTutorial = false)),
        ],
      ),
    );
  }
}
