/// Stores progress details for a completed level.
class LevelProgress {
  final int levelNumber;
  final bool isCompleted;
  final int stars;
  final int bestMoves;

  const LevelProgress({
    required this.levelNumber,
    required this.isCompleted,
    required this.stars,
    required this.bestMoves,
  });

  Map<String, dynamic> toJson() {
    return {
      'levelNumber': levelNumber,
      'isCompleted': isCompleted,
      'stars': stars,
      'bestMoves': bestMoves,
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      levelNumber: json['levelNumber'] as int,
      isCompleted: json['isCompleted'] as bool,
      stars: json['stars'] as int,
      bestMoves: json['bestMoves'] as int,
    );
  }
}
