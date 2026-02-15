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
  late Powerup _drawnPowerup;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false; // false = face down, true = face up
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _drawnPowerup = _generateRandomPowerup();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    // Auto-close after reveal? Or let user tap to close?
    // User requested "animation to get one random powerup".
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Powerup _generateRandomPowerup() {
    final random = Random();
    final all = Powerup.all;
    return all[random.nextInt(all.length)];
  }

  void _handleDeckTap() {
    if (_isAnimating || _isFlipped) return;

    setState(() {
      _isAnimating = true;
    });

    // Animate Flip
    _controller.forward().then((_) {
      // Wait a beat, then select
      Future.delayed(const Duration(milliseconds: 800), () {
        widget.onSelect(_drawnPowerup);
      });
    });

    setState(() {
      _isFlipped = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isFlipped ? "YOU DREW:" : "DRAW A CARD",
              style: AppTheme.heading.copyWith(
                color: Colors.white,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(color: AppTheme.accent, blurRadius: 20),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _handleDeckTap,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // logic for 3D flip effect
                  final angle = _flipAnimation.value * pi;
                  final isUnder = angle > pi / 2;

                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateY(angle);

                  return Transform(
                    transform: transform,
                    alignment: Alignment.center,
                    child: isUnder
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..rotateY(pi), // correct text orientation
                            child: _buildFront(_drawnPowerup),
                          ) // Front (Powerup)
                        : _buildBack(), // Back (Deck)
                  );
                },
              ),
            ),
            if (_isFlipped) ...[
              const SizedBox(height: 32),
              Text(
                "Adding to Inventory...",
                style: AppTheme.body.copyWith(color: Colors.white70),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 4),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5),
        ],
      ),
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white12, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.help_outline, color: Colors.white24, size: 50),
          ),
        ),
      ),
    );
  }

  Widget _buildFront(Powerup powerup) {
    return Container(
      width: 200,
      height: 300,
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
        border: Border.all(color: powerup.color.withOpacity(0.8), width: 3),
        boxShadow: [
          BoxShadow(
            color: powerup.color.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: powerup.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(powerup.icon, color: powerup.color, size: 60),
          ),
          const SizedBox(height: 24),
          Text(
            powerup.name.toUpperCase(),
            style: AppTheme.body.copyWith(
              fontWeight: FontWeight.bold,
              color: powerup.color,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              powerup.description,
              style: AppTheme.body.copyWith(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
