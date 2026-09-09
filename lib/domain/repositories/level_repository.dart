import '../models/level_definition.dart';

/// Abstract repository interface for loading and querying puzzle levels.
abstract class LevelRepository {
  Future<List<LevelDefinition>> getAllLevels();
  Future<LevelDefinition?> getLevelById(int id);
  Future<List<LevelDefinition>> getLevelRange(int startId, int count);
  Future<bool> validateLevel(LevelDefinition level);
}
