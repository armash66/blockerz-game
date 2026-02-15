import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';

class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen> {
  int _selectedMode = 0; // 0: PvP, 1: PvAI
  bool _powerupsEnabled = false;

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

            const Spacer(),

            PrimaryButton(
              label: 'START MATCH',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Starting Mode: ${_selectedMode == 0 ? "PvP" : "PvAI"}'),
                    backgroundColor: AppTheme.accent,
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
}
