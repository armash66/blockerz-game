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

    // 2. Find Best Move based on Difficulty
    _Move? selectedMove;

    if (difficulty == AIDifficulty.easy) {
      // EASY: Pure Random
      List<_Move> validMoves = _findValidMoves(state);
      if (validMoves.isNotEmpty) {
        selectedMove = validMoves[_random.nextInt(validMoves.length)];
      }
    } else {
      // HARD: Minimax with Alpha-Beta Pruning
      selectedMove = _findBestMoveMinimax(state);
    }

    if (selectedMove == null) return;

    // 3. Execute Move
    state.selectCell(selectedMove.fromRow, selectedMove.fromCol);
    await Future.delayed(const Duration(milliseconds: 300));
    state.selectCell(selectedMove.toRow, selectedMove.toCol);
  }

  // --- Minimax Logic ---

  _Move? _findBestMoveMinimax(GameState state) {
    // Determine depth based on board size
    // 5x5: depth 6 is usually fast enough
    // 9x9: depth 3-4
    int depth = state.boardSize == 5 ? 6 : (state.boardSize == 7 ? 4 : 3);

    _Move? bestMove;
    double bestValue = -double.infinity;
    double alpha = -double.infinity;
    double beta = double.infinity;

    List<_Move> moves = _findValidMoves(state);
    if (moves.isEmpty) return null;

    // Shuffle moves to avoid predictable play for equal scores
    moves.shuffle();

    for (final move in moves) {
      // Simulate move on a lightweight representation
      final nextState = _SimState.fromGameState(state);
      nextState.applyMove(move);

      double value = _minimax(nextState, depth - 1, alpha, beta, false);

      if (value > bestValue) {
        bestValue = value;
        bestMove = move;
      }
      alpha = max(alpha, bestValue);
    }

    return bestMove;
  }

  double _minimax(_SimState state, int depth, double alpha, double beta,
      bool isMaximizing) {
    if (depth == 0 || state.isGameOver()) {
      return _evaluate(state);
    }

    if (isMaximizing) {
      double maxEval = -double.infinity;
      for (final move in state.getMoves(Player.player2)) {
        state.applyMove(move);
        double eval = _minimax(state, depth - 1, alpha, beta, false);
        state.undoMove(move);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in state.getMoves(Player.player1)) {
        state.applyMove(move);
        double eval = _minimax(state, depth - 1, alpha, beta, true);
        state.undoMove(move);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  // Evaluation: Mobility is king in Blockerz
  double _evaluate(_SimState state) {
    if (state.isGameOver()) {
      // If AI (Player 2) is the winner, return high positive
      return state.winner == Player.player2 ? 10000.0 : -10000.0;
    }

    // Heuristics:
    // 1. Mobility: More moves is better
    int aiMoves = state.getMovesCount(Player.player2);
    int p1Moves = state.getMovesCount(Player.player1);

    // Mobility Differential
    double score = (aiMoves - p1Moves) * 10.0;

    // 2. Centrality: Slight preference for central tiles
    final center = state.size / 2.0 - 0.5;
    for (final pos in state.player2Positions) {
      double dist = (pos.row - center).abs() + (pos.col - center).abs();
      score += (state.size - dist) * 0.5;
    }

    return score;
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
              if (state.grid[nr][nc].isEmpty) {
                moves.add(_Move(
                  fromRow: r,
                  fromCol: c,
                  toRow: nr,
                  toCol: nc,
                ));
              }
            }
          }
        }
      }
    }
    return moves;
  }
}

// Lightweight simulation state
class _SimState {
  final int size;
  final List<List<CellType>> grid;
  final List<_Pos> player1Positions;
  final List<_Pos> player2Positions;
  Player currentPlayer;

  _SimState({
    required this.size,
    required this.grid,
    required this.player1Positions,
    required this.player2Positions,
    required this.currentPlayer,
  });

  factory _SimState.fromGameState(GameState state) {
    final size = state.boardSize;
    final grid = List.generate(
        size, (r) => List.generate(size, (c) => state.grid[r][c].type));
    final p1Pos = <_Pos>[];
    final p2Pos = <_Pos>[];

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (state.grid[r][c].isOccupied) {
          if (state.grid[r][c].owner == Player.player1) {
            p1Pos.add(_Pos(r, c));
          } else {
            p2Pos.add(_Pos(r, c));
          }
        }
      }
    }
    return _SimState(
      size: size,
      grid: grid,
      player1Positions: p1Pos,
      player2Positions: p2Pos,
      currentPlayer: state.currentPlayer,
    );
  }

  void applyMove(_Move move) {
    // 1. Move
    grid[move.fromRow][move.fromCol] = CellType.blocked;
    grid[move.toRow][move.toCol] = CellType.occupied;

    // 2. Update Position List
    final posList =
        currentPlayer == Player.player1 ? player1Positions : player2Positions;
    for (int i = 0; i < posList.length; i++) {
      if (posList[i].row == move.fromRow && posList[i].col == move.fromCol) {
        posList[i] = _Pos(move.toRow, move.toCol);
        break;
      }
    }

    currentPlayer = currentPlayer.opponent;
  }

  void undoMove(_Move move) {
    currentPlayer = currentPlayer.opponent;

    // Restore grid
    grid[move.fromRow][move.fromCol] = CellType.occupied;
    grid[move.toRow][move.toCol] = CellType.empty;

    // Update Position List
    final posList =
        currentPlayer == Player.player1 ? player1Positions : player2Positions;
    for (int i = 0; i < posList.length; i++) {
      if (posList[i].row == move.toRow && posList[i].col == move.toCol) {
        posList[i] = _Pos(move.fromRow, move.fromCol);
        break;
      }
    }
  }

  List<_Move> getMoves(Player p) {
    final moves = <_Move>[];
    final posList = p == Player.player1 ? player1Positions : player2Positions;
    final neighbors = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1]
    ];

    for (final pos in posList) {
      for (final offset in neighbors) {
        final nr = pos.row + offset[0];
        final nc = pos.col + offset[1];
        if (nr >= 0 && nr < size && nc >= 0 && nc < size) {
          if (grid[nr][nc] == CellType.empty) {
            moves.add(_Move(
              fromRow: pos.row,
              fromCol: pos.col,
              toRow: nr,
              toCol: nc,
            ));
          }
        }
      }
    }
    return moves;
  }

  int getMovesCount(Player p) {
    int count = 0;
    final posList = p == Player.player1 ? player1Positions : player2Positions;
    final neighbors = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1]
    ];

    for (final pos in posList) {
      for (final offset in neighbors) {
        final nr = pos.row + offset[0];
        final nc = pos.col + offset[1];
        if (nr >= 0 && nr < size && nc >= 0 && nc < size) {
          if (grid[nr][nc] == CellType.empty) {
            count++;
          }
        }
      }
    }
    return count;
  }

  bool isGameOver() => getMovesCount(currentPlayer) == 0;
  Player? get winner => isGameOver() ? currentPlayer.opponent : null;
}

class _Pos {
  final int row;
  final int col;
  _Pos(this.row, this.col);
}

class _Move {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  _Move(
      {required this.fromRow,
      required this.fromCol,
      required this.toRow,
      required this.toCol});
}
