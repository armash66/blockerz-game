import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/primary_button.dart';
import 'mode_select_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF302E2B), // Gunmetal
              Color(0xFF262522), // Darker Surface
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Title Section
                Icon(
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
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Secondary Action (Placeholder for stats/settings)
                TextButton(
                  onPressed: () {},
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
    );
  }
}
