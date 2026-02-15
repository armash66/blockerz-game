import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/game_state.dart';
import '../core/board.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/theme_toggle_btn.dart';
import '../core/ai_player.dart'; // Import added at top

class GameScreen extends StatefulWidget {
  final bool isPvAI;
  final bool enablePowerups;
  final AIDifficulty difficulty;
  final int boardSize; // Added

  const GameScreen({
    super.key,
    required this.isPvAI,
    required this.enablePowerups,
    this.difficulty = AIDifficulty.easy,
    this.boardSize = 5, // Default
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  late AIPlayer _aiPlayer;

  @override
  void initState() {
    super.initState();
    _gameState = GameState(boardSize: widget.boardSize); // Pass size
    _aiPlayer = AIPlayer(difficulty: widget.difficulty);
    _gameState.addListener(_onGameStateChanged);
  }

  // ...

  void _onGameStateChanged() {
    setState(() {});

    if (_gameState.isGameOver) {
      _showGameOverDialog();
    } else {
      // Check for AI Turn
      if (widget.isPvAI && _gameState.currentPlayer == Player.player2) {
        _aiPlayer.makeMove(_gameState);
      }
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final winner = _gameState.winner!;
        final winnerName = winner == Player.player1
            ? "PLAYER 1"
            : (widget.isPvAI ? "AI" : "PLAYER 2");

        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text('GAME OVER', style: AppTheme.heading),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ThemeToggleBtn(onToggle: () => setState(() {})),
          ),
        ],
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
                  // Opponent Info (Player 2 - Top)
                  _buildPlayerInfo(Player.player2, isTop: true),

                  const Spacer(),

                  // 5x5 Grid (Board)
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.currentBoardTheme.borderColor,
                      borderRadius: BorderRadius.circular(16), // Rounded Board
                      boxShadow: [
                        // Depth
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                          color: AppTheme.currentBoardTheme.borderColor,
                          width: 8), // Thicker Border
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Column(
                          children: List.generate(_gameState.boardSize, (row) {
                            return Expanded(
                              child: Row(
                                children:
                                    List.generate(_gameState.boardSize, (col) {
                                  return Expanded(child: _buildCell(row, col));
                                }),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Player Info (Player 1 - Bottom - You)
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
    final name = player == Player.player1
        ? "PLAYER 1 (You)"
        : (widget.isPvAI
            ? "AI (${widget.difficulty == AIDifficulty.easy ? 'Easy' : 'Hard'})"
            : "PLAYER 2");

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
    final theme = AppTheme.currentBoardTheme;
    final isDark = (row + col) % 2 == 1;
    final baseColor = isDark ? theme.gridDark : theme.gridLight;

    // Override for Blocked or Highlight
    Color cellColor = baseColor;
    Widget? content;

    // 2. Highlights & Content
    if (cell.isBlocked) {
      // User Request: "blockers red mark not grey"
      cellColor = theme.blockedColor;
      // We keep background dark but make ICON red
      content =
          const Icon(Icons.close_rounded, color: Colors.redAccent, size: 32);
    } else if (cell.isOccupied) {
      // User Request: "multiple token shapes"
      final isPlayer1 = cell.owner == Player.player1;

      content = Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _getPlayerColor(cell.owner!),
          shape: isPlayer1
              ? BoxShape.circle
              : BoxShape.rectangle, // P1 Circle, P2 Square
          borderRadius: isPlayer1
              ? null
              : BorderRadius.circular(8), // Rounded rect for P2
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
            isPlayer1
                ? Icons.circle
                : Icons.stop_rounded, // Inner detail matches shape
            size: 12,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      );
    } else if (isSelected) {
      cellColor = AppTheme.accent.withOpacity(0.5);
    }

    return GestureDetector(
      onTap: () {
        // Prevent tapping if it's AI turn (and we are in PvAI mode)
        if (widget.isPvAI && _gameState.currentPlayer == Player.player2) return;

        _gameState.selectCell(row, col);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
        ),
        child: content,
      ),
    );
  }

  Color _getPlayerColor(Player p) {
    final theme = AppTheme.currentBoardTheme;
    return p == Player.player1 ? theme.player1Color : theme.player2Color;
  }
}
