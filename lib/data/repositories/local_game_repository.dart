import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/account_model.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/level_progress.dart';
import '../../domain/models/notification_settings.dart';
import '../../domain/models/remote_config_model.dart';
import '../../domain/models/reward_transaction.dart';
import '../../domain/models/weekly_challenge.dart';
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
  static const String _keyAccountModel = 'arrow_path_account_model';
  static const String _keyAdsRemoved = 'arrow_path_ads_removed';

  static const String _keyLastDailyLoginClaimIso = 'arrow_path_last_daily_login_claim_iso';
  static const String _keyCurrentLoginDay = 'arrow_path_current_login_day';
  static const String _keyWeeklyChallenges = 'arrow_path_weekly_challenges';
  static const String _keySavedEvent = 'arrow_path_saved_event';
  static const String _keyNotificationSettings = 'arrow_path_notification_settings';
  static const String _keyRemoteConfig = 'arrow_path_remote_config';

  final SharedPreferencesAsync _prefs;

  LocalGameRepository({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  @override
  Future<int> getCurrentLevel() async {
    final level = await _prefs.getInt(_keyCurrentLevel);
    if (level != null) return level;
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
  Future<AccountModel?> getSavedAccountModel() async {
    final jsonStr = await _prefs.getString(_keyAccountModel);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return AccountModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveAccountModel(AccountModel account) async {
    await _prefs.setString(_keyAccountModel, jsonEncode(account.toJson()));
  }

  @override
  Future<String?> getLastDailyLoginClaimIso() async {
    return await _prefs.getString(_keyLastDailyLoginClaimIso);
  }

  @override
  Future<void> setLastDailyLoginClaimIso(String iso) async {
    await _prefs.setString(_keyLastDailyLoginClaimIso, iso);
  }

  @override
  Future<int> getCurrentLoginDay() async {
    final day = await _prefs.getInt(_keyCurrentLoginDay);
    return day ?? 1;
  }

  @override
  Future<void> setCurrentLoginDay(int day) async {
    await _prefs.setInt(_keyCurrentLoginDay, day);
  }

  @override
  Future<Map<String, WeeklyChallenge>> getWeeklyChallenges() async {
    final jsonStr = await _prefs.getString(_keyWeeklyChallenges);
    if (jsonStr == null || jsonStr.isEmpty) return {};

    try {
      final Map<String, dynamic> rawMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      final Map<String, WeeklyChallenge> resultMap = {};
      rawMap.forEach((k, v) {
        resultMap[k] = WeeklyChallenge.fromJson(v as Map<String, dynamic>);
      });
      return resultMap;
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> saveWeeklyChallenge(WeeklyChallenge challenge) async {
    final map = await getWeeklyChallenges();
    map[challenge.id] = challenge;

    final rawMap = <String, dynamic>{};
    map.forEach((k, v) => rawMap[k] = v.toJson());

    await _prefs.setString(_keyWeeklyChallenges, jsonEncode(rawMap));
  }

  @override
  Future<EventModel?> getSavedEvent() async {
    final jsonStr = await _prefs.getString(_keySavedEvent);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return EventModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveEvent(EventModel event) async {
    await _prefs.setString(_keySavedEvent, jsonEncode(event.toJson()));
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    final jsonStr = await _prefs.getString(_keyNotificationSettings);
    if (jsonStr == null || jsonStr.isEmpty) return const NotificationSettings();
    try {
      return NotificationSettings.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return const NotificationSettings();
    }
  }

  @override
  Future<void> setNotificationSettings(NotificationSettings settings) async {
    await _prefs.setString(_keyNotificationSettings, jsonEncode(settings.toJson()));
  }

  @override
  Future<RemoteConfigModel?> getRemoteConfig() async {
    final jsonStr = await _prefs.getString(_keyRemoteConfig);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return RemoteConfigModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveRemoteConfig(RemoteConfigModel config) async {
    await _prefs.setString(_keyRemoteConfig, jsonEncode(config.toJson()));
  }

  @override
  Future<bool> isAdsRemoved() async {
    final removed = await _prefs.getBool(_keyAdsRemoved);
    return removed ?? false;
  }

  @override
  Future<void> setAdsRemoved(bool removed) async {
    await _prefs.setBool(_keyAdsRemoved, removed);
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
    await _prefs.remove(_keyAccountModel);
    await _prefs.remove(_keyAdsRemoved);
    await _prefs.remove(_keyLastDailyLoginClaimIso);
    await _prefs.remove(_keyCurrentLoginDay);
    await _prefs.remove(_keyWeeklyChallenges);
    await _prefs.remove(_keySavedEvent);
    await _prefs.remove(_keyNotificationSettings);
    await _prefs.remove(_keyRemoteConfig);
  }
}
