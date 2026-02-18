enum Player {
  player1,
  player2;

  Player get opponent => this == player1 ? player2 : player1;
}

enum CellType {
  empty,
  occupied,
  blocked,
}

class Cell {
  final int row;
  final int col;
  CellType type;
  Player? owner; // For occupied cells

  Cell({
    required this.row,
    required this.col,
    this.type = CellType.empty,
    this.owner,
  });

  bool get isEmpty => type == CellType.empty;
  bool get isBlocked => type == CellType.blocked;
  bool get isOccupied => type == CellType.occupied;

  void occupy(Player p) {
    type = CellType.occupied;
    owner = p;
  }

  void block() {
    type = CellType.blocked;
    owner = null;
  }

  void clear() {
    type = CellType.empty;
    owner = null;
  }

  // Snapshot Helpers
  CellState saveState() {
    return CellState(owner, isBlocked, false);
  }

  void copyFrom(CellState state) {
    type = state.isBlocked
        ? CellType.blocked
        : (state.owner != null ? CellType.occupied : CellType.empty);
    owner = state.owner;
    // Selection is transient, don't restore
  }
}

class CellState {
  final Player? owner;
  final bool isBlocked;
  final bool isSelected;

  CellState(this.owner, this.isBlocked, this.isSelected);
}
