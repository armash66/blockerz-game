import 'package:flutter/material.dart';

enum PowerupType {
  extraMove, // Move an additional time this turn
  wallBuilder, // Block any empty tile (Remote Block)
  pathClearer, // Unblock any blocked tile (Remote Unblock)
  stealthMove, // Move WITHOUT blocking previous tile
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
      type: PowerupType.extraMove,
      name: "Extra Move",
      description: "Move freely! Does not end turn.",
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
    Powerup(
      type: PowerupType.stealthMove,
      name: "Stealth Move",
      description: "Move without leaving a block behind.",
      icon: Icons.visibility_off_rounded,
      color: Colors.blueGrey,
    ),
  ];

  static Powerup get(PowerupType type) {
    return all.firstWhere((p) => p.type == type);
  }
}
