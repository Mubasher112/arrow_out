import '../models/account_model.dart';
import '../models/achievement.dart';
import '../models/event_model.dart';
import '../models/level_progress.dart';
import '../models/notification_settings.dart';
import '../models/remote_config_model.dart';
import '../models/reward_transaction.dart';
import '../models/weekly_challenge.dart';
import '../../services/daily_challenge_service.dart';

/// Abstract repository interface for player data persistence.
abstract class GameRepository {
  Future<int> getCurrentLevel();
  Future<void> setCurrentLevel(int levelNumber);

  Future<Map<int, LevelProgress>> getAllProgress();
  Future<LevelProgress?> getLevelProgress(int levelNumber);
  Future<void> saveLevelProgress(LevelProgress progress);

  Future<int> getCoinsBalance();
  Future<void> addCoins(int amount);
  Future<void> setCoinsBalance(int coins);

  Future<List<RewardTransaction>> getRewardTransactions();
  Future<void> addRewardTransaction(RewardTransaction transaction);

  Future<Map<String, DailyChallengeResult>> getDailyChallengeResults();
  Future<void> saveDailyChallengeResult(DailyChallengeResult result);

  Future<int> getLongestStreak();
  Future<void> setLongestStreak(int streak);

  Future<Map<String, Achievement>> getAchievements();
  Future<void> saveAchievement(Achievement achievement);

  Future<AccountModel?> getSavedAccountModel();
  Future<void> saveAccountModel(AccountModel account);

  Future<String?> getLastDailyLoginClaimIso();
  Future<void> setLastDailyLoginClaimIso(String iso);

  Future<int> getCurrentLoginDay();
  Future<void> setCurrentLoginDay(int day);

  Future<Map<String, WeeklyChallenge>> getWeeklyChallenges();
  Future<void> saveWeeklyChallenge(WeeklyChallenge challenge);

  Future<EventModel?> getSavedEvent();
  Future<void> saveEvent(EventModel event);

  Future<NotificationSettings> getNotificationSettings();
  Future<void> setNotificationSettings(NotificationSettings settings);

  Future<RemoteConfigModel?> getRemoteConfig();
  Future<void> saveRemoteConfig(RemoteConfigModel config);

  Future<bool> isAdsRemoved();
  Future<void> setAdsRemoved(bool removed);

  Future<bool> isSoundEnabled();
  Future<void> setSoundEnabled(bool enabled);

  Future<bool> isMusicEnabled();
  Future<void> setMusicEnabled(bool enabled);

  Future<bool> isVibrationEnabled();
  Future<void> setVibrationEnabled(bool enabled);

  Future<void> clearAllData();
}
