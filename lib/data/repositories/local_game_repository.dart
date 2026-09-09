import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/level_progress.dart';
import '../../domain/repositories/game_repository.dart';

/// Local implementation of GameRepository using SharedPreferences.
class LocalGameRepository implements GameRepository {
  static const String _keyCurrentLevel = 'arrow_path_current_level';
  static const String _keyLevelProgressMap = 'arrow_path_progress_map';
  static const String _keySoundEnabled = 'arrow_path_sound_enabled';
  static const String _keyMusicEnabled = 'arrow_path_music_enabled';
  static const String _keyVibrationEnabled = 'arrow_path_vibration_enabled';

  final SharedPreferencesAsync _prefs;

  LocalGameRepository({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  @override
  Future<int> getCurrentLevel() async {
    final level = await _prefs.getInt(_keyCurrentLevel);
    return level ?? 1;
  }

  @override
  Future<void> setCurrentLevel(int levelNumber) async {
    await _prefs.setInt(_keyCurrentLevel, levelNumber);
  }

  @override
  Future<Map<int, LevelProgress>> getAllProgress() async {
    final jsonStr = await _prefs.getString(_keyLevelProgressMap);
    if (jsonStr == null || jsonStr.isEmpty) {
      return {};
    }

    try {
      final Map<String, dynamic> rawMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      final Map<int, LevelProgress> progressMap = {};
      rawMap.forEach((key, value) {
        final levelNum = int.parse(key);
        progressMap[levelNum] = LevelProgress.fromJson(value as Map<String, dynamic>);
      });
      return progressMap;
    } catch (_) {
      return {};
    }
  }

  @override
  Future<LevelProgress?> getLevelProgress(int levelNumber) async {
    final map = await getAllProgress();
    return map[levelNumber];
  }

  @override
  Future<void> saveLevelProgress(LevelProgress progress) async {
    final map = await getAllProgress();
    final existing = map[progress.levelNumber];

    // Only update if better or new
    final updatedStars = existing != null && existing.stars > progress.stars
        ? existing.stars
        : progress.stars;
    final updatedBestMoves = existing != null && existing.bestMoves < progress.bestMoves
        ? existing.bestMoves
        : progress.bestMoves;

    map[progress.levelNumber] = LevelProgress(
      levelNumber: progress.levelNumber,
      isCompleted: true,
      stars: updatedStars,
      bestMoves: updatedBestMoves,
    );

    final rawMap = <String, dynamic>{};
    map.forEach((key, val) {
      rawMap[key.toString()] = val.toJson();
    });

    await _prefs.setString(_keyLevelProgressMap, jsonEncode(rawMap));
  }

  @override
  Future<bool> isSoundEnabled() async {
    return (await _prefs.getBool(_keySoundEnabled)) ?? true;
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_keySoundEnabled, enabled);
  }

  @override
  Future<bool> isMusicEnabled() async {
    return (await _prefs.getBool(_keyMusicEnabled)) ?? true;
  }

  @override
  Future<void> setMusicEnabled(bool enabled) async {
    await _prefs.setBool(_keyMusicEnabled, enabled);
  }

  @override
  Future<bool> isVibrationEnabled() async {
    return (await _prefs.getBool(_keyVibrationEnabled)) ?? true;
  }

  @override
  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_keyVibrationEnabled, enabled);
  }

  @override
  Future<void> clearAllData() async {
    await _prefs.remove(_keyCurrentLevel);
    await _prefs.remove(_keyLevelProgressMap);
    await _prefs.remove(_keySoundEnabled);
    await _prefs.remove(_keyMusicEnabled);
    await _prefs.remove(_keyVibrationEnabled);
  }
}
