import '../../domain/models/level_progress.dart';
import '../../domain/repositories/game_repository.dart';

class MockGameRepository implements GameRepository {
  final Map<int, LevelProgress> _progress = {};
  final Map<String, String> _keyValueStore = {};
  int _coins = 100;
  int _currentLevel = 1;
  int _soundVolume = 100;
  int _musicVolume = 100;

  @override
  Future<int> getCoinsBalance() async => _coins;

  @override
  Future<void> updateCoinsBalance(int coins) async {
    _coins = coins;
  }

  @override
  Future<int> getCurrentLevelId() async => _currentLevel;

  @override
  Future<void> saveCurrentLevelId(int levelId) async {
    _currentLevel = levelId;
  }

  @override
  Future<LevelProgress?> getLevelProgress(int levelId) async {
    return _progress[levelId];
  }

  @override
  Future<void> saveLevelProgress(LevelProgress progress) async {
    _progress[progress.levelId] = progress;
  }

  @override
  Future<Map<int, LevelProgress>> getAllProgress() async {
    return Map.unmodifiable(_progress);
  }

  @override
  Future<int> getSoundVolume() async => _soundVolume;

  @override
  Future<void> setSoundVolume(int volume) async {
    _soundVolume = volume;
  }

  @override
  Future<int> getMusicVolume() async => _musicVolume;

  @override
  Future<void> setMusicVolume(int volume) async {
    _musicVolume = volume;
  }

  @override
  Future<String?> getString(String key) async => _keyValueStore[key];

  @override
  Future<void> setString(String key, String value) async {
    _keyValueStore[key] = value;
  }

  @override
  Future<void> clearAll() async {
    _progress.clear();
    _keyValueStore.clear();
    _coins = 100;
    _currentLevel = 1;
  }
}
