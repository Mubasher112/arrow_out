import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/level_progress.dart';
import '../../domain/models/reward_transaction.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/daily_challenge_service.dart';

/// Local implementation of GameRepository using SharedPreferences.
class LocalGameRepository implements GameRepository {
  static const String _keyCurrentLevel = 'arrow_path_current_level_v2';
  static const String _keyLevelProgressMap = 'arrow_path_progress_map_v2';
  static const String _keySoundEnabled = 'arrow_path_sound_enabled';
  static const String _keyMusicEnabled = 'arrow_path_music_enabled';
  static const String _keyVibrationEnabled = 'arrow_path_vibration_enabled';

  static const String _keyCoinsBalance = 'arrow_path_coins_balance';
  static const String _keyRewardTransactions = 'arrow_path_reward_transactions';
  static const String _keyDailyChallengeResults = 'arrow_path_daily_challenge_results';
  static const String _keyLongestStreak = 'arrow_path_longest_streak';
  static const String _keyAchievements = 'arrow_path_achievements';

  final SharedPreferencesAsync _prefs;

  LocalGameRepository({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  @override
  Future<int> getCurrentLevel() async {
    final level = await _prefs.getInt(_keyCurrentLevel);
    if (level != null) return level;
    // Check v1 key for backward compatibility migration
    final v1Level = await _prefs.getInt('arrow_path_current_level');
    return v1Level ?? 1;
  }

  @override
  Future<void> setCurrentLevel(int levelNumber) async {
    await _prefs.setInt(_keyCurrentLevel, levelNumber);
  }

  @override
  Future<Map<int, LevelProgress>> getAllProgress() async {
    String? jsonStr = await _prefs.getString(_keyLevelProgressMap);
    jsonStr ??= await _prefs.getString('arrow_path_progress_map');

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
  Future<int> getCoinsBalance() async {
    final coins = await _prefs.getInt(_keyCoinsBalance);
    return coins ?? 0;
  }

  @override
  Future<void> addCoins(int amount) async {
    final current = await getCoinsBalance();
    await _prefs.setInt(_keyCoinsBalance, current + amount);
  }

  @override
  Future<void> setCoinsBalance(int coins) async {
    await _prefs.setInt(_keyCoinsBalance, coins);
  }

  @override
  Future<List<RewardTransaction>> getRewardTransactions() async {
    final jsonStr = await _prefs.getString(_keyRewardTransactions);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => RewardTransaction.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addRewardTransaction(RewardTransaction transaction) async {
    final list = await getRewardTransactions();
    list.add(transaction);
    final jsonList = list.map((t) => t.toJson()).toList();
    await _prefs.setString(_keyRewardTransactions, jsonEncode(jsonList));
  }

  @override
  Future<Map<String, DailyChallengeResult>> getDailyChallengeResults() async {
    final jsonStr = await _prefs.getString(_keyDailyChallengeResults);
    if (jsonStr == null || jsonStr.isEmpty) return {};

    try {
      final Map<String, dynamic> rawMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      final Map<String, DailyChallengeResult> resultMap = {};
      rawMap.forEach((key, val) {
        resultMap[key] = DailyChallengeResult.fromJson(val as Map<String, dynamic>);
      });
      return resultMap;
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> saveDailyChallengeResult(DailyChallengeResult result) async {
    final map = await getDailyChallengeResults();
    map[result.dateIso] = result;

    final rawMap = <String, dynamic>{};
    map.forEach((k, v) => rawMap[k] = v.toJson());

    await _prefs.setString(_keyDailyChallengeResults, jsonEncode(rawMap));
  }

  @override
  Future<int> getLongestStreak() async {
    final streak = await _prefs.getInt(_keyLongestStreak);
    return streak ?? 0;
  }

  @override
  Future<void> setLongestStreak(int streak) async {
    await _prefs.setInt(_keyLongestStreak, streak);
  }

  @override
  Future<Map<String, Achievement>> getAchievements() async {
    final jsonStr = await _prefs.getString(_keyAchievements);
    if (jsonStr == null || jsonStr.isEmpty) return {};

    try {
      final Map<String, dynamic> rawMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      final Map<String, Achievement> resultMap = {};
      rawMap.forEach((k, v) {
        resultMap[k] = Achievement.fromJson(v as Map<String, dynamic>);
      });
      return resultMap;
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> saveAchievement(Achievement achievement) async {
    final map = await getAchievements();
    map[achievement.id] = achievement;

    final rawMap = <String, dynamic>{};
    map.forEach((k, v) => rawMap[k] = v.toJson());

    await _prefs.setString(_keyAchievements, jsonEncode(rawMap));
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
    await _prefs.remove('arrow_path_current_level');
    await _prefs.remove('arrow_path_progress_map');
    await _prefs.remove(_keySoundEnabled);
    await _prefs.remove(_keyMusicEnabled);
    await _prefs.remove(_keyVibrationEnabled);
    await _prefs.remove(_keyCoinsBalance);
    await _prefs.remove(_keyRewardTransactions);
    await _prefs.remove(_keyDailyChallengeResults);
    await _prefs.remove(_keyLongestStreak);
    await _prefs.remove(_keyAchievements);
  }
}
