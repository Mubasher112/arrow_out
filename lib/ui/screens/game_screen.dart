import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/game_engine.dart';
import '../../domain/models/ad_placement.dart';
import '../../domain/models/game_status.dart';
import '../../domain/models/level_definition.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../../services/hint_service.dart';
import '../../services/level_loader_service.dart';
import '../../services/monetization_service.dart';
import '../../services/progression_service.dart';
import '../../services/reward_service.dart';
import '../../services/star_rating_service.dart';
import '../../services/tutorial_service.dart';
import '../theme/app_theme.dart';
import '../widgets/arrow_board_widget.dart';
import '../widgets/level_complete_overlay.dart';
import '../widgets/pause_dialog.dart';

class GameScreen extends StatefulWidget {
  final int levelNumber;
  final GameRepository repository;
  final AudioService audioService;
  final MonetizationService? monetizationService;

  const GameScreen({
    super.key,
    required this.levelNumber,
    required this.repository,
    required this.audioService,
    this.monetizationService,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameEngine _engine;
  late ProgressionService _progressionService;
  late RewardService _rewardService;
  final LevelLoaderService _levelLoader = LevelLoaderService();
  final HintService _hintService = HintService();

  int _currentLevelNum = 1;
  String? _hintArrowId;
  bool _isInit = false;
  String? _errorMessage;

  ScoreEvaluation? _lastCompletionEval;
  int _previousBestMoves = 0;

  @override
  void initState() {
    super.initState();
    _currentLevelNum = widget.levelNumber;
    _engine = GameEngine();
    _progressionService = ProgressionService(repository: widget.repository);
    _rewardService = RewardService(repository: widget.repository);
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
      _lastCompletionEval = null;
    });

    try {
      final existingProgress = await widget.repository.getLevelProgress(levelNum);
      _previousBestMoves = existingProgress?.bestMoves ?? 0;

      final levelDef = await _levelLoader.loadLevel(levelNum);
      _engine.startLevel(levelDef);
      _hintService.resetSession();

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

    if (_engine.status == GameStatus.completed && _lastCompletionEval == null) {
      _handleLevelCompleted();
    } else {
      setState(() {});
    }
  }

  Future<void> _handleLevelCompleted() async {
    widget.audioService.playSound(SoundType.levelComplete);

    final level = _engine.currentLevel;
    if (level == null) return;

    final eval = await _progressionService.recordLevelCompletion(
      level: level,
      movesTaken: _engine.moves,
    );

    await _rewardService.grantLevelRewards(
      levelNumber: level.levelNumber,
      stars: eval.stars,
    );

    if (mounted) {
      setState(() {
        _lastCompletionEval = eval;
      });
    }

    // Interstitial Ad Trigger
    widget.monetizationService?.maybeShowInterstitial(AdPlacement.interstitialLevelComplete);
  }

  void _onArrowTap(String arrowId) {
    if (_engine.status != GameStatus.playing) return;

    setState(() => _hintArrowId = null);

    final result = _engine.moveArrow(arrowId);

    if (result.isValid) {
      widget.audioService.playSound(SoundType.arrowExit);
    } else {
      widget.audioService.playSound(SoundType.blocked);
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

  void _triggerHint() {
    final hintRes = _hintService.getHint(_engine);
    if (hintRes.hasAvailableHint && hintRes.recommendedArrow != null) {
      widget.audioService.playSound(SoundType.buttonClick);
      setState(() {
        _hintArrowId = hintRes.recommendedArrow!.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hintRes.message!),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  void _onHintTap() {
    if (_hintService.hintsUsedInSession >= 2 && widget.monetizationService != null) {
      // Offer Rewarded Video or Coins options
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.bgLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Need a Hint?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Watch a short video or spend coins to reveal the next unblocked arrow move.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text('Watch Video (Free)', style: TextStyle(color: AppTheme.goldStar)),
              onPressed: () async {
                Navigator.of(ctx).pop();
                final success = await widget.monetizationService!.showRewardedAd(
                  placement: AdPlacement.rewardedHint,
                  onRewardEarned: () async {
                    _triggerHint();
                  },
                );
                if (!success) {
                  _triggerHint(); // Fallback
                }
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Use Free Hint'),
              onPressed: () {
                Navigator.of(ctx).pop();
                _triggerHint();
              },
            ),
          ],
        ),
      );
    } else {
      _triggerHint();
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
        monetizationService: widget.monetizationService,
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
    if (_currentLevelNum < 500) {
      setState(() {
        _currentLevelNum++;
      });
      _loadLevel(_currentLevelNum);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.bgLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Congratulations!', style: TextStyle(color: Colors.white)),
          content: const Text(
            'You have successfully cleared all 500 levels!',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Level Map'),
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
    final tutorialMsg = TutorialService.getTutorialMessage(_currentLevelNum);

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

                            // Tutorial Banner if applicable
                            if (tutorialMsg != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withAlpha(200),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.secondary),
                                ),
                                child: Text(
                                  tutorialMsg,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
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

                        // Level Completed Overlay
                        if (_engine.status == GameStatus.completed)
                          LevelCompleteOverlay(
                            levelNumber: _currentLevelNum,
                            movesTaken: _engine.moves,
                            bestMoves: _previousBestMoves > 0 && _previousBestMoves < _engine.moves
                                ? _previousBestMoves
                                : _engine.moves,
                            starsEarned: _lastCompletionEval?.stars ??
                                (level?.calculateStars(_engine.moves) ?? 3),
                            isNewBest: _lastCompletionEval?.isNewBest ?? true,
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
                  label: const Text('Level Map'),
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
