import '../domain/models/level_definition.dart';
import '../domain/models/level_progress.dart';

/// Calculation result when evaluating a completed level run.
class ScoreEvaluation {
  final int stars;
  final bool isNewBest;
  final bool isStarImproved;
  final bool isMoveImproved;

  const ScoreEvaluation({
    required this.stars,
    required this.isNewBest,
    required this.isStarImproved,
    required this.isMoveImproved,
  });
}

/// Domain service for evaluating stars, total star accumulation, and best scores.
class StarRatingService {
  /// Calculate star rating for a run based on moves taken vs par moves.
  static int calculateStars(int movesTaken, LevelDefinition level) {
    if (movesTaken <= level.parMoves) return 3;
    if (movesTaken <= level.parMoves + 3) return 2;
    return 1;
  }

  /// Evaluate if a new run improves upon existing saved progress.
  static ScoreEvaluation evaluateRun({
    required int movesTaken,
    required LevelDefinition level,
    LevelProgress? existingProgress,
  }) {
    final stars = calculateStars(movesTaken, level);

    if (existingProgress == null || !existingProgress.isCompleted) {
      return ScoreEvaluation(
        stars: stars,
        isNewBest: true,
        isStarImproved: true,
        isMoveImproved: true,
      );
    }

    final isStarImproved = stars > existingProgress.stars;
    final isStarEqual = stars == existingProgress.stars;
    final isMoveImproved = movesTaken < existingProgress.bestMoves;

    final isNewBest = isStarImproved || (isStarEqual && isMoveImproved);

    return ScoreEvaluation(
      stars: stars,
      isNewBest: isNewBest,
      isStarImproved: isStarImproved,
      isMoveImproved: isMoveImproved,
    );
  }

  /// Calculate total accumulative stars across all completed levels without double counting.
  static int calculateTotalStars(Map<int, LevelProgress> progressMap) {
    int total = 0;
    progressMap.forEach((_, p) {
      if (p.isCompleted) {
        total += p.stars;
      }
    });
    return total;
  }
}
