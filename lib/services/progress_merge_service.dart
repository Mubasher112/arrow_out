import 'dart:math' as math;
import '../domain/models/achievement.dart';
import '../domain/models/cloud_game_data.dart';
import '../domain/models/level_progress.dart';
import '../domain/models/reward_transaction.dart';
import 'daily_challenge_service.dart';

/// Pure domain service executing deterministic conflict resolution and progress merging.
class ProgressMergeService {
  /// Merge local guest game data and cloud account game data according to strict rules.
  static CloudGameData mergeGameData({
    required CloudGameData localData,
    required CloudGameData cloudData,
    required String targetUserId,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Current Level: Highest level index
    final mergedCurrentLevel = math.max(localData.currentLevel, cloudData.currentLevel);

    // 2. Level Progress Map: Union of completed levels, max stars, min best moves
    final Map<int, LevelProgress> mergedProgress = {};
    final allLevelKeys = <int>{
      ...localData.levelProgressMap.keys,
      ...cloudData.levelProgressMap.keys,
    };

    for (final levelNum in allLevelKeys) {
      final loc = localData.levelProgressMap[levelNum];
      final cld = cloudData.levelProgressMap[levelNum];

      if (loc != null && cld != null) {
        final isComp = loc.isCompleted || cld.isCompleted;
        final stars = math.max(loc.stars, cld.stars);

        int bestMoves = 0;
        if (loc.bestMoves > 0 && cld.bestMoves > 0) {
          bestMoves = math.min(loc.bestMoves, cld.bestMoves);
        } else {
          bestMoves = loc.bestMoves > 0 ? loc.bestMoves : cld.bestMoves;
        }

        mergedProgress[levelNum] = LevelProgress(
          levelNumber: levelNum,
          isCompleted: isComp,
          stars: stars,
          bestMoves: bestMoves,
        );
      } else {
        mergedProgress[levelNum] = loc ?? cld!;
      }
    }

    // 3. Reward Transactions & Coins Balance: De-duplicate transactions by referenceId
    final Map<String, RewardTransaction> txMap = {};
    for (final tx in localData.rewardTransactions) {
      txMap[tx.referenceId] = tx;
    }
    for (final tx in cloudData.rewardTransactions) {
      if (!txMap.containsKey(tx.referenceId)) {
        txMap[tx.referenceId] = tx;
      }
    }

    final mergedTransactions = txMap.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int recalculatedCoins = 0;
    for (final tx in mergedTransactions) {
      recalculatedCoins += tx.amount;
    }

    // 4. Daily Challenge Results: Merge by dateIso
    final Map<String, DailyChallengeResult> mergedDailyMap = {};
    final allDailyKeys = <String>{
      ...localData.dailyChallengeResults.keys,
      ...cloudData.dailyChallengeResults.keys,
    };

    for (final dateIso in allDailyKeys) {
      final loc = localData.dailyChallengeResults[dateIso];
      final cld = cloudData.dailyChallengeResults[dateIso];

      if (loc != null && cld != null) {
        final isComp = loc.isCompleted || cld.isCompleted;
        final stars = math.max(loc.stars, cld.stars);
        int bestMoves = 0;
        if (loc.bestMoves > 0 && cld.bestMoves > 0) {
          bestMoves = math.min(loc.bestMoves, cld.bestMoves);
        } else {
          bestMoves = loc.bestMoves > 0 ? loc.bestMoves : cld.bestMoves;
        }

        mergedDailyMap[dateIso] = DailyChallengeResult(
          dateIso: dateIso,
          isCompleted: isComp,
          stars: stars,
          movesTaken: loc.movesTaken,
          bestMoves: bestMoves,
        );
      } else {
        mergedDailyMap[dateIso] = loc ?? cld!;
      }
    }

    // 5. Longest Streak
    final mergedStreak = math.max(localData.longestStreak, cloudData.longestStreak);

    // 6. Achievements: Union unlocked achievements
    final Map<String, Achievement> mergedAchievements = {};
    final allAchievementKeys = <String>{
      ...localData.achievements.keys,
      ...cloudData.achievements.keys,
    };

    for (final key in allAchievementKeys) {
      final loc = localData.achievements[key];
      final cld = cloudData.achievements[key];

      if (loc != null && cld != null) {
        final isUnlocked = loc.isUnlocked || cld.isUnlocked;
        final progress = math.max(loc.progress, cld.progress);
        final unlockedAt = loc.unlockedAt ?? cld.unlockedAt;

        mergedAchievements[key] = loc.copyWith(
          progress: progress,
          isUnlocked: isUnlocked,
          unlockedAt: unlockedAt,
        );
      } else {
        mergedAchievements[key] = loc ?? cld!;
      }
    }

    return CloudGameData(
      schemaVersion: 1,
      userId: targetUserId,
      currentLevel: mergedCurrentLevel,
      levelProgressMap: mergedProgress,
      coinsBalance: recalculatedCoins,
      rewardTransactions: mergedTransactions,
      dailyChallengeResults: mergedDailyMap,
      longestStreak: mergedStreak,
      achievements: mergedAchievements,
      lastSyncedAt: now,
    );
  }
}
