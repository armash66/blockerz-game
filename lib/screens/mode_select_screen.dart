import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/glass_card.dart';
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
  Duration? _selectedTimeLimit; // Null = No Limit

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mode Selection (PvP / PvAI)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildModeBtn(0, 'PvP', Icons.people_rounded),
                        ),
                        Expanded(
                          child:
                              _buildModeBtn(1, 'PvAI', Icons.smart_toy_rounded),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // AI Difficulty (Only if PvAI)
                  AnimatedCrossFade(
                    firstChild: Container(height: 0),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'DIFFICULTY',
                          style: AppTheme.body.copyWith(
                              letterSpacing: 2.0,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() =>
                                      _selectedDifficulty = AIDifficulty.easy),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedDifficulty ==
                                              AIDifficulty.easy
                                          ? AppTheme.accent
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'EASY',
                                        style: AppTheme.body.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _selectedDifficulty ==
                                                  AIDifficulty.easy
                                              ? Colors.white
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() =>
                                      _selectedDifficulty = AIDifficulty.hard),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedDifficulty ==
                                              AIDifficulty.hard
                                          ? Colors.orangeAccent
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'HARD',
                                        style: AppTheme.body.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _selectedDifficulty ==
                                                  AIDifficulty.hard
                                              ? Colors.white
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                    crossFadeState: _selectedMode == 1
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),

                  // Powerups Toggle
                  GlassCard(
                    onTap: () =>
                        setState(() => _powerupsEnabled = !_powerupsEnabled),
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
                          onChanged: (val) =>
                              setState(() => _powerupsEnabled = val),
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
                            final isSelected =
                                AppTheme.currentBoardTheme == theme;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => AppTheme.currentBoardTheme = theme),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.gridDark,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.accent
                                        : Colors.white24,
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
                                      color: theme.gridLight ==
                                              const Color(0xFF1A1A1A)
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

                          return GestureDetector(
                            onTap: () => setState(() => _boardSize = size),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.accent
                                    : Colors.transparent,
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
                        style: AppTheme.body.copyWith(
                            fontSize: 11, color: AppTheme.textSecondary),
                      ),

                      const SizedBox(height: 24),

                      // Time Control Selector
                      Text(
                        'TIME CONTROL',
                        style: AppTheme.body.copyWith(
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 12,
                        children: [
                          null, // No Limit
                          const Duration(minutes: 1),
                          const Duration(minutes: 5),
                          const Duration(minutes: 10),
                        ].map((duration) {
                          final isSelected = _selectedTimeLimit == duration;
                          String label;
                          if (duration == null) {
                            label = "∞";
                          } else {
                            label = "${duration.inMinutes}m";
                          }

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTimeLimit = duration),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.accent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.accent
                                      : AppTheme.textSecondary.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                label,
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
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Start Button (Pinned to Bottom)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: AppTheme.accent.withOpacity(0.4),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        isPvAI: _selectedMode == 1,
                        enablePowerups: _powerupsEnabled,
                        difficulty: _selectedDifficulty,
                        boardSize: _boardSize,
                        timeLimit: _selectedTimeLimit,
                      ),
                    ),
                  );
                },
                child: Text(
                  'START MATCH',
                  style: AppTheme.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(int index, String label, IconData icon) {
    final isSelected = _selectedMode == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.body.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
