import '../domain/models/level_definition.dart';
import '../domain/models/level_progress.dart';
import '../domain/repositories/game_repository.dart';
import 'star_rating_service.dart';

/// Application service orchestrating progression updates, level unlocking, and score persistence.
class ProgressionService {
  final GameRepository _repository;

  ProgressionService({required GameRepository repository})
      : _repository = repository;

  /// Process completed level run and save progress if improved. Returns ScoreEvaluation.
  Future<ScoreEvaluation> recordLevelCompletion({
    required LevelDefinition level,
    required int movesTaken,
  }) async {
    final existing = await _repository.getLevelProgress(level.levelNumber);
    final eval = StarRatingService.evaluateRun(
      movesTaken: movesTaken,
      level: level,
      existingProgress: existing,
    );

    // Compute updated stars and best moves to save
    final bestStars = (existing != null && existing.stars > eval.stars)
        ? existing.stars
        : eval.stars;
    final bestMoves = (existing != null && existing.bestMoves < movesTaken)
        ? existing.bestMoves
        : movesTaken;

    final updatedProgress = LevelProgress(
      levelNumber: level.levelNumber,
      isCompleted: true,
      stars: bestStars,
      bestMoves: bestMoves,
    );

    await _repository.saveLevelProgress(updatedProgress);

    // Unlock next level N+1
    final currentHighest = await _repository.getCurrentLevel();
    if (level.levelNumber >= currentHighest && level.levelNumber < 500) {
      await _repository.setCurrentLevel(level.levelNumber + 1);
    }

    return eval;
  }

  /// Get total stars accumulated by the player.
  Future<int> getTotalStars() async {
    final allProgress = await _repository.getAllProgress();
    return StarRatingService.calculateTotalStars(allProgress);
  }

  /// Get current unlocked level index.
  Future<int> getHighestUnlockedLevel() async {
    return await _repository.getCurrentLevel();
  }
}
