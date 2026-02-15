import 'package:flutter/foundation.dart';
import 'board.dart';
import 'powerup.dart';

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
  // Powerup State
  int _turnsSinceLastPowerup = 0;
  final Map<Player, List<Powerup>> _inventory = {
    Player.player1: [],
    Player.player2: [],
  };

  Powerup? _activePowerup;

  // Selected Piece for Movement
  Cell? _selectedAndActiveCell;
  Cell? get selectedCell => _selectedAndActiveCell;

  bool get isPowerupSelectionPhase =>
      _turnsSinceLastPowerup > 0 && _turnsSinceLastPowerup % 3 == 0;
  List<Powerup> get currentPlayerInventory => _inventory[_currentPlayer] ?? [];
  Powerup? get activePowerup => _activePowerup;

  GameState({this.boardSize = 5}) : grid = _createGrid(boardSize) {
    _initializePieces();
  }

  // Powerup: Add to Inventory
  void addPowerupToInventory(Powerup powerup) {
    _inventory[_currentPlayer]?.add(powerup);
    // Reset counter or just keep it?
    // If we want it every 3 turns, we just let it grow.
    // Or we reset it. Let's reset it to 0 after selection?
    // No, logic is "Every 3 turns". So turns 3, 6, 9...
    // We'll handle the phase end in UI calling "completeSelection"
    notifyListeners();
  }

  void completePowerupSelection() {
    _turnsSinceLastPowerup = 0; // Reset counter after selection
    notifyListeners();
  }

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
      case PowerupType.highJump:
        success = _applyHighJump(target);
        break;
      case PowerupType.bomb:
        success = _applyBomb(target);
        break;
      case PowerupType.shield:
        success = _applyShield();
        break;
      case PowerupType.doubleMove:
        // Handled in _performMove
        success = false;
        break;
    }

    if (success) {
      // Consume Powerup and End Turn (unless Double Move / Shield special case)
      _inventory[_currentPlayer]?.remove(_activePowerup);
      _activePowerup = null;
      // Note: High Jump moves piece -> End Turn called in move.
      // Bomb -> End Turn called in apply.
      // Shield -> Instant effect -> End Turn?
      if (type == PowerupType.shield) _endTurn();
    }
    return success;
  }

  // --- New Powerup Implementations ---

  // 1. High Jump: Range 3, Ignores Obstacles
  bool _applyHighJump(Cell target) {
    if (_selectedAndActiveCell == null) return false;
    // Must be empty
    if (!target.isEmpty) return false;

    final from = _selectedAndActiveCell!;
    // Range Check (Manhattan Distance <= 3)
    final dr = (from.row - target.row).abs();
    final dc = (from.col - target.col).abs();

    // Logic: Range 3.
    if ((dr + dc) <= 3) {
      _performMove(from, target);
      return true;
    }
    return false;
  }

  // 2. Bomb: Destroy Blocked Cell
  bool _applyBomb(Cell target) {
    // Target must be BLOCKED
    if (!target.isBlocked) return false;

    // Destroy it!
    target.type = CellType.empty;

    // Bomb ends turn immediately
    _inventory[_currentPlayer]?.remove(Powerup.get(PowerupType.bomb));
    _activePowerup = null;
    _selectedAndActiveCell = null;
    _endTurn();
    return true;
  }

  // 3. Shield: Immune to blocking for next turn
  // We need a way to track "Immunity".
  // Let's add `_isShielded` state.
  bool _isShielded = false; // Current player is shielded?
  // Actually, shield protects the TILE you leave from being blocked.
  // Or protects YOU from being blocked?
  // "Immune to being blocked next turn" ->
  // Interpretation: The tile I move FROM is NOT blocked.
  // Implementation: Set flag, then in _performMove, skip block().

  bool _applyShield() {
    _isShielded = true;
    // Shield doesn't end turn, it applies to the MOVE.
    // So we just set state and return false (to not consume yet? No, consume now).
    // Wait, if we consume now, activePowerup becomes null.
    // Let's keep it active until move?
    // Easier: Just set a flag "Shield Active" and consume immediately.

    // BUT user has to move AFTER clicking shield.
    // So: Click Shield -> Active.
    // Then Move -> Check Active -> Skip Block -> Consume.
    return false; // Handled in performMove
  }

  void _performMove(Cell from, Cell to) {
    // Move Piece
    to.occupy(_currentPlayer);

    // Block the OLD square (Core Mechanic)
    // UNLESS Shield is active!
    // Or High Jump? (High Jump still blocks old square usually).

    bool skipBlock = false;

    // Check if player has shield active
    if (_isShielded) {
      skipBlock = true;
      _isShielded = false; // Consume shield
    } else if (_activePowerup?.type == PowerupType.shield) {
      // Fallback or double check if active powerup is still there?
      // Actually applyShield sets _isShielded.
      // So we rely on _isShielded.
    }

    if (!skipBlock) {
      from.block();
    }

    // Check Double Move
    if (_activePowerup?.type == PowerupType.doubleMove) {
      // Don't end turn yet!
      _inventory[_currentPlayer]?.remove(_activePowerup);
      _activePowerup = null;
      _selectedAndActiveCell = null; // Clear selection
      notifyListeners();
      return;
    }

    // High Jump Logic (Consume if used)
    if (_activePowerup?.type == PowerupType.highJump) {
      _inventory[_currentPlayer]?.remove(_activePowerup);
      _activePowerup = null;
    }

    _selectedAndActiveCell = null;
    _endTurn();
  }

  void _endTurn() {
    _activePowerup = null;
    _currentPlayer = _currentPlayer.opponent;

    // Increment turn counter only when Player 1 starts?
    // Or just count "half turns"?
    // "Every 3rd move" usually means "Every 3 rounds".
    // Let's increment on P2 -> P1 switch?
    if (_currentPlayer == Player.player1) {
      _turnsSinceLastPowerup++;
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
