import 'dart:math';
import 'board.dart';
import 'game_state.dart';

enum AIDifficulty { easy, hard }

class AIPlayer {
  final Random _random = Random();
  final AIDifficulty difficulty;

  AIPlayer({this.difficulty = AIDifficulty.easy});

  Future<void> makeMove(GameState state) async {
    // 1. Simulate "Thinking" Delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (state.isGameOver) return;

    // 2. Find all legal moves for Player 2
    List<_Move> validMoves = _findValidMoves(state);

    if (validMoves.isEmpty) return;

    // 3. Pick Move based on Difficulty
    _Move selectedMove;

    if (difficulty == AIDifficulty.easy) {
      // EASY: Pure Random
      selectedMove = validMoves[_random.nextInt(validMoves.length)];
    } else {
      // HARD: Ranked moves
      // (For now, simple heuristic: prioritize moves that block opponent or win)
      selectedMove = _pickBestMove(state, validMoves);
    }

    // 4. Execut Move
    state.selectCell(selectedMove.from.row, selectedMove.from.col);
    await Future.delayed(const Duration(milliseconds: 300));
    state.selectCell(selectedMove.to.row, selectedMove.to.col);
  }

  List<_Move> _findValidMoves(GameState state) {
    List<_Move> moves = [];
    final size = state.boardSize;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final cell = state.grid[r][c];
        if (cell.owner == Player.player2) {
          final neighbors = [
            [-1, 0],
            [1, 0],
            [0, -1],
            [0, 1]
          ];
          for (final offset in neighbors) {
            final nr = r + offset[0];
            final nc = c + offset[1];
            if (nr >= 0 && nr < size && nc >= 0 && nc < size) {
              final target = state.grid[nr][nc];
              if (target.isEmpty) {
                moves.add(_Move(from: cell, to: target));
              }
            }
          }
        }
      }
    }
    return moves;
  }

  _Move _pickBestMove(GameState state, List<_Move> moves) {
    // Basic Heuristic:
    // Score moves.
    // +100 if leads to a win (opponent has no moves).
    // +10 if it blocks an adjacent opponent piece.
    // +1 Random factor.

    _Move bestMove = moves.first;
    int bestScore = -9999;
    final center = state.boardSize ~/ 2;

    for (final move in moves) {
      int score = _random.nextInt(5); // Random base to vary play slightly

      // 1. Center Control
      if (move.to.row == center && move.to.col == center) score += 5;

      // 2. Proximity to Opponent (Aggression)
      if (_hasNeighbor(state, move.to, Player.player1)) {
        score += 3; // Block/Engage logic
      }

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  bool _hasNeighbor(GameState state, Cell cell, Player targetOwner) {
    final size = state.boardSize;
    final neighbors = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1]
    ];
    for (final offset in neighbors) {
      final nr = cell.row + offset[0];
      final nc = cell.col + offset[1];
      if (nr >= 0 && nr < size && nc >= 0 && nc < size) {
        if (state.grid[nr][nc].owner == targetOwner) return true;
      }
    }
    return false;
  }
}

class _Move {
  final Cell from;
  final Cell to;
  _Move({required this.from, required this.to});
}
