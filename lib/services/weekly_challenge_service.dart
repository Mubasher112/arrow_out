import '../domain/models/weekly_challenge.dart';
import '../domain/repositories/game_repository.dart';
import 'date_provider.dart';
import 'reward_service.dart';

/// Service managing weekly objective challenge progress and rewards.
class WeeklyChallengeService {
  final GameRepository _repository;
  final RewardService _rewardService;
  final DateProvider _dateProvider;

  WeeklyChallengeService({
    required GameRepository repository,
    required RewardService rewardService,
    DateProvider? dateProvider,
  })  : _repository = repository,
        _rewardService = rewardService,
        _dateProvider = dateProvider ?? const LocalDateProvider();

  List<WeeklyChallenge> getDefaultChallenges() {
    final now = _dateProvider.now;
    final startAtIso = DateProvider.dateToIso(now);
    final endAtIso = DateProvider.dateToIso(now.add(const Duration(days: 7)));

    return [
      WeeklyChallenge(
        id: 'week_levels_20',
        title: 'Complete 20 Levels',
        description: 'Clear any 20 levels in story mode.',
        target: 20,
        rewardAmount: 250,
        startAtIso: startAtIso,
        endAtIso: endAtIso,
      ),
      WeeklyChallenge(
        id: 'week_stars_50',
        title: 'Earn 50 Stars',
        description: 'Accumulate 50 stars across all levels.',
        target: 50,
        rewardAmount: 300,
        startAtIso: startAtIso,
        endAtIso: endAtIso,
      ),
      WeeklyChallenge(
        id: 'week_dailies_5',
        title: '5 Daily Puzzles',
        description: 'Complete 5 daily challenges this week.',
        target: 5,
        rewardAmount: 350,
        startAtIso: startAtIso,
        endAtIso: endAtIso,
      ),
      WeeklyChallenge(
        id: 'week_par_3',
        title: 'Par Master',
        description: 'Finish 3 levels with 3-star perfect moves.',
        target: 3,
        rewardAmount: 400,
        startAtIso: startAtIso,
        endAtIso: endAtIso,
      ),
    ];
  }

  /// Get current weekly challenges with player progress.
  Future<List<WeeklyChallenge>> getWeeklyChallenges() async {
    final savedMap = await _repository.getWeeklyChallenges();
    final defaults = getDefaultChallenges();

    return defaults.map((def) {
      if (savedMap.containsKey(def.id)) {
        final saved = savedMap[def.id]!;
        return def.copyWith(
          progress: saved.progress,
          isClaimed: saved.isClaimed,
        );
      }
      return def;
    }).toList();
  }

  /// Evaluate and update weekly challenge progress from gameplay stats.
  Future<void> evaluateProgress() async {
    final challenges = await getWeeklyChallenges();
    final allProgress = await _repository.getAllProgress();
    final dailyResults = await _repository.getDailyChallengeResults();

    int totalCompleted = 0;
    int totalStars = 0;
    int threeStarCount = 0;

    allProgress.forEach((_, p) {
      if (p.isCompleted) {
        totalCompleted++;
        totalStars += p.stars;
        if (p.stars == 3) threeStarCount++;
      }
    });

    int completedDailies = dailyResults.values.where((d) => d.isCompleted).length;

    for (final c in challenges) {
      int val = 0;
      switch (c.id) {
        case 'week_levels_20':
          val = totalCompleted;
          break;
        case 'week_stars_50':
          val = totalStars;
          break;
        case 'week_dailies_5':
          val = completedDailies;
          break;
        case 'week_par_3':
          val = threeStarCount;
          break;
      }

      final updatedProgress = val.clamp(0, c.target);
      final updated = c.copyWith(progress: updatedProgress);
      await _repository.saveWeeklyChallenge(updated);
    }
  }

  /// Claim coins reward for a completed weekly challenge.
  Future<int> claimChallengeReward(String challengeId) async {
    final challenges = await getWeeklyChallenges();
    final match = challenges.where((c) => c.id == challengeId);
    if (match.isEmpty) return 0;

    final challenge = match.first;
    if (!challenge.isCompleted || challenge.isClaimed) return 0;

    final ref = 'weekly_claim_$challengeId';
    if (!await _rewardService.hasClaimed(ref)) {
      await _rewardService.grantDailyChallengeReward(ref);
    }

    final updated = challenge.copyWith(isClaimed: true);
    await _repository.saveWeeklyChallenge(updated);

    return challenge.rewardAmount;
  }
}
