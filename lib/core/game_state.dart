import 'package:flutter/foundation.dart';
import 'board.dart';
import 'powerup.dart';
import 'ai_player.dart';

class GameState extends ChangeNotifier {
  // Grid
  final int boardSize;
  final List<List<Cell>> grid;

  // Turn Management
  Player _currentPlayer = Player.player1;
  Player? _winner;

  // AI Configuration
  AIDifficulty? aiDifficulty; // Null means PvP or Player's turn

  // Game Status
  bool get isGameOver => _winner != null;
  Player get currentPlayer => _currentPlayer;
  Player? get winner => _winner;

  // Powerup State
  final Map<Player, int> _turnsPlayed = {
    Player.player1: 0,
    Player.player2: 0,
  };

  final Map<Player, List<Powerup>> _inventory = {
    Player.player1: [],
    Player.player2: [],
  };

  Powerup? _activePowerup;

  // Selected Piece for Movement
  Cell? _selectedAndActiveCell;
  Cell? get selectedCell => _selectedAndActiveCell;

  bool get isPowerupSelectionPhase {
    if (_powerupSelectedThisTurn) return false;

    // A player is eligible for a powerup AFTER they have COMPLETED 3, 6, 9... moves.
    // So at the START of Turn 4, 7, 10... (when count is 3, 6, 9...)
    final turnsCompleted = _turnsPlayed[_currentPlayer] ?? 0;
    if (turnsCompleted > 0 && turnsCompleted % 3 == 0) {
      if (_currentPlayer == Player.player2 && aiDifficulty != null) {
        return false; // AI handled in _endTurn
      }
      return true;
    }
    return false;
  }

  List<Powerup> get currentPlayerInventory => _inventory[_currentPlayer] ?? [];
  List<Powerup> getPlayerInventory(Player p) => _inventory[p] ?? [];
  Powerup? get activePowerup => _activePowerup;

  GameState({this.boardSize = 5, this.aiDifficulty})
      : grid = _createGrid(boardSize) {
    _initializePieces();
  }

  // Powerup: Add to Inventory & Complete Selection
  void selectPowerup(Powerup powerup) {
    _inventory[_currentPlayer]?.add(powerup);
    _powerupSelectedThisTurn = true;
    notifyListeners();
  }

  bool _powerupSelectedThisTurn = false;

  // Powerup: Activation
  void activatePowerup(Powerup powerup) {
    if (_activePowerup == powerup) {
      _activePowerup = null; // Toggle off
    } else {
      _activePowerup = powerup;
    }
    _selectedAndActiveCell = null; // Clear movement selection
    notifyListeners();
  }

  // Powerup: Execution
  bool applyPowerup(Cell target) {
    if (_activePowerup == null) return false;

    bool success = false;
    final type = _activePowerup!.type;

    switch (type) {
      case PowerupType.extraMove:
        // Handled in _performMove
        success = false;
        break;
      case PowerupType.wallBuilder:
        success = _applyWallBuilder(target);
        break;
      case PowerupType.pathClearer:
        success = _applyPathClearer(target);
        break;
    }

    if (success) {
      // Consume Powerup BUT DO NOT END TURN (Free Action)
      _inventory[_currentPlayer]?.remove(_activePowerup);
      _activePowerup = null;
      // Note: We deliberately removed _endTurn() here.
      // User must still make a regular move.
      notifyListeners(); // UI Update!
    }
    return success;
  }

  // --- New Powerup Implementations ---

  // 1. Wall Builder: Block ANY empty tile
  bool _applyWallBuilder(Cell target) {
    if (!target.isEmpty) return false;

    // Remote Block
    target.block();
    return true;
  }

  // 2. Path Clearer: Unblock ANY blocked tile
  bool _applyPathClearer(Cell target) {
    if (!target.isBlocked) return false;

    // Unblock
    target.type = CellType.empty;
    return true;
  }

  void _performMove(Cell from, Cell to) {
    // Move Piece
    to.occupy(_currentPlayer);

    // Block the OLD square (Core Mechanic)
    from.block();

    // Check Extra Move
    if (_activePowerup?.type == PowerupType.extraMove) {
      // Don't end turn yet!
      _inventory[_currentPlayer]?.remove(_activePowerup);
      _activePowerup = null;
      _selectedAndActiveCell = null; // Clear selection

      // CRITICAL FIX: Check if the player (who still has the turn) ACTUALLY has moves left.
      // If they used their extra move to fill the last spot, they might be stuck.
      _checkWinCondition();

      notifyListeners();
      return;
    }

    _selectedAndActiveCell = null;
    _endTurn();
  }

  void _endTurn() {
    _activePowerup = null;

    // Increment moves for the player who JUST finished
    _turnsPlayed[_currentPlayer] = (_turnsPlayed[_currentPlayer] ?? 0) + 1;

    // Switch to Next Player
    _currentPlayer = _currentPlayer.opponent;
    _powerupSelectedThisTurn = false;

    // Check AI Hard Powerup Grant (Now checking the NEW player who just started)
    if (_currentPlayer == Player.player2 && aiDifficulty == AIDifficulty.hard) {
      final turnsCompletedByAI = _turnsPlayed[_currentPlayer] ?? 0;
      if (turnsCompletedByAI > 0 && turnsCompletedByAI % 3 == 0) {
        // Grant Random Powerup automatically
        // Simple random selection
        // We can't import valid dart:math Random here easily without making field.
        // Let's just give Double Move for now or cycle?
        // Better: use list.
        const list = Powerup.all;
        final item = list[DateTime.now().millisecond % list.length];
        _inventory[_currentPlayer]?.add(item);
      }
    }

    _checkWinCondition();
    notifyListeners();
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
