import '../models/level_progress.dart';

/// Abstract repository interface for player data persistence.
abstract class GameRepository {
  Future<int> getCurrentLevel();
  Future<void> setCurrentLevel(int levelNumber);

  Future<Map<int, LevelProgress>> getAllProgress();
  Future<LevelProgress?> getLevelProgress(int levelNumber);
  Future<void> saveLevelProgress(LevelProgress progress);

  Future<bool> isSoundEnabled();
  Future<void> setSoundEnabled(bool enabled);

  Future<bool> isMusicEnabled();
  Future<void> setMusicEnabled(bool enabled);

  Future<bool> isVibrationEnabled();
  Future<void> setVibrationEnabled(bool enabled);

  Future<void> clearAllData();
}
