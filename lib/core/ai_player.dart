import 'dart:math';
import 'board.dart';
import 'game_state.dart';

class AIPlayer {
  final Random _random = Random();

  Future<void> makeMove(GameState state) async {
    // 1. Simulate "Thinking" Delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (state.isGameOver) return;

    // 2. Find all legal moves for Player 2
    List<_Move> validMoves = [];

    // Iterate through grid to find Player 2's pieces
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        final cell = state.grid[r][c];
        if (cell.owner == Player.player2) {
          // Check neighbors
          final neighbors = [
            [-1, 0],
            [1, 0],
            [0, -1],
            [0, 1]
          ];

          for (final offset in neighbors) {
            final nr = r + offset[0];
            final nc = c + offset[1];

            if (nr >= 0 && nr < 5 && nc >= 0 && nc < 5) {
              final target = state.grid[nr][nc];
              if (target.isEmpty) {
                validMoves.add(_Move(from: cell, to: target));
              }
            }
          }
        }
      }
    }

    // 3. Pick a Random Move
    if (validMoves.isNotEmpty) {
      final move = validMoves[_random.nextInt(validMoves.length)];

      // Execute Move directly
      // Note: We need a way to execute move on GameState without selection UI logic if possible,
      // or we just simulate the selection.

      // select piece
      state.selectCell(move.from.row, move.from.col);

      // fast delay
      await Future.delayed(const Duration(milliseconds: 300));

      // start move
      state.selectCell(move.to.row, move.to.col);
    }
  }
}

class _Move {
  final Cell from;
  final Cell to;
  _Move({required this.from, required this.to});
}
