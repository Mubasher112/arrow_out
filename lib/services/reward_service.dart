import '../domain/models/reward_transaction.dart';
import '../domain/repositories/game_repository.dart';

/// Centralized service managing coin currency balance and granting non-duplicable rewards.
class RewardService {
  final GameRepository _repository;

  static const int rewardLevelComplete = 20;
  static const int rewardThreeStarBonus = 30;
  static const int rewardDailyChallenge = 100;
  static const int rewardStreakMilestone = 150;

  RewardService({required GameRepository repository}) : _repository = repository;

  /// Get current total coin balance.
  Future<int> getCoinsBalance() async {
    return await _repository.getCoinsBalance();
  }

  /// Check whether a transaction reference ID has already been claimed.
  Future<bool> hasClaimed(String referenceId) async {
    final transactions = await _repository.getRewardTransactions();
    return transactions.any((t) => t.referenceId == referenceId);
  }

  /// Grant level completion rewards (+20 coins base, +30 bonus for 3 stars) if not claimed yet.
  Future<int> grantLevelRewards({
    required int levelNumber,
    required int stars,
  }) async {
    int grantedAmount = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    final baseRef = 'level_complete_$levelNumber';
    if (!await hasClaimed(baseRef)) {
      final tx = RewardTransaction(
        id: 'tx_lvl_$levelNumber\_$now',
        type: RewardType.levelComplete,
        amount: rewardLevelComplete,
        timestamp: now,
        referenceId: baseRef,
      );
      await _repository.addRewardTransaction(tx);
      await _repository.addCoins(rewardLevelComplete);
      grantedAmount += rewardLevelComplete;
    }

    if (stars == 3) {
      final starRef = 'level_3star_$levelNumber';
      if (!await hasClaimed(starRef)) {
        final tx = RewardTransaction(
          id: 'tx_star_$levelNumber\_$now',
          type: RewardType.threeStarBonus,
          amount: rewardThreeStarBonus,
          timestamp: now,
          referenceId: starRef,
        );
        await _repository.addRewardTransaction(tx);
        await _repository.addCoins(rewardThreeStarBonus);
        grantedAmount += rewardThreeStarBonus;
      }
    }

    return grantedAmount;
  }

  /// Grant daily challenge reward (+100 coins) if not claimed yet.
  Future<int> grantDailyChallengeReward(String dateIso) async {
    final ref = 'daily_challenge_$dateIso';
    if (await hasClaimed(ref)) return 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final tx = RewardTransaction(
      id: 'tx_daily_$dateIso\_$now',
      type: RewardType.dailyChallenge,
      amount: rewardDailyChallenge,
      timestamp: now,
      referenceId: ref,
    );

    await _repository.addRewardTransaction(tx);
    await _repository.addCoins(rewardDailyChallenge);
    return rewardDailyChallenge;
  }

  /// Grant streak milestone bonus (+150 coins for every 7 day streak) if not claimed yet.
  Future<int> grantStreakMilestoneReward(int currentStreak) async {
    if (currentStreak <= 0 || currentStreak % 7 != 0) return 0;

    final ref = 'streak_milestone_$currentStreak';
    if (await hasClaimed(ref)) return 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final tx = RewardTransaction(
      id: 'tx_streak_$currentStreak\_$now',
      type: RewardType.streakMilestone,
      amount: rewardStreakMilestone,
      timestamp: now,
      referenceId: ref,
    );

    await _repository.addRewardTransaction(tx);
    await _repository.addCoins(rewardStreakMilestone);
    return rewardStreakMilestone;
  }
}
