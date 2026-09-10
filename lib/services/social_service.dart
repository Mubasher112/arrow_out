import '../data/repositories/social_repository.dart';
import '../domain/models/account_model.dart';
import '../domain/models/player_social_profile.dart';
import '../domain/repositories/game_repository.dart';
import 'auth_service.dart';
import 'friends_service.dart';
import 'leaderboard_service.dart';
import 'progression_service.dart';

/// Central social service facade handling social profile syncs and guest auth checks.
class SocialService {
  final SocialRepository _socialRepository;
  final GameRepository _gameRepository;
  final AuthService _authService;
  final LeaderboardService leaderboardService;
  final FriendsService friendsService;

  SocialService({
    required SocialRepository socialRepository,
    required GameRepository gameRepository,
    required AuthService authService,
  })  : _socialRepository = socialRepository,
        _gameRepository = gameRepository,
        _authService = authService,
        leaderboardService = LeaderboardService(socialRepository: socialRepository),
        friendsService = FriendsService(socialRepository: socialRepository);

  /// Check if user is authenticated (social features require an account).
  bool get isSocialEnabled {
    final account = _authService.currentAccount;
    return account != null && !account.isGuest;
  }

  /// Synchronize public social profile with latest local progress.
  Future<void> syncPublicProfile() async {
    final account = _authService.currentAccount;
    if (account == null || account.isGuest) return;

    final progService = ProgressionService(repository: _gameRepository);
    final totalStars = await progService.getTotalStars();
    final allProgress = await _gameRepository.getAllProgress();
    final achievementsMap = await _gameRepository.getAchievements();

    int completed = 0;
    allProgress.forEach((_, p) {
      if (p.isCompleted) completed++;
    });

    int unlockedAchievements = achievementsMap.values.where((a) => a.isUnlocked).length;

    final profile = PlayerSocialProfile(
      playerId: account.userId,
      displayName: account.displayName,
      avatarUrl: account.photoUrl,
      totalStars: totalStars,
      completedLevels: completed,
      unlockedAchievements: unlockedAchievements,
      createdAt: account.createdAt,
    );

    await _socialRepository.updateProfile(profile);
  }
}
