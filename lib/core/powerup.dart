import 'package:flutter/material.dart';

enum PowerupType {
  flash, // Teleport to any empty tile within range 2
  swap, // Swap with any adjacent unit
  push, // Push adjacent enemy 1 tile
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
      type: PowerupType.flash,
      name: "Flash",
      description: "Teleport to any empty tile within range 2.",
      icon: Icons.flash_on_rounded,
      color: Colors.amber,
    ),
    Powerup(
      type: PowerupType.swap,
      name: "Swap",
      description: "Swap places with any adjacent unit.",
      icon: Icons.swap_horiz_rounded,
      color: Colors.blueAccent,
    ),
    Powerup(
      type: PowerupType.push,
      name: "Push",
      description: "Push an adjacent enemy 1 tile away.",
      icon: Icons.published_with_changes_rounded,
      color: Colors.deepOrangeAccent,
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
