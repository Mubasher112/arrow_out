import 'package:flutter/material.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../../services/progression_service.dart';
import '../theme/app_theme.dart';
import '../widgets/settings_dialog.dart';
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
  int _currentLevel = 1;
  int _totalStars = 0;
  int _completedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _progressionService = ProgressionService(repository: widget.repository);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    final cur = await widget.repository.getCurrentLevel();
    final allProgress = await widget.repository.getAllProgress();
    final stars = await _progressionService.getTotalStars();

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
                    // Top Bar with Stars Badge and Settings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.bgLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.goldStar.withAlpha(100)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppTheme.goldStar, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                '$_totalStars / 1500',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withAlpha(200),
                            AppTheme.secondary.withAlpha(200),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withAlpha(80),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.navigation_rounded,
                            size: 72,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'ARROW PATH',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.black,
                              letterSpacing: 2.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '500 Extraction Puzzles',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withAlpha(200),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Stats Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('Current Level', '$_currentLevel / 500'),
                          Container(width: 1, height: 30, color: Colors.white24),
                          _buildStatColumn('Completed', '$_completedCount'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Play / Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 36),
                        label: Text(
                          'CONTINUE LEVEL $_currentLevel',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        onPressed: _playCurrentLevel,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Level Map Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: AppTheme.secondary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.map_rounded, color: AppTheme.secondary),
                        label: const Text(
                          'LEVEL MAP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        onPressed: _openLevelMap,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
