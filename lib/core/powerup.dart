import 'package:flutter/material.dart';

enum PowerupType {
  doubleMove, // Move twice in one turn
  wallBuilder, // Block any empty tile (Remote Block)
  pathClearer, // Unblock any blocked tile (Remote Unblock)
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
      type: PowerupType.doubleMove,
      name: "Double Move",
      description: "Move twice in a single turn.",
      icon: Icons.fast_forward_rounded,
      color: Colors.purpleAccent,
    ),
    Powerup(
      type: PowerupType.wallBuilder,
      name: "Wall Builder",
      description: "Block ANY empty tile on the board.",
      icon: Icons.grid_off_rounded,
      color: Colors.brown,
    ),
    Powerup(
      type: PowerupType.pathClearer,
      name: "Path Clearer",
      description: "Remove a block from ANY tile.",
      icon: Icons.cleaning_services_rounded,
      color: Colors.tealAccent,
    ),
  ];

  static Powerup get(PowerupType type) {
    return all.firstWhere((p) => p.type == type);
  }
}
