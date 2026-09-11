import '../domain/models/daily_login_reward.dart';
import '../domain/models/reward_transaction.dart';
import '../domain/repositories/game_repository.dart';
import 'date_provider.dart';
import 'reward_service.dart';

/// Service managing 7-day calendar daily login rewards and date ISO claim tracking.
class DailyLoginService {
  final GameRepository _repository;
  final RewardService _rewardService;
  final DateProvider _dateProvider;

  static const List<DailyLoginReward> defaultRewards = [
    DailyLoginReward(day: 1, type: RewardType.levelComplete, amount: 50),
    DailyLoginReward(day: 2, type: RewardType.levelComplete, amount: 75),
    DailyLoginReward(day: 3, type: RewardType.threeStarBonus, amount: 100),
    DailyLoginReward(day: 4, type: RewardType.levelComplete, amount: 125),
    DailyLoginReward(day: 5, type: RewardType.threeStarBonus, amount: 150),
    DailyLoginReward(day: 6, type: RewardType.levelComplete, amount: 200),
    DailyLoginReward(day: 7, type: RewardType.dailyChallenge, amount: 350),
  ];

  DailyLoginService({
    required GameRepository repository,
    required RewardService rewardService,
    DateProvider? dateProvider,
  })  : _repository = repository,
        _rewardService = rewardService,
        _dateProvider = dateProvider ?? const LocalDateProvider();

  /// Check whether player has already claimed today's login reward.
  Future<bool> isTodayClaimed() async {
    final todayIso = _dateProvider.currentDateIso;
    final lastClaimedIso = await _repository.getLastDailyLoginClaimIso();
    return lastClaimedIso == todayIso;
  }

  /// Get current login cycle day (1..7).
  Future<int> getCurrentLoginDay() async {
    final day = await _repository.getCurrentLoginDay();
    return day.clamp(1, 7);
  }

  /// Claim today's login reward if eligible.
  Future<int> claimTodayReward() async {
    final todayIso = _dateProvider.currentDateIso;
    if (await isTodayClaimed()) return 0;

    int currentDay = await getCurrentLoginDay();
    final rewardDef = defaultRewards[currentDay - 1];

    final ref = 'daily_login_${todayIso}_day_$currentDay';
    if (!await _rewardService.hasClaimed(ref)) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final tx = RewardTransaction(
        id: 'tx_login_$now',
        type: rewardDef.type,
        amount: rewardDef.amount,
        timestamp: now,
        referenceId: ref,
      );
      await _repository.addRewardTransaction(tx);
      await _repository.addCoins(rewardDef.amount);
    }

    await _repository.setLastDailyLoginClaimIso(todayIso);

    // Advance to next day or loop to Day 1
    final nextDay = (currentDay >= 7) ? 1 : currentDay + 1;
    await _repository.setCurrentLoginDay(nextDay);

    return rewardDef.amount;
  }
}
