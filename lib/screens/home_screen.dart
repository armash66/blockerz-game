import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/audio_manager.dart';
import '../widgets/primary_button.dart';
import '../widgets/theme_toggle_btn.dart';
import 'mode_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // We need to force rebuild when theme changes if we use setState on theme,
  // but AppTheme.currentBoardTheme is static.
  // For simplicity, we'll just setState here to rebuild local UI if it used theme (it doesn't much).
  // But we want to show the current theme name maybe?

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
                        _showRules();
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
        ],
      ),
    );
  }

  void _showRules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('HOW TO PLAY', style: AppTheme.heading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRuleItem("1.", "Move your piece to any adjacent empty spot."),
            _buildRuleItem(
                "2.", "Jump over an adjacent piece to an empty spot."),
            _buildRuleItem("3.", "Trap your opponent so they can't move."),
            const SizedBox(height: 12),
            Text("Last player moving wins!",
                style: AppTheme.body.copyWith(color: AppTheme.accent)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("GOT IT", style: TextStyle(color: AppTheme.accent)),
          )
        ],
      ),
    );
  }

  Widget _buildRuleItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number,
              style: AppTheme.body.copyWith(
                  fontWeight: FontWeight.bold, color: AppTheme.accent)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTheme.body)),
        ],
      ),
    );
  }
}
