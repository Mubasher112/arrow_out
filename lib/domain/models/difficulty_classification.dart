/// Measurable data-driven difficulty classification.
enum DifficultyClassification {
  easy,
  normal,
  hard,
  expert,
  master;

  /// Calculate classification based on board size, arrow count, and par moves.
  static DifficultyClassification classify({
    required int rows,
    required int cols,
    required int arrowCount,
    required int parMoves,
  }) {
    final totalCells = rows * cols;
    final density = arrowCount / totalCells;

    if (totalCells <= 16 && density <= 0.4) {
      return DifficultyClassification.easy;
    } else if (totalCells <= 25 && density <= 0.5) {
      return DifficultyClassification.normal;
    } else if (totalCells <= 36 && density <= 0.6) {
      return DifficultyClassification.hard;
    } else if (totalCells <= 49) {
      return DifficultyClassification.expert;
    } else {
      return DifficultyClassification.master;
    }
  }
}
