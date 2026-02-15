import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/powerup.dart';

import 'dart:math';

class PowerupDeckOverlay extends StatefulWidget {
  final Function(Powerup) onSelect;

  const PowerupDeckOverlay({super.key, required this.onSelect});

  @override
  State<PowerupDeckOverlay> createState() => _PowerupDeckOverlayState();
}

class _PowerupDeckOverlayState extends State<PowerupDeckOverlay>
    with SingleTickerProviderStateMixin {
  late List<Powerup> _offeredPowerups;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _offeredPowerups = _generateRandomPowerups();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Powerup> _generateRandomPowerups() {
    final random = Random();
    // Pick 3 random powerups (can be duplicates? Let's say yes for now, or distinct?)
    // Let's try to make them distinct if possible.
    final all = List<Powerup>.from(Powerup.all);
    all.shuffle(random);
    return all.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54, // Dim background
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "CHOOSE YOUR POWERUP!",
                style: AppTheme.heading.copyWith(
                  color: Colors.white,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(color: AppTheme.accent, blurRadius: 20),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: _offeredPowerups.map((powerup) {
                  return _buildPowerupCard(powerup);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerupCard(Powerup powerup) {
    return GestureDetector(
      onTap: () => widget.onSelect(powerup),
      child: Container(
        width: 140,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.surface,
              AppTheme.surface.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: powerup.color.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: powerup.color.withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: powerup.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(powerup.icon, color: powerup.color, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              powerup.name.toUpperCase(),
              style: AppTheme.body.copyWith(
                fontWeight: FontWeight.bold,
                color: powerup.color,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                powerup.description,
                style: AppTheme.body.copyWith(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
