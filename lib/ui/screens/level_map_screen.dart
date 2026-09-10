import 'package:flutter/material.dart';
import '../../domain/models/chapter_definition.dart';
import '../../domain/models/level_progress.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/chapter_card_widget.dart';
import 'game_screen.dart';

class LevelMapScreen extends StatefulWidget {
  final GameRepository repository;
  final AudioService audioService;

  const LevelMapScreen({
    super.key,
    required this.repository,
    required this.audioService,
  });

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  Map<int, LevelProgress> _progressMap = {};
  int _highestUnlockedLevel = 1;
  int _selectedChapterId = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    final map = await widget.repository.getAllProgress();
    final curLevel = await widget.repository.getCurrentLevel();

    int highest = curLevel;
    map.forEach((levelNum, p) {
      if (p.isCompleted && levelNum + 1 > highest) {
        highest = levelNum + 1;
      }
    });

    final currentHighest = highest.clamp(1, 500);
    final chapterForCurrent = ChapterDefinition.getChapterForLevel(currentHighest);

    if (mounted) {
      setState(() {
        _progressMap = map;
        _highestUnlockedLevel = currentHighest;
        _selectedChapterId = chapterForCurrent.id;
        _isLoading = false;
      });
    }
  }

  void _onLevelTap(int levelNumber) {
    final isUnlocked = levelNumber <= _highestUnlockedLevel;
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
        .then((_) => _loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    int totalStars = 0;
    _progressMap.forEach((_, p) {
      if (p.isCompleted) totalStars += p.stars;
    });

    final currentChapter = ChapterDefinition.allChapters.firstWhere(
      (c) => c.id == _selectedChapterId,
      orElse: () => ChapterDefinition.allChapters.first,
    );

    int completedInChapter = 0;
    int starsInChapter = 0;
    for (int l = currentChapter.startLevel; l <= currentChapter.endLevel; l++) {
      final p = _progressMap[l];
      if (p != null && p.isCompleted) {
        completedInChapter++;
        starsInChapter += p.stars;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Map', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.goldStar, size: 22),
                const SizedBox(width: 4),
                Text(
                  '$totalStars / 1500',
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
            : Column(
                children: [
                  // Chapter Selection Tabs
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: ChapterDefinition.allChapters.length,
                      itemBuilder: (context, index) {
                        final chapter = ChapterDefinition.allChapters[index];
                        final isSelected = chapter.id == _selectedChapterId;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text('Ch. ${chapter.id}'),
                            selected: isSelected,
                            selectedColor: AppTheme.primary,
                            backgroundColor: AppTheme.bgLight,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                widget.audioService.playSound(SoundType.buttonClick);
                                setState(() {
                                  _selectedChapterId = chapter.id;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Active Chapter Banner Card
                  ChapterCardWidget(
                    chapter: currentChapter,
                    completedInChapter: completedInChapter,
                    starsInChapter: starsInChapter,
                  ),

                  // Winding Grid Path of Levels in Current Chapter
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: currentChapter.endLevel - currentChapter.startLevel + 1,
                      itemBuilder: (context, index) {
                        final levelNumber = currentChapter.startLevel + index;
                        final progress = _progressMap[levelNumber];
                        final isUnlocked = levelNumber <= _highestUnlockedLevel;
                        final isCompleted = progress?.isCompleted ?? false;
                        final stars = progress?.stars ?? 0;
                        final isCurrent = levelNumber == _highestUnlockedLevel;

                        return _buildLevelNode(
                          levelNumber: levelNumber,
                          isUnlocked: isUnlocked,
                          isCompleted: isCompleted,
                          isCurrent: isCurrent,
                          stars: stars,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLevelNode({
    required int levelNumber,
    required bool isUnlocked,
    required bool isCompleted,
    required bool isCurrent,
    required int stars,
  }) {
    final bgColor = isCurrent
        ? AppTheme.goldStar.withAlpha(200)
        : !isUnlocked
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
            color: isCurrent
                ? AppTheme.goldStar
                : isUnlocked
                    ? Colors.white30
                    : Colors.white10,
            width: isCurrent ? 2.5 : 1.5,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: isCurrent
                        ? AppTheme.goldStar.withAlpha(100)
                        : Colors.black.withAlpha(60),
                    blurRadius: isCurrent ? 10 : 6,
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
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (starIdx) {
                  final filled = starIdx < stars;
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 14,
                    color: filled
                        ? (isCurrent ? Colors.black87 : AppTheme.goldStar)
                        : (isCurrent ? Colors.black38 : Colors.white38),
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
