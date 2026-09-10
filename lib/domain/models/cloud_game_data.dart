import 'achievement.dart';
import 'level_progress.dart';
import 'reward_transaction.dart';
import '../../services/daily_challenge_service.dart';

/// Container data model for local & cloud progress synchronization with schema versioning.
class CloudGameData {
  final int schemaVersion;
  final String userId;
  final int currentLevel;
  final Map<int, LevelProgress> levelProgressMap;
  final int coinsBalance;
  final List<RewardTransaction> rewardTransactions;
  final Map<String, DailyChallengeResult> dailyChallengeResults;
  final int longestStreak;
  final Map<String, Achievement> achievements;
  final int lastSyncedAt;

  const CloudGameData({
    this.schemaVersion = 1,
    required this.userId,
    required this.currentLevel,
    required this.levelProgressMap,
    required this.coinsBalance,
    required this.rewardTransactions,
    required this.dailyChallengeResults,
    required this.longestStreak,
    required this.achievements,
    required this.lastSyncedAt,
  });

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'userId': userId,
        'currentLevel': currentLevel,
        'levelProgressMap': levelProgressMap.map((k, v) => MapEntry(k.toString(), v.toJson())),
        'coinsBalance': coinsBalance,
        'rewardTransactions': rewardTransactions.map((t) => t.toJson()).toList(),
        'dailyChallengeResults': dailyChallengeResults.map((k, v) => MapEntry(k, v.toJson())),
        'longestStreak': longestStreak,
        'achievements': achievements.map((k, v) => MapEntry(k, v.toJson())),
        'lastSyncedAt': lastSyncedAt,
      };

  factory CloudGameData.fromJson(Map<String, dynamic> json) {
    final Map<int, LevelProgress> progressMap = {};
    if (json['levelProgressMap'] != null) {
      (json['levelProgressMap'] as Map<String, dynamic>).forEach((k, v) {
        progressMap[int.parse(k)] = LevelProgress.fromJson(v as Map<String, dynamic>);
      });
    }

    final List<RewardTransaction> txList = [];
    if (json['rewardTransactions'] != null) {
      for (final item in json['rewardTransactions'] as List) {
        txList.add(RewardTransaction.fromJson(item as Map<String, dynamic>));
      }
    }

    final Map<String, DailyChallengeResult> dailyMap = {};
    if (json['dailyChallengeResults'] != null) {
      (json['dailyChallengeResults'] as Map<String, dynamic>).forEach((k, v) {
        dailyMap[k] = DailyChallengeResult.fromJson(v as Map<String, dynamic>);
      });
    }

    final Map<String, Achievement> achieveMap = {};
    if (json['achievements'] != null) {
      (json['achievements'] as Map<String, dynamic>).forEach((k, v) {
        achieveMap[k] = Achievement.fromJson(v as Map<String, dynamic>);
      });
    }

    return CloudGameData(
      schemaVersion: (json['schemaVersion'] ?? 1) as int,
      userId: json['userId'] as String,
      currentLevel: (json['currentLevel'] ?? 1) as int,
      levelProgressMap: progressMap,
      coinsBalance: (json['coinsBalance'] ?? 0) as int,
      rewardTransactions: txList,
      dailyChallengeResults: dailyMap,
      longestStreak: (json['longestStreak'] ?? 0) as int,
      achievements: achieveMap,
      lastSyncedAt: (json['lastSyncedAt'] ?? 0) as int,
    );
  }
}
