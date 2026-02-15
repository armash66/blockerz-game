import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/game_state.dart';
import '../core/board.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';

class GameScreen extends StatefulWidget {
  final bool isPvAI;
  final bool enablePowerups;

  const GameScreen({
    super.key,
    required this.isPvAI,
    required this.enablePowerups,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    _gameState.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _gameState.removeListener(_onGameStateChanged);
    _gameState.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    setState(() {});

    if (_gameState.isGameOver) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final winner = _gameState.winner!;
        final winnerName = winner == Player.player1 ? "PLAYER 1" : "PLAYER 2";

        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text('GAME OVER', style: AppTheme.heading),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_rounded,
                  size: 60, color: AppTheme.accent),
              const SizedBox(height: 20),
              Text('$winnerName WINS!',
                  style: AppTheme.display.copyWith(fontSize: 24)),
              const SizedBox(height: 10),
              Text(
                'The opponent has no legal moves.',
                style: AppTheme.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            PrimaryButton(
              label: 'Back to Menu',
              onPressed: () {
                Navigator.of(context).pop(); // Close Dialog
                Navigator.of(context).pop(); // Back to Mode Select
                Navigator.of(context).pop(); // Back to Home
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLOCKERZ'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Opponent Info
                  _buildPlayerInfo(Player.player2, isTop: true),

                  const SizedBox(height: 20),

                  // 5x5 Grid (Board)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF302E2B), // Border color
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFF302E2B), width: 4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Column(
                          children: List.generate(5, (row) {
                            return Expanded(
                              child: Row(
                                children: List.generate(5, (col) {
                                  return Expanded(child: _buildCell(row, col));
                                }),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Player Info (You)
                  _buildPlayerInfo(Player.player1, isTop: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(Player player, {required bool isTop}) {
    final isTurn = _gameState.currentPlayer == player;
    final name = player == Player.player1 ? "PLAYER 1 (You)" : "PLAYER 2";

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isTurn ? 1.0 : 0.5,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getPlayerColor(player),
                  radius: 8,
                ),
                const SizedBox(width: 12),
                Text(name, style: AppTheme.heading.copyWith(fontSize: 16)),
              ],
            ),
            if (isTurn)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'YOUR TURN',
                  style: AppTheme.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final cell = _gameState.grid[row][col];
    final isSelected = _gameState.selectedCell == cell;

    // 1. Checkerboard Background
    final isDark = (row + col) % 2 == 1;
    final baseColor = isDark
        ? const Color(0xFF769656) // Chess.com Green Dark
        : const Color(0xFFEEEED2); // Chess.com Cream Light

    // Override for Blocked or Highlight
    Color cellColor = baseColor;
    Widget? content;

    // 2. Highlights & Content
    if (cell.isBlocked) {
      cellColor = const Color(0xFF262522); // Dark Charcoal for blocked
      content =
          const Icon(Icons.close_rounded, color: Colors.white12, size: 32);
    } else if (cell.isOccupied) {
      // 3. Premium Piece Styling
      content = Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _getPlayerColor(cell.owner!),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              offset: const Offset(0, -2),
              blurRadius: 4,
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.black12, width: 1),
        ),
        child: Center(
          child: Icon(
            Icons.circle, // Inner detail
            size: 12,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      );
    } else if (isSelected) {
      // Highlight Selected Empty (Target?) - Logic handles 'active' selection elsewhere
      cellColor = AppTheme.accent.withOpacity(0.5);
    } else if (_gameState.selectedCell != null) {
      // Optional: Show valid move hints (dots)
      // For now, simpler highlight if needed
    }

    return GestureDetector(
      onTap: () => _gameState.selectCell(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          // No border for seamless board look
        ),
        child: content,
      ),
    );
  }

  Color _getPlayerColor(Player p) {
    return p == Player.player1
        ? const Color(0xFF4C81B6)
        : const Color(0xFFB64C81); // Blue vs Pink/Red
  }
}
