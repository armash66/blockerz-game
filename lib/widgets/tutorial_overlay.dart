import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onFinish;

  const TutorialOverlay({super.key, required this.onFinish});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: "WELCOME TO BLOCKERZ",
      description: "A game of strategy where your own path becomes your enemy.",
      icon: Icons.grid_4x4_rounded,
    ),
    TutorialStep(
      title: "MOVE YOUR PIECE",
      description:
          "Tap any of your pieces, then tap an adjacent empty square to move.",
      icon: Icons.touch_app_rounded,
    ),
    TutorialStep(
      title: "BLOCK THE PATH",
      description:
          "Every time you move, the square you left behind becomes BLOCKED permanently.",
      icon: Icons.lock_rounded,
    ),
    TutorialStep(
      title: "TRAP THEM",
      description:
          "If your opponent has no legal moves left, YOU WIN! Plan ahead to box them in.",
      icon: Icons.emoji_events_rounded,
    ),
  ];

  void _next() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey(_currentStep),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppTheme.accent.withOpacity(0.3)),
                      ),
                      child: Icon(step.icon, size: 64, color: AppTheme.accent),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      step.title,
                      style: AppTheme.display.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      step.description,
                      style: AppTheme.body.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentStep == index
                          ? AppTheme.accent
                          : Colors.white24,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentStep == _steps.length - 1 ? "GOT IT!" : "NEXT",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              if (_currentStep < _steps.length - 1)
                TextButton(
                  onPressed: widget.onFinish,
                  child: Text(
                    "SKIP",
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
