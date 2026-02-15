import 'package:flutter/material.dart';

enum PowerupType {
  highJump, // Jump to any empty tile within range 3 (ignore obstacles)
  bomb, // Destroy a targeted blocked cell
  shield, // Immune to being blocked next turn
  doubleMove, // Move twice in one turn
}

class Powerup {
  final PowerupType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const Powerup({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  static const List<Powerup> all = [
    Powerup(
      type: PowerupType.highJump,
      name: "High Jump",
      description: "Leap to any empty tile within Range 3. Ignores obstacles!",
      icon: Icons.flight_takeoff_rounded,
      color: Colors.amber,
    ),
    Powerup(
      type: PowerupType.bomb,
      name: "Bomb",
      description: "Destroy a Blocked Cell to clear a path.",
      icon: Icons.dangerous_rounded,
      color: Colors.redAccent,
    ),
    Powerup(
      type: PowerupType.shield,
      name: "Shield",
      description: "Your previous tile cannot be blocked next turn.",
      icon: Icons.security_rounded,
      color: Colors.cyanAccent,
    ),
    Powerup(
      type: PowerupType.doubleMove,
      name: "Double Move",
      description: "Move twice in a single turn.",
      icon: Icons.fast_forward_rounded,
      color: Colors.purpleAccent,
    ),
  ];

  static Powerup get(PowerupType type) {
    return all.firstWhere((p) => p.type == type);
  }
}
