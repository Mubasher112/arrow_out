import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/game_engine.dart';
import '../../domain/models/game_status.dart';
import '../../domain/models/level_definition.dart';
import '../../domain/models/level_progress.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../../services/level_loader_service.dart';
import '../theme/app_theme.dart';
import '../widgets/arrow_board_widget.dart';
import '../widgets/level_complete_overlay.dart';
import '../widgets/pause_dialog.dart';

class GameScreen extends StatefulWidget {
  final int levelNumber;
  final GameRepository repository;
  final AudioService audioService;

  const GameScreen({
    super.key,
    required this.levelNumber,
    required this.repository,
    required this.audioService,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameEngine _engine;
  final LevelLoaderService _levelLoader = LevelLoaderService();
  int _currentLevelNum = 1;
  String? _hintArrowId;
  bool _isInit = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentLevelNum = widget.levelNumber;
    _engine = GameEngine();
    _engine.addListener(_onEngineUpdate);
    _loadLevel(_currentLevelNum);
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdate);
    _engine.dispose();
    super.dispose();
  }

  Future<void> _loadLevel(int levelNum) async {
    setState(() {
      _isInit = false;
      _hintArrowId = null;
      _errorMessage = null;
    });

    try {
      final levelDef = await _levelLoader.loadLevel(levelNum);
      _engine.startLevel(levelDef);

      if (mounted) {
        setState(() => _isInit = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInit = true;
          _errorMessage = 'Failed to load level $levelNum. Please try again.';
        });
      }
    }
  }

  void _onEngineUpdate() {
    if (!mounted) return;

    if (_engine.status == GameStatus.completed) {
      _handleLevelCompleted();
    } else {
      setState(() {});
    }
  }

  Future<void> _handleLevelCompleted() async {
    widget.audioService.playSound(SoundType.levelComplete);

    final level = _engine.currentLevel;
    if (level == null) return;

    final moves = _engine.moves;
    final stars = level.calculateStars(moves);

    final progress = LevelProgress(
      levelNumber: level.levelNumber,
      isCompleted: true,
      stars: stars,
      bestMoves: moves,
    );

    await widget.repository.saveLevelProgress(progress);

    // Save current level + 1 as highest unlocked
    final curHighest = await widget.repository.getCurrentLevel();
    if (level.levelNumber >= curHighest && level.levelNumber < 100) {
      await widget.repository.setCurrentLevel(level.levelNumber + 1);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onArrowTap(String arrowId) {
    if (_engine.status != GameStatus.playing) return;

    setState(() => _hintArrowId = null); // Clear hint on interaction

    final result = _engine.moveArrow(arrowId);

    if (result.isValid) {
      widget.audioService.playSound(SoundType.arrowExit);
    } else {
      widget.audioService.playSound(SoundType.blocked);
      // Reset blocked state after shake animation
      Timer(const Duration(milliseconds: 350), () {
        _engine.resetBlockedState(arrowId);
      });
    }
  }

  void _onUndoTap() {
    if (_engine.canUndo) {
      widget.audioService.playSound(SoundType.buttonClick);
      setState(() => _hintArrowId = null);
      _engine.undo();
    }
  }

  void _onHintTap() {
    final hintArrow = _engine.getHint();
    if (hintArrow != null) {
      widget.audioService.playSound(SoundType.buttonClick);
      setState(() {
        _hintArrowId = hintArrow.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hint: Highlighted arrow is ready to exit!'),
          duration: Duration(seconds: 2),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  void _onRestartTap() {
    widget.audioService.playSound(SoundType.buttonClick);
    _loadLevel(_currentLevelNum);
  }

  void _openPauseMenu() {
    _engine.pauseGame();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PauseDialog(
        levelNumber: _currentLevelNum,
        audioService: widget.audioService,
        onResume: () {
          _engine.resumeGame();
        },
        onRestart: () {
          _loadLevel(_currentLevelNum);
        },
        onLevelSelect: () {
          Navigator.of(context).pop();
        },
      ),
    ).then((_) {
      if (_engine.status == GameStatus.paused) {
        _engine.resumeGame();
      }
      setState(() {});
    });
  }

  void _nextLevel() {
    if (_currentLevelNum < 100) {
      setState(() {
        _currentLevelNum++;
      });
      _loadLevel(_currentLevelNum);
    } else {
      // Final Level 100 completed!
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.bgLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Congratulations!', style: TextStyle(color: Colors.white)),
          content: const Text(
            'You have successfully cleared all 100 levels!',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Level Select'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = _engine.currentLevel;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.audioService.playSound(SoundType.buttonClick);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: !_isInit
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorView()
                  : Stack(
                      children: [
                        Column(
                          children: [
                            // Header Bar
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'LEVEL $_currentLevelNum',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Moves: ${_engine.moves}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.pause_circle_filled_rounded,
                                        color: Colors.white, size: 32),
                                    onPressed: _openPauseMenu,
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Interactive Board Area
                            Expanded(
                              flex: 8,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: ArrowBoardWidget(
                                  board: _engine.board!,
                                  hintArrowId: _hintArrowId,
                                  onArrowTap: _onArrowTap,
                                  onArrowExitComplete: (arrowId) {
                                    _engine.completeArrowExit(arrowId);
                                  },
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Bottom Action Controls
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildActionButton(
                                    icon: Icons.refresh_rounded,
                                    label: 'Restart',
                                    onPressed: _onRestartTap,
                                    color: AppTheme.cardBg,
                                  ),
                                  _buildActionButton(
                                    icon: Icons.undo_rounded,
                                    label: 'Undo',
                                    onPressed: _engine.canUndo ? _onUndoTap : null,
                                    color: AppTheme.cardBg,
                                  ),
                                  _buildActionButton(
                                    icon: Icons.lightbulb_rounded,
                                    label: 'Hint',
                                    onPressed: _onHintTap,
                                    color: AppTheme.goldStar.withAlpha(200),
                                    iconColor: Colors.black,
                                    textColor: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Level Completed Dialog Overlay
                        if (_engine.status == GameStatus.completed)
                          LevelCompleteOverlay(
                            levelNumber: _currentLevelNum,
                            movesTaken: _engine.moves,
                            starsEarned: level?.calculateStars(_engine.moves) ?? 3,
                            onNextLevel: _nextLevel,
                            onReplay: () => _loadLevel(_currentLevelNum),
                            onLevelSelect: () => Navigator.of(context).pop(),
                          ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.accent),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  onPressed: () => _loadLevel(_currentLevelNum),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('Level Select'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
  }) {
    final bool enabled = onPressed != null;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : color.withAlpha(80),
        foregroundColor: enabled ? iconColor : Colors.white38,
        elevation: enabled ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: enabled ? Colors.white24 : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: Icon(icon, size: 20, color: enabled ? iconColor : Colors.white38),
      label: Text(
        label,
        style: TextStyle(
          color: enabled ? textColor : Colors.white38,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
