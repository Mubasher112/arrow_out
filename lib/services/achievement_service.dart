import '../domain/models/achievement.dart';
import '../domain/repositories/game_repository.dart';
import 'reward_service.dart';

/// Service managing achievement evaluations, progress tracking, and unlocks.
class AchievementService {
  final GameRepository _repository;
  final RewardService _rewardService;

  static const List<Achievement> defaultAchievements = [
    Achievement(
      id: 'first_move',
      title: 'First Move',
      description: 'Make your first successful arrow move.',
      iconName: 'navigation',
      target: 1,
      coinReward: 25,
    ),
    Achievement(
      id: 'first_victory',
      title: 'First Victory',
      description: 'Complete your first level.',
      iconName: 'emoji_events',
      target: 1,
      coinReward: 50,
    ),
    Achievement(
      id: 'star_collector',
      title: 'Star Collector',
      description: 'Earn a total of 10 stars.',
      iconName: 'star',
      target: 10,
      coinReward: 50,
    ),
    Achievement(
      id: 'star_master',
      title: 'Star Master',
      description: 'Earn a total of 50 stars.',
      iconName: 'stars',
      target: 50,
      coinReward: 100,
    ),
    Achievement(
      id: 'puzzle_fan',
      title: 'Puzzle Fan',
      description: 'Complete 25 levels.',
      iconName: 'grid_view',
      target: 25,
      coinReward: 75,
    ),
    Achievement(
      id: 'puzzle_expert',
      title: 'Puzzle Expert',
      description: 'Complete 100 levels.',
      iconName: 'workspace_premium',
      target: 100,
      coinReward: 150,
    ),
    Achievement(
      id: 'puzzle_master',
      title: 'Puzzle Master',
      description: 'Complete 500 levels.',
      iconName: 'military_tech',
      target: 500,
      coinReward: 300,
    ),
    Achievement(
      id: 'daily_player',
      title: 'Daily Player',
      description: 'Complete 3 daily challenges.',
      iconName: 'today',
      target: 3,
      coinReward: 75,
    ),
    Achievement(
      id: 'weekly_warrior',
      title: 'Weekly Warrior',
      description: 'Reach a 7-day streak.',
      iconName: 'whatshot',
      target: 7,
      coinReward: 150,
    ),
    Achievement(
      id: 'dedicated',
      title: 'Dedicated',
      description: 'Reach a 30-day streak.',
      iconName: 'local_fire_department',
      target: 30,
      coinReward: 500,
    ),
    Achievement(
      id: 'perfectionist',
      title: 'Perfectionist',
      description: 'Earn 3 stars on 25 levels.',
      iconName: 'verified',
      target: 25,
      coinReward: 100,
    ),
  ];

  AchievementService({
    required GameRepository repository,
    required RewardService rewardService,
  })  : _repository = repository,
        _rewardService = rewardService;

  /// Get all achievements with current saved progress.
  Future<List<Achievement>> getAllAchievements() async {
    final savedMap = await _repository.getAchievements();

    return defaultAchievements.map((def) {
      if (savedMap.containsKey(def.id)) {
        final saved = savedMap[def.id]!;
        return def.copyWith(
          progress: saved.progress,
          isUnlocked: saved.isUnlocked,
          unlockedAt: saved.unlockedAt,
        );
      }
      return def;
    }).toList();
  }

  /// Evaluate progress stats and unlock newly eligible achievements.
  /// Returns list of newly unlocked achievements for UI toast notifications.
  Future<List<Achievement>> evaluateAchievements() async {
    final achievements = await getAllAchievements();
    final allProgress = await _repository.getAllProgress();
    final dailyResults = await _repository.getDailyChallengeResults();
    final longestStreak = await _repository.getLongestStreak();

    int totalCompleted = 0;
    int totalStars = 0;
    int threeStarCount = 0;

    allProgress.forEach((_, p) {
      if (p.isCompleted) {
        totalCompleted++;
        totalStars += p.stars;
        if (p.stars == 3) {
          threeStarCount++;
        }
      }
    });

    int completedDailies = dailyResults.values.where((d) => d.isCompleted).length;

    final List<Achievement> newlyUnlocked = [];

    for (var a in achievements) {
      if (a.isUnlocked) continue;

      int currentVal = 0;
      switch (a.id) {
        case 'first_move':
          currentVal = (totalCompleted > 0 || completedDailies > 0) ? 1 : 0;
          break;
        case 'first_victory':
          currentVal = totalCompleted > 0 ? 1 : 0;
          break;
        case 'star_collector':
        case 'star_master':
          currentVal = totalStars;
          break;
        case 'puzzle_fan':
        case 'puzzle_expert':
        case 'puzzle_master':
          currentVal = totalCompleted;
          break;
        case 'daily_player':
          currentVal = completedDailies;
          break;
        case 'weekly_warrior':
        case 'dedicated':
          currentVal = longestStreak;
          break;
        case 'perfectionist':
          currentVal = threeStarCount;
          break;
      }

      final updatedProgress = currentVal.clamp(0, a.target);
      final shouldUnlock = currentVal >= a.target;

      if (shouldUnlock || updatedProgress != a.progress) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final updated = a.copyWith(
          progress: updatedProgress,
          isUnlocked: shouldUnlock,
          unlockedAt: shouldUnlock ? now : a.unlockedAt,
        );

        await _repository.saveAchievement(updated);

        if (shouldUnlock) {
          newlyUnlocked.add(updated);
          // Grant coin reward for achievement
          final ref = 'achievement_${a.id}';
          if (!await _rewardService.hasClaimed(ref)) {
            await _rewardService.grantDailyChallengeReward(ref); // reuse claim logic
          }
        }
      }
    }

    return newlyUnlocked;
  }
}
