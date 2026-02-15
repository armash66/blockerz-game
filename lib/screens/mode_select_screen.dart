import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import 'game_screen.dart';
import '../core/ai_player.dart'; // Import Difficulty Enum

class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen> {
  int _selectedMode = 0; // 0: PvP, 1: PvAI
  bool _powerupsEnabled = false;
  AIDifficulty _selectedDifficulty = AIDifficulty.easy; // Difficulty State

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEW GAME'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CHOOSE OPPONENT',
              style: AppTheme.body.copyWith(letterSpacing: 2.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // PvP Card
            _buildModeCard(
              index: 0,
              title: 'Pass & Play',
              subtitle: 'Play against a friend on this device.',
              icon: Icons.people_alt_rounded,
            ),
            const SizedBox(height: 20),

            // PvAI Card
            _buildModeCard(
              index: 1,
              title: 'Vs Computer',
              subtitle: 'Challenge the AI engine.',
              icon: Icons.computer_rounded,
            ),

            // Difficulty Selector (Only visible if PvAI is selected)
            if (_selectedMode == 1) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildDifficultyBtn("EASY", AIDifficulty.easy)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildDifficultyBtn("HARD", AIDifficulty.hard)),
                ],
              ),
            ],

            const SizedBox(height: 40),

            // Powerups Toggle
            GlassCard(
              onTap: () => setState(() => _powerupsEnabled = !_powerupsEnabled),
              child: Row(
                children: [
                  Icon(
                    Icons.flash_on_rounded,
                    color: _powerupsEnabled
                        ? Colors.yellow
                        : AppTheme.textSecondary,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable Powerups',
                          style: AppTheme.heading.copyWith(fontSize: 18),
                        ),
                        Text(
                          'Add chaos with special abilities.',
                          style: AppTheme.body.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _powerupsEnabled,
                    activeColor: AppTheme.accent,
                    onChanged: (val) => setState(() => _powerupsEnabled = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Theme Selection
            Text(
              'BOARD STYLE',
              style: AppTheme.body.copyWith(letterSpacing: 2.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: BoardTheme.all.length,
                separatorBuilder: (c, i) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final theme = BoardTheme.all[index];
                  final isSelected = AppTheme.currentBoardTheme == theme;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        AppTheme.currentBoardTheme = theme;
                      });
                    },
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: theme.gridDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppTheme.accent : Colors.white24,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            // FIX: Check if theme is Neon (Dark Grid), if so make dot WHITE
                            color: theme.gridLight == const Color(0xFF1A1A1A)
                                ? Colors.white
                                : theme.gridLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            PrimaryButton(
              label: 'START MATCH',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      isPvAI: _selectedMode == 1,
                      enablePowerups: _powerupsEnabled,
                      difficulty: _selectedDifficulty,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMode == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.accent.withOpacity(0.1) : AppTheme.surface,
          border: Border.all(
            color: isSelected ? AppTheme.accent : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accent
                    : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.heading.copyWith(
                      fontSize: 18,
                      color:
                          isSelected ? AppTheme.accent : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.body.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppTheme.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBtn(String label, AIDifficulty diff) {
    final isSelected = _selectedDifficulty == diff;
    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = diff),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: isSelected ? AppTheme.accent : Colors.white10),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.body.copyWith(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12),
          ),
        ),
      ),
    );
  }
}
