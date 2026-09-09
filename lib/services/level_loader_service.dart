import '../data/repositories/asset_level_repository.dart';
import '../domain/level_generator.dart';
import '../domain/models/level_definition.dart';
import '../domain/repositories/level_repository.dart';

/// Service using LevelRepository to load levels, falling back to runtime generation if needed.
class LevelLoaderService {
  final LevelRepository _levelRepository;

  LevelLoaderService({LevelRepository? levelRepository})
      : _levelRepository = levelRepository ?? AssetLevelRepository();

  /// Load all levels.
  Future<List<LevelDefinition>> loadAllLevels() async {
    final levels = await _levelRepository.getAllLevels();
    if (levels.isNotEmpty) {
      return levels;
    }
    // Fallback runtime generator if asset reading fails
    final generator = LevelGenerator(seed: 2026);
    return generator.generate100Levels();
  }

  /// Load a single level by ID.
  Future<LevelDefinition> loadLevel(int levelNumber) async {
    final level = await _levelRepository.getLevelById(levelNumber);
    if (level != null) {
      return level;
    }
    // Fallback deterministic generator
    final generator = LevelGenerator(seed: levelNumber);
    return generator.generateLevel(levelNumber);
  }
}
