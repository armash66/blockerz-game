import 'package:flutter/foundation.dart';
import 'board.dart';

class GameState extends ChangeNotifier {
  // 5x5 Grid
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

  GameState() : grid = _createGrid() {
    _initializePieces();
  }

  // 1. Initialize 5x5 Grid
  static List<List<Cell>> _createGrid() {
    return List.generate(5, (row) {
      return List.generate(5, (col) {
        return Cell(row: row, col: col);
      });
    });
  }

  // 2. Setup Starting Positions (Corners)
  void _initializePieces() {
    // Player 1: Top Corners (0,0) and (0,4)
    grid[0][0].occupy(Player.player1);
    grid[0][4].occupy(Player.player1);

    // Player 2: Bottom Corners (4,0) and (4,4)
    grid[4][0].occupy(Player.player2);
    grid[4][4].occupy(Player.player2);
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
    if (r < 0 || r >= 5 || c < 0 || c >= 5) return false;

    // Check if Empty
    return grid[r][c].isEmpty;
  }
}
