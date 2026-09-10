import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/domain/models/achievement.dart';
import 'package:arrow_path/domain/models/cloud_game_data.dart';
import 'package:arrow_path/domain/models/level_progress.dart';
import 'package:arrow_path/domain/models/reward_transaction.dart';
import 'package:arrow_path/services/daily_challenge_service.dart';
import 'package:arrow_path/services/progress_merge_service.dart';

void main() {
  group('ProgressMergeService Rules', () {
    test('union of completed levels, max stars, best moves', () {
      final localData = CloudGameData(
        userId: 'user_1',
        currentLevel: 50,
        levelProgressMap: {
          10: const LevelProgress(levelNumber: 10, isCompleted: true, stars: 2, bestMoves: 25),
          20: const LevelProgress(levelNumber: 20, isCompleted: true, stars: 3, bestMoves: 12),
        },
        coinsBalance: 100,
        rewardTransactions: const [
          RewardTransaction(id: 'tx1', type: RewardType.levelComplete, amount: 20, timestamp: 1000, referenceId: 'lvl_10'),
        ],
        dailyChallengeResults: const {},
        longestStreak: 3,
        achievements: const {},
        lastSyncedAt: 1000,
      );

      final cloudData = CloudGameData(
        userId: 'user_1',
        currentLevel: 100,
        levelProgressMap: {
          10: const LevelProgress(levelNumber: 10, isCompleted: true, stars: 3, bestMoves: 20),
          30: const LevelProgress(levelNumber: 30, isCompleted: true, stars: 1, bestMoves: 15),
        },
        coinsBalance: 200,
        rewardTransactions: const [
          RewardTransaction(id: 'tx1', type: RewardType.levelComplete, amount: 20, timestamp: 1000, referenceId: 'lvl_10'),
          RewardTransaction(id: 'tx2', type: RewardType.levelComplete, amount: 20, timestamp: 2000, referenceId: 'lvl_30'),
        ],
        dailyChallengeResults: const {},
        longestStreak: 5,
        achievements: const {},
        lastSyncedAt: 2000,
      );

      final merged = ProgressMergeService.mergeGameData(
        localData: localData,
        cloudData: cloudData,
        targetUserId: 'user_1',
      );

      expect(merged.currentLevel, 100); // Highest level index
      expect(merged.levelProgressMap.length, 3); // Level 10, 20, 30

      // Level 10 retains 3 stars (cloud) and 20 best moves (cloud min moves)
      expect(merged.levelProgressMap[10]?.stars, 3);
      expect(merged.levelProgressMap[10]?.bestMoves, 20);

      // Coins de-duplicated: tx1 (20) + tx2 (20) = 40
      expect(merged.rewardTransactions.length, 2);
      expect(merged.coinsBalance, 40);

      // Longest streak
      expect(merged.longestStreak, 5);
    });

    test('union of achievements and daily challenges', () {
      final localData = CloudGameData(
        userId: 'user_1',
        currentLevel: 10,
        levelProgressMap: const {},
        coinsBalance: 50,
        rewardTransactions: const [],
        dailyChallengeResults: {
          '2026-09-10': const DailyChallengeResult(dateIso: '2026-09-10', isCompleted: true, stars: 3, movesTaken: 12, bestMoves: 12),
        },
        longestStreak: 1,
        achievements: {
          'first_move': const Achievement(id: 'first_move', title: 'First Move', description: 'desc', iconName: 'nav', target: 1, progress: 1, isUnlocked: true, coinReward: 25),
        },
        lastSyncedAt: 1000,
      );

      final cloudData = CloudGameData(
        userId: 'user_1',
        currentLevel: 10,
        levelProgressMap: const {},
        coinsBalance: 50,
        rewardTransactions: const [],
        dailyChallengeResults: {
          '2026-09-11': const DailyChallengeResult(dateIso: '2026-09-11', isCompleted: true, stars: 2, movesTaken: 15, bestMoves: 15),
        },
        longestStreak: 2,
        achievements: {
          'first_victory': const Achievement(id: 'first_victory', title: 'First Victory', description: 'desc', iconName: 'trophy', target: 1, progress: 1, isUnlocked: true, coinReward: 50),
        },
        lastSyncedAt: 2000,
      );

      final merged = ProgressMergeService.mergeGameData(
        localData: localData,
        cloudData: cloudData,
        targetUserId: 'user_1',
      );

      expect(merged.dailyChallengeResults.length, 2);
      expect(merged.achievements.length, 2);
      expect(merged.achievements['first_move']?.isUnlocked, isTrue);
      expect(merged.achievements['first_victory']?.isUnlocked, isTrue);
    });
  });
}
