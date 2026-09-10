import 'package:flutter/material.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../../services/daily_challenge_service.dart';
import '../../services/progression_service.dart';
import '../theme/app_theme.dart';
import '../widgets/settings_dialog.dart';
import 'achievements_screen.dart';
import 'daily_challenge_screen.dart';
import 'game_screen.dart';
import 'level_map_screen.dart';

class HomeScreen extends StatefulWidget {
  final GameRepository repository;
  final AudioService audioService;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.audioService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProgressionService _progressionService;
  late DailyChallengeService _dailyService;

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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Top Bar with Stars Badge, Coins Counter, and Settings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.goldStar.withAlpha(100)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: AppTheme.goldStar, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_totalStars',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.goldStar.withAlpha(100)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.monetization_on_rounded, color: AppTheme.goldStar, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_coins',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                          onPressed: _openSettings,
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Title Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          const Icon(Icons.navigation_rounded, size: 60, color: Colors.white),
                          const SizedBox(height: 8),
                          const Text(
                            'ARROW PATH',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.black,
                              letterSpacing: 2.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '500 Extraction Puzzles',
                            style: TextStyle(
                              fontSize: 13,
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
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.bgLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accent.withAlpha(150), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.today_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAlignment.start,
                                children: [
                                  Text(
                                    'DAILY CHALLENGE',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Today\'s Special Puzzle',
                                    style: TextStyle(fontSize: 12, color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.whatshot_rounded, color: AppTheme.goldStar, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_streak Day',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Play / Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 32),
                        label: Text(
                          'CONTINUE LEVEL $_currentLevel',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        onPressed: _playCurrentLevel,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Navigation Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: AppTheme.secondary, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.map_rounded, color: AppTheme.secondary, size: 20),
                              label: const Text(
                                'LEVEL MAP',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              onPressed: _openLevelMap,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: AppTheme.goldStar, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.military_tech_rounded, color: AppTheme.goldStar, size: 20),
                              label: const Text(
                                'ACHIEVEMENTS',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              onPressed: _openAchievements,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }
}
