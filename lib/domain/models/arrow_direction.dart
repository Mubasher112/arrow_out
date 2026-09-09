/// Direction an arrow is pointing on the game board.
enum ArrowDirection {
  up(dRow: -1, dCol: 0),
  down(dRow: 1, dCol: 0),
  left(dRow: 0, dCol: -1),
  right(dRow: 0, dCol: 1);

  final int dRow;
  final int dCol;

  const ArrowDirection({required this.dRow, required this.dCol});

  /// Get opposite direction.
  ArrowDirection get opposite {
    switch (this) {
      case ArrowDirection.up:
        return ArrowDirection.down;
      case ArrowDirection.down:
        return ArrowDirection.up;
      case ArrowDirection.left:
        return ArrowDirection.right;
      case ArrowDirection.right:
        return ArrowDirection.left;
    }
  }

  /// Direction name in string.
  String get nameString => name;

  /// Parse direction from string.
  static ArrowDirection fromString(String val) {
    return ArrowDirection.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ArrowDirection.up,
    );
  }
}
