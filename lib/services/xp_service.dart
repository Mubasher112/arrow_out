import '../domain/models/player_level.dart';
import '../domain/repositories/game_repository.dart';
import 'reward_service.dart';

/// Result object for XP additions.
class XpGainResult {
  final int xpGained;
  final PlayerLevel newPlayerLevel;
  final bool didLevelUp;
  final int coinsBonusEarned;

  const XpGainResult({
    required this.xpGained,
    required this.newPlayerLevel,
    required this.didLevelUp,
    required this.coinsBonusEarned,
  });
}

/// Service managing account XP progression and level-up milestone rewards.
class XpService {
  final GameRepository _repository;
  final RewardService _rewardService;

  static const int xpLevelComplete = 50;
  static const int xpDailyChallenge = 100;
  static const int xpWeeklyChallenge = 150;
  static const int xpAchievement = 200;
  static const int coinsPerLevelUp = 100;

  XpService({
    required GameRepository repository,
    required RewardService rewardService,
  })  : _repository = repository,
        _rewardService = rewardService;

  /// Award XP to player and handle level up milestones.
  Future<XpGainResult> addXp(int xpAmount) async {
    final curLevel = await _repository.getSavedAccountModel(); // or player level storage
    final currentCoins = await _repository.getCoinsBalance();

    int playerLevel = 1;
    int currentXp = 0;

    // Read stored XP
    final savedXp = await _repository.getCurrentLevel(); // using stored index
    currentXp += xpAmount;

    bool didLevelUp = false;
    int bonusCoins = 0;

    int requiredXp = playerLevel * 250;
    while (currentXp >= requiredXp) {
      currentXp -= requiredXp;
      playerLevel++;
      didLevelUp = true;
      bonusCoins += coinsPerLevelUp;
      requiredXp = playerLevel * 250;
    }

    if (bonusCoins > 0) {
      await _repository.addCoins(bonusCoins);
    }

    final newLevel = PlayerLevel(level: playerLevel, currentXp: currentXp);

    return XpGainResult(
      xpGained: xpAmount,
      newPlayerLevel: newLevel,
      didLevelUp: didLevelUp,
      coinsBonusEarned: bonusCoins,
    );
  }
}
