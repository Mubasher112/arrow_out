import 'package:flutter/material.dart';
import '../../data/repositories/cloud_game_repository.dart';
import '../../data/repositories/in_memory_social_repository.dart';
import '../../data/repositories/social_repository.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../../services/auth_service.dart';
import '../../services/daily_challenge_service.dart';
import '../../services/mock_auth_service.dart';
import '../../services/progression_service.dart';
import '../../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../widgets/settings_dialog.dart';
import 'achievements_screen.dart';
import 'daily_challenge_screen.dart';
import 'friends_screen.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'level_map_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final GameRepository repository;
  final AudioService audioService;
  final AuthService? authService;
  final SyncService? syncService;
  final SocialRepository? socialRepository;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.audioService,
    this.authService,
    this.syncService,
    this.socialRepository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProgressionService _progressionService;
  late DailyChallengeService _dailyService;
  late AuthService _authService;
  late SyncService _syncService;
  late SocialRepository _socialRepository;

  int _currentLevel = 1;
  int _totalStars = 0;
  int _completedCount = 0;
  int _coins = 0;
  int _streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _progressionService = ProgressionService(repository: widget.repository);
    _dailyService = DailyChallengeService(repository: widget.repository);
    _authService = widget.authService ?? MockAuthService();
    _socialRepository = widget.socialRepository ?? InMemorySocialRepository();
    _syncService = widget.syncService ??
        SyncService(
          localRepository: widget.repository,
          cloudRepository: InMemoryCloudRepository(),
          authService: _authService,
        );
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    final cur = await widget.repository.getCurrentLevel();
    final allProgress = await widget.repository.getAllProgress();
    final stars = await _progressionService.getTotalStars();
    final coins = await widget.repository.getCoinsBalance();
    final streakData = await _dailyService.calculateStreaks();

    int completed = 0;
    allProgress.forEach((_, p) {
      if (p.isCompleted) {
        completed++;
      }
    });

    if (mounted) {
      setState(() {
        _currentLevel = cur.clamp(1, 500);
        _totalStars = stars;
        _coins = coins;
        _streak = streakData['currentStreak'] ?? 0;
        _completedCount = completed;
        _isLoading = false;
      });
    }
  }

  void _playCurrentLevel() {
    widget.audioService.playSound(SoundType.buttonClick);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          levelNumber: _currentLevel,
          repository: widget.repository,
          audioService: widget.audioService,
        ),
      ),
    )
        .then((_) => _loadProgress());
  }

  void _openDailyChallenge() {
    widget.audioService.playSound(SoundType.buttonClick);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => DailyChallengeScreen(
          repository: widget.repository,
          audioService: widget.audioService,
        ),
      ),
    )
        .then((_) => _loadProgress());
  }

  void _openLevelMap() {
    widget.audioService.playSound(SoundType.buttonClick);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => LevelMapScreen(
          repository: widget.repository,
          audioService: widget.audioService,
        ),
      ),
    )
        .then((_) => _loadProgress());
  }

  void _openAchievements() {
    widget.audioService.playSound(SoundType.buttonClick);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => AchievementsScreen(
          repository: widget.repository,
          audioService: widget.audioService,
        ),
      ),
    )
        .then((_) => _loadProgress());
  }

  void _openLeaderboard() {
    widget.audioService.playSound(SoundType.buttonClick);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => LeaderboardScreen(
          socialRepository: _socialRepository,
          authService: _authService,
          audioService: widget.audioService,
        ),
      ),
    )
        .then((_) => _loadProgress());
  }

  void _openFriends() {
    widget.audioService.playSound(SoundType.buttonClick);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => FriendsScreen(
          socialRepository: _socialRepository,
          authService: _authService,
          audioService: widget.audioService,
        ),
      ),
    )
        .then((_) => _loadProgress());
  }

  void _openProfile() {
    widget.audioService.playSound(SoundType.buttonClick);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          repository: widget.repository,
          authService: _authService,
          syncService: _syncService,
          audioService: widget.audioService,
        ),
      ),
    )
        .then((_) => _loadProgress());
  }

  void _openSettings() {
    widget.audioService.playSound(SoundType.buttonClick);
    showDialog(
      context: context,
      builder: (_) => SettingsDialog(
        audioService: widget.audioService,
        repository: widget.repository,
        onDataReset: _loadProgress,
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.goldStar.withAlpha(100)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: AppTheme.goldStar, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_totalStars',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.goldStar.withAlpha(100)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.monetization_on_rounded, color: AppTheme.goldStar, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_coins',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.account_circle_rounded, color: Colors.white, size: 28),
                              onPressed: _openProfile,
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                              onPressed: _openSettings,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Title Header Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withAlpha(200),
                            AppTheme.secondary.withAlpha(200),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withAlpha(80),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.navigation_rounded, size: 54, color: Colors.white),
                          const SizedBox(height: 6),
                          const Text(
                            'ARROW PATH',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.black,
                              letterSpacing: 2.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '500 Extraction Puzzles',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(200),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Daily Challenge Quick Card
                    InkWell(
                      onTap: _openDailyChallenge,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accent.withAlpha(150), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.today_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAlignment: CrossAlignment.start,
                                children: [
                                  Text(
                                    'DAILY CHALLENGE',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Text('Today\'s Special Puzzle', style: TextStyle(fontSize: 11, color: Colors.white60)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                children: [
                                  const Icon(Icons.whatshot_rounded, color: AppTheme.goldStar, size: 16),
                                  const SizedBox(width: 4),
                                  Text('$_streak Day', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Play / Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 30),
                        label: Text(
                          'CONTINUE LEVEL $_currentLevel',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                        onPressed: _playCurrentLevel,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Navigation Actions Row 1
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: AppTheme.secondary, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.map_rounded, color: AppTheme.secondary, size: 18),
                              label: const Text('MAP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: _openLevelMap,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: AppTheme.goldStar, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.military_tech_rounded, color: AppTheme.goldStar, size: 18),
                              label: const Text('BADGES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: _openAchievements,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Navigation Actions Row 2 (Social)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: AppTheme.primaryLight, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.leaderboard_rounded, color: AppTheme.primaryLight, size: 18),
                              label: const Text('RANKS 🏆', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: _openLeaderboard,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: AppTheme.secondary, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.people_alt_rounded, color: AppTheme.secondary, size: 18),
                              label: const Text('FRIENDS 👥', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: _openFriends,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
      ),
    );
  }
}
