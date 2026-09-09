import 'package:flutter/material.dart';
import '../../domain/models/level_progress.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  final GameRepository repository;
  final AudioService audioService;

  const LevelSelectScreen({
    super.key,
    required this.repository,
    required this.audioService,
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  Map<int, LevelProgress> _progressMap = {};
  int _currentHighestUnlocked = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);
    final map = await widget.repository.getAllProgress();
    final curLevel = await widget.repository.getCurrentLevel();

    int highest = curLevel;
    map.forEach((levelNum, p) {
      if (p.isCompleted && levelNum + 1 > highest) {
        highest = levelNum + 1;
      }
    });

    if (mounted) {
      setState(() {
        _progressMap = map;
        _currentHighestUnlocked = highest.clamp(1, 100);
        _isLoading = false;
      });
    }
  }

  void _onLevelTap(int levelNumber) {
    final isUnlocked = levelNumber <= _currentHighestUnlocked;
    if (!isUnlocked) {
      widget.audioService.playSound(SoundType.blocked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete Level ${levelNumber - 1} to unlock!'),
          duration: const Duration(milliseconds: 1200),
          backgroundColor: AppTheme.cardBg,
        ),
      );
      return;
    }

    widget.audioService.playSound(SoundType.buttonClick);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          levelNumber: levelNumber,
          repository: widget.repository,
          audioService: widget.audioService,
        ),
      ),
    )
        .then((_) => _loadProgressData());
  }

  @override
  Widget build(BuildContext context) {
    int totalStars = 0;
    _progressMap.forEach((_, p) {
      if (p.isCompleted) totalStars += p.stars;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Level',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.goldStar, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$totalStars',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid columns
                  final crossAxisCount = constraints.maxWidth > 600 ? 6 : 4;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      final levelNumber = index + 1;
                      final progress = _progressMap[levelNumber];
                      final isUnlocked = levelNumber <= _currentHighestUnlocked;
                      final isCompleted = progress?.isCompleted ?? false;
                      final stars = progress?.stars ?? 0;

                      return _buildLevelCard(
                        levelNumber: levelNumber,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        stars: stars,
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildLevelCard({
    required int levelNumber,
    required bool isUnlocked,
    required bool isCompleted,
    required int stars,
  }) {
    final bgColor = !isUnlocked
        ? AppTheme.bgLight.withAlpha(120)
        : isCompleted
            ? AppTheme.primary.withAlpha(180)
            : AppTheme.secondary.withAlpha(200);

    return InkWell(
      onTap: () => _onLevelTap(levelNumber),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? Colors.white30 : Colors.white10,
            width: 1.5,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              const Icon(Icons.lock_rounded, color: Colors.white38, size: 28)
            else ...[
              Text(
                '$levelNumber',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (starIdx) {
                  final filled = starIdx < stars;
                  return Icon(
                    filled ? Icons.star : Icons.star_border,
                    size: 14,
                    color: filled ? AppTheme.goldStar : Colors.white38,
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
