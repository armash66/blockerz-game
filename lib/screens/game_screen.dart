import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/game_state.dart';
import '../core/powerup.dart';
import '../core/board.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/theme_toggle_btn.dart';
import '../core/ai_player.dart';
// Powerup Model
import '../widgets/powerup_deck_overlay.dart'; // Overlay Widget

class GameScreen extends StatefulWidget {
  final bool isPvAI;
  final bool enablePowerups;
  final AIDifficulty difficulty;
  final int boardSize;
  final Duration? timeLimit; // Added

  const GameScreen({
    super.key,
    required this.isPvAI,
    required this.enablePowerups,
    this.difficulty = AIDifficulty.easy,
    this.boardSize = 5,
    this.timeLimit,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameState _gameState;
  late AIPlayer _aiPlayer;

  // Screen Shake
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _gameState = GameState(
      boardSize: widget.boardSize,
      timeLimit: widget.timeLimit,
    );
    _aiPlayer = AIPlayer(difficulty: widget.difficulty);
    _gameState.addListener(_onGameStateChanged);

    // Setup Shake Animation
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reset();
        }
      });

    // Listen to Game Events
    _gameState.eventStream.listen((event) {
      if (event == GameEvent.move ||
          event == GameEvent.block ||
          event == GameEvent.powerup) {
        _shakeController.forward(from: 0);
      }
    });
  }

  // ...

  void _onGameStateChanged() {
    if (!mounted) return;
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
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final offset = _shakeAnimation.value *
                  ((DateTime.now().millisecond % 2 == 0) ? 1 : -1);
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: SafeArea(
              child: Column(
                children: [
                  // Header (Back, Info, Theme)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Column(
                          children: [
                            Text(
                              widget.isPvAI ? "PvAI" : "PvP",
                              style: AppTheme.heading.copyWith(fontSize: 20),
                            ),
                            if (widget.isPvAI)
                              Text(
                                widget.difficulty.name.toUpperCase(),
                                style: AppTheme.body.copyWith(
                                    fontSize: 12, color: AppTheme.accent),
                              ),

                            // Turn Indicator
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _gameState.currentPlayer ==
                                        Player.player1
                                    ? AppTheme.currentBoardTheme.player1Color
                                        .withOpacity(0.2)
                                    : AppTheme.currentBoardTheme.player2Color
                                        .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _gameState.currentPlayer ==
                                          Player.player1
                                      ? AppTheme.currentBoardTheme.player1Color
                                      : AppTheme.currentBoardTheme.player2Color,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _gameState.currentPlayer == Player.player1
                                    ? "PLAYER 1"
                                    : "PLAYER 2",
                                style: AppTheme.body.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _gameState.currentPlayer ==
                                          Player.player1
                                      ? AppTheme.currentBoardTheme.player1Color
                                      : AppTheme.currentBoardTheme.player2Color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.undo),
                              color: AppTheme.textPrimary,
                              onPressed:
                                  _gameState.canUndo ? _gameState.undo : null,
                              tooltip: "Undo",
                            ),
                            IconButton(
                              icon: const Icon(Icons.redo),
                              color: AppTheme.textPrimary,
                              onPressed:
                                  _gameState.canRedo ? _gameState.redo : null,
                              tooltip: "Redo",
                            ),
                          ],
                        ),
                        ThemeToggleBtn(onToggle: () => setState(() {})),
                      ],
                    ),
                  ),

                  // Active Powerup Indicator
                  if (_gameState.activePowerup != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: _gameState.activePowerup!.color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: _gameState.activePowerup!.color
                                    .withOpacity(0.4),
                                blurRadius: 8),
                          ]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_gameState.activePowerup!.icon,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "${_gameState.activePowerup!.name} ACTIVE",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Opponent Info (Player 2 - Top)
                  _buildPlayerInfo(Player.player2, isTop: true),
                  if (widget.enablePowerups) _buildInventoryBar(Player.player2),

                  // Game Board
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _buildGrid(),
                        ),
                      ),
                    ),
                  ),

                  // Player 1 Info (We should probably add this for symmetry?)
                  // For now, just the bar.
                  _buildPlayerInfo(Player.player1, isTop: false),
                  if (widget.enablePowerups) _buildInventoryBar(Player.player1),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ), // Closes AnimatedBuilder

          // Powerup Selection Overlay
          if (widget.enablePowerups && _gameState.isPowerupSelectionPhase)
            PowerupDeckOverlay(
              onSelect: (powerup) {
                _gameState.selectPowerup(powerup);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      children: List.generate(widget.boardSize, (row) {
        return Expanded(
          child: Row(
            children: List.generate(widget.boardSize, (col) {
              return Expanded(child: _buildCell(row, col));
            }),
          ),
        );
      }),
    );
  }

  Widget _buildInventoryBar(Player player) {
    // Only show if powerups enabled (checked by caller mostly, but safe here)
    if (!widget.enablePowerups) return const SizedBox.shrink();

    final inventory = _gameState.getPlayerInventory(player);
    final isCurrentPlayerOne = player == Player.player1;
    // Alignments: Top (P2) -> Start/End?, Bottom (P1) -> Start?
    // Let's just keep standard list.

    return Container(
      height: 60, // Squeezed a bit to fit both
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isCurrentPlayerOne
            ? MainAxisAlignment.end
            : MainAxisAlignment.start, // P1 Right, P2 Left? Or both centered?
        children: [
          // Label
          if (!isCurrentPlayerOne) ...[
            Text("OPPONENT",
                style: AppTheme.body
                    .copyWith(fontSize: 8, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
          ],

          Expanded(
            child: inventory.isEmpty
                ? Align(
                    alignment: isCurrentPlayerOne
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      "Empty",
                      style: AppTheme.body.copyWith(
                          fontSize: 10, color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    reverse: isCurrentPlayerOne, // P1 fills from right
                    itemCount: inventory.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final powerup = inventory[index];
                      final isActive = _gameState.activePowerup == powerup;
                      final isOwnerTurn = _gameState.currentPlayer == player;

                      return Tooltip(
                        message: powerup.description,
                        child: GestureDetector(
                          onTap: () {
                            // Interaction Logic
                            if (!isOwnerTurn) return; // Not their turn
                            if (player == Player.player2 && widget.isPvAI) {
                              return; // Can't touch AI items
                            }

                            // Prevent tapping opponent's items
                            if (player != _gameState.currentPlayer) return;

                            _gameState.activatePowerup(powerup);
                          },
                          child: Opacity(
                            opacity: isOwnerTurn ? 1.0 : 0.5,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      isActive ? powerup.color : Colors.white10,
                                  width: isActive ? 2 : 1,
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: powerup.color.withOpacity(0.4),
                                          blurRadius: 8,
                                        )
                                      ]
                                    : [],
                              ),
                              child: Icon(powerup.icon,
                                  color: powerup.color, size: 20),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (isCurrentPlayerOne) ...[
            const SizedBox(width: 8),
            Text("YOU",
                style: AppTheme.body
                    .copyWith(fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ],
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
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getPlayerColor(player),
                  radius: 8,
                ),
                const SizedBox(width: 12),
                Text(name, style: AppTheme.heading.copyWith(fontSize: 16)),
                if (_gameState.timeLimit != null) ...[
                  const SizedBox(width: 12),
                  _buildTimer(player),
                ],
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
      // Premium Blocker Design
      cellColor = Colors.transparent; // Let container handle color
      content = Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: const Color(0xFF2C3E50), // Dark Slate
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: Colors.redAccent.withOpacity(0.6), width: 2),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))
            ]),
        child: const Center(
          child: Icon(Icons.lock_outline_rounded,
              color: Colors.redAccent, size: 24),
        ),
      );
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

        // PRIORITIZE POWERUP APPLICATION (Except Double Move)
        if (_gameState.activePowerup != null &&
            _gameState.activePowerup!.type != PowerupType.extraMove) {
          _gameState.applyPowerup(cell);
          return;
        }

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

  Widget _buildTimer(Player player) {
    final duration = _gameState.playerTimes[player] ?? Duration.zero;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final isTurn = _gameState.currentPlayer == player;

    // Changing color when low on time (< 10 seconds)
    final isLowTime = duration.inSeconds <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLowTime
              ? Colors.redAccent
              : (isTurn ? AppTheme.accent : Colors.white12),
        ),
      ),
      child: Text(
        "$minutes:$seconds",
        style: TextStyle(
          color: isLowTime ? Colors.redAccent : AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier', // Monospace for numbers
        ),
      ),
    );
  }

  Color _getPlayerColor(Player p) {
    final theme = AppTheme.currentBoardTheme;
    return p == Player.player1 ? theme.player1Color : theme.player2Color;
  }
}
