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
}
