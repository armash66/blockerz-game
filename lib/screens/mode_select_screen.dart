import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/theme_toggle_btn.dart';
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
  AIDifficulty _selectedDifficulty = AIDifficulty.easy;
  int _boardSize = 5; // 5, 7, 9

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEW GAME'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ThemeToggleBtn(onToggle: () => setState(() {})),
          ),
        ],
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

            // Customization Section
            Column(
              children: [
                // Style Selector
                Text(
                  'BOARD STYLE',
                  style: AppTheme.body.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: BoardTheme.all.map((theme) {
                      final isSelected = AppTheme.currentBoardTheme == theme;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => AppTheme.currentBoardTheme = theme),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.gridDark,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected ? AppTheme.accent : Colors.white24,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppTheme.accent.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color:
                                    theme.gridLight == const Color(0xFF1A1A1A)
                                        ? Colors.white
                                        : theme.gridLight,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Size Selector
                Text(
                  'BOARD SIZE',
                  style: AppTheme.body.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [5, 7, 9].map((size) {
                    final isSelected = _boardSize == size;
                    final label = size == 5
                        ? "Small (5x5)"
                        : (size == 7 ? "Medium (7x7)" : "Large (9x9)");

                    return GestureDetector(
                      onTap: () => setState(() => _boardSize = size),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppTheme.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.accent
                                : AppTheme.textSecondary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          "${size}x$size",
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  _boardSize == 5
                      ? "Quick Match • 2 Pieces"
                      : (_boardSize == 7
                          ? "Standard • 3 Pieces"
                          : "Long Match • 4 Pieces"),
                  style: AppTheme.body
                      .copyWith(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
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
                      boardSize: _boardSize,
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
                    : (AppTheme.isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05)),
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
          color: isSelected
              ? AppTheme.accent
              : (AppTheme.isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected
                  ? AppTheme.accent
                  : (AppTheme.isDark ? Colors.white10 : Colors.black12)),
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
