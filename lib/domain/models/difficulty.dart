/// Puzzle difficulty ratings.
enum Difficulty {
  easy,
  medium,
  hard;

  static Difficulty fromString(String val) {
    return Difficulty.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => Difficulty.easy,
    );
  }
}
