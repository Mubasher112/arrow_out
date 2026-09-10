import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/game_engine.dart';
import '../../domain/models/game_status.dart';
import '../../domain/models/level_definition.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../../services/daily_challenge_service.dart';
import '../../services/date_provider.dart';
import '../../services/hint_service.dart';
import '../../services/reward_service.dart';
import '../theme/app_theme.dart';
import '../widgets/arrow_board_widget.dart';
import '../widgets/level_complete_overlay.dart';
import '../widgets/pause_dialog.dart';

class DailyChallengeScreen extends StatefulWidget {
  final GameRepository repository;
  final AudioService audioService;
  final DateProvider? dateProvider;

  const DailyChallengeScreen({
    super.key,
    required this.repository,
    required this.audioService,
    this.dateProvider,
  });

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late GameEngine _engine;
  late DailyChallengeService _dailyService;
  late RewardService _rewardService;
  final HintService _hintService = HintService();

  late LevelDefinition _challengeLevel;
  late String _currentDateIso;
  int _currentStreak = 0;
  int _earnedCoins = 0;
  String? _hintArrowId;
  bool _isInit = false;
  Map<String, DailyChallengeResult> _historyMap = {};

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();
    _dailyService = DailyChallengeService(
      repository: widget.repository,
      dateProvider: widget.dateProvider,
    );
    _rewardService = RewardService(repository: widget.repository);
    _engine.addListener(_onEngineUpdate);
    _loadDailyChallenge();
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdate);
    _engine.dispose();
    super.dispose();
  }

  Future<void> _loadDailyChallenge() async {
    setState(() {
      _isInit = false;
      _hintArrowId = null;
      _earnedCoins = 0;
    });

    _currentDateIso = _dailyService.dateProvider.currentDateIso;
    _challengeLevel = _dailyService.getTodayChallenge();

    final streaks = await _dailyService.calculateStreaks();
    _historyMap = await widget.repository.getDailyChallengeResults();

    _engine.startLevel(_challengeLevel);
    _hintService.resetSession();

    if (mounted) {
      setState(() {
        _currentStreak = streaks['currentStreak'] ?? 0;
        _isInit = true;
      });
    }
  }

  void _onEngineUpdate() {
    if (!mounted) return;

    if (_engine.status == GameStatus.completed && _earnedCoins == 0) {
      _handleDailyCompleted();
    } else {
      setState(() {});
    }
  }

  Future<void> _handleDailyCompleted() async {
    widget.audioService.playSound(SoundType.levelComplete);

    final stars = _challengeLevel.calculateStars(_engine.moves);
    await _dailyService.recordDailyCompletion(
      dateIso: _currentDateIso,
      stars: stars,
      movesTaken: _engine.moves,
    );

    final coinsGranted = await _rewardService.grantDailyChallengeReward(_currentDateIso);
    final streaks = await _dailyService.calculateStreaks();

    if (mounted) {
      setState(() {
        _earnedCoins = coinsGranted;
        _currentStreak = streaks['currentStreak'] ?? 0;
      });
    }
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

  void _onHintTap() {
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

  void _openPauseMenu() {
    _engine.pauseGame();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PauseDialog(
        levelNumber: 1,
        audioService: widget.audioService,
        onResume: () {
          _engine.resumeGame();
        },
        onRestart: () {
          _loadDailyChallenge();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: !_isInit
            ? const Center(child: CircularProgressIndicator())
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
                                const Text(
                                  'DAILY CHALLENGE',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.black,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  _currentDateIso,
                                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withAlpha(200),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.whatshot_rounded, color: AppTheme.goldStar, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_currentStreak',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.black,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 7-Day History View Bar
                      _buildRecentHistoryBar(),

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
                              onPressed: () => _loadDailyChallenge(),
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

                  // Daily Challenge Complete Overlay
                  if (_engine.status == GameStatus.completed)
                    LevelCompleteOverlay(
                      levelNumber: 1,
                      movesTaken: _engine.moves,
                      bestMoves: _engine.moves,
                      starsEarned: _challengeLevel.calculateStars(_engine.moves),
                      isNewBest: _earnedCoins > 0,
                      onNextLevel: () => Navigator.of(context).pop(),
                      onReplay: () => _loadDailyChallenge(),
                      onLevelSelect: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildRecentHistoryBar() {
    final today = _dailyService.dateProvider.now;
    final List<DateTime> recentDates = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: recentDates.map((dt) {
          final iso = DateProvider.dateToIso(dt);
          final res = _historyMap[iso];
          final isCompleted = res?.isCompleted ?? false;
          final isToday = iso == _currentDateIso;

          return Column(
            children: [
              Text(
                '${dt.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? AppTheme.goldStar : Colors.white60,
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: isCompleted ? AppTheme.secondary : Colors.white24,
              ),
            ],
          );
        }).toList(),
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
