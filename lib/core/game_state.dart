import 'package:flutter/foundation.dart';
import 'board.dart';

class GameState extends ChangeNotifier {
  // Grid
  final int boardSize;
  final List<List<Cell>> grid;

  // Turn Management
  Player _currentPlayer = Player.player1;
  Player? _winner;

  // Game Status
  bool get isGameOver => _winner != null;
  Player get currentPlayer => _currentPlayer;
  Player? get winner => _winner;

  // Selected Piece for Movement
  Cell? _selectedAndActiveCell;
  Cell? get selectedCell => _selectedAndActiveCell;

  GameState({this.boardSize = 5}) : grid = _createGrid(boardSize) {
    _initializePieces();
  }

  // 1. Initialize Grid
  static List<List<Cell>> _createGrid(int size) {
    return List.generate(size, (row) {
      return List.generate(size, (col) {
        return Cell(row: row, col: col);
      });
    });
  }

  // 2. Setup Starting Positions
  void _initializePieces() {
    int piecesPerPlayer = 2; // Default 5x5
    if (boardSize == 7) piecesPerPlayer = 3;
    if (boardSize == 9) piecesPerPlayer = 4;

    // Corner Logic for N pieces?
    // 5x5 (2): Corners (0,0 & 0,4) vs (4,0 & 4,4)
    // 7x7 (3): Corners + Middle Edge? or Back Row?
    // Let's use Back Row logic centered.

    // Player 2 (Top)
    for (int i = 0; i < piecesPerPlayer; i++) {
      // Distribute along the back row (row 0)
      // For 2 pieces: 0, Size-1 (Corners) - Current logic
      // For 3 pieces: 0, Mid, Size-1? or 0, 1, 2?
      // Let's space them out.

      int col;
      if (piecesPerPlayer == 2) {
        col = i == 0 ? 0 : boardSize - 1;
      } else if (piecesPerPlayer == 3) {
        if (i == 0) {
          col = 0;
        } else if (i == 1) {
          col = boardSize ~/ 2;
        } else {
          col = boardSize - 1;
        }
      } else {
        // 4 pieces (9x9)
        if (i == 0) {
          col = 0;
        } else if (i == 1) {
          col = 2;
        } else if (i == 2) {
          col = boardSize - 3;
        } else {
          col = boardSize - 1;
        }
      }

      grid[0][col].occupy(Player.player2);
      grid[boardSize - 1][col].occupy(Player.player1);
    }
  }

  // 3. Selection Logic
  void selectCell(int row, int col) {
    if (isGameOver) return;

    final cell = grid[row][col];

    // If tapping own piece -> Select it
    if (cell.isOccupied && cell.owner == _currentPlayer) {
      _selectedAndActiveCell = cell;
      notifyListeners();
      return;
    }

    // If moving to an empty cell
    if (_selectedAndActiveCell != null && cell.isEmpty) {
      if (_isValidMove(_selectedAndActiveCell!, cell)) {
        _performMove(_selectedAndActiveCell!, cell);
      }
    }
  }

  // 4. Move Validation (1 Step Orthogonal)
  bool _isValidMove(Cell from, Cell to) {
    final dr = (from.row - to.row).abs();
    final dc = (from.col - to.col).abs();

    // Must be exactly 1 step away (Up/Down/Left/Right)
    // Sum of differences must be 1 (0+1 or 1+0)
    return (dr + dc) == 1;
  }

  // 5. Execute Move & Block
  void _performMove(Cell from, Cell to) {
    // Move Piece
    to.occupy(_currentPlayer);

    // Block the OLD square (Core Mechanic)
    from.block();

    // Clear Selection
    _selectedAndActiveCell = null;

    // Switch Turn
    _currentPlayer = _currentPlayer.opponent;

    // Check for Win Condition
    _checkWinCondition();

    notifyListeners();
  }

  // 6. Win Check (Does current player have ANY moves?)
  void _checkWinCondition() {
    // If the NEW current player has NO moves, the PREVIOUS player wins
    if (!_hasLegalMoves(_currentPlayer)) {
      _winner = _currentPlayer.opponent;
    }
  }

  bool _hasLegalMoves(Player p) {
    // Find all pieces for player 'p'
    for (var row in grid) {
      for (var cell in row) {
        if (cell.owner == p) {
          // Check all 4 neighbors
          if (_canMove(cell, -1, 0)) return true; // Up
          if (_canMove(cell, 1, 0)) return true; // Down
          if (_canMove(cell, 0, -1)) return true; // Left
          if (_canMove(cell, 0, 1)) return true; // Right
        }
      }
    }
    return false;
  }

  bool _canMove(Cell from, int dRow, int dCol) {
    final r = from.row + dRow;
    final c = from.col + dCol;

    // Check Bounds
    if (r < 0 || r >= boardSize || c < 0 || c >= boardSize) return false;

    // Check if Empty
    return grid[r][c].isEmpty;
  }
}
