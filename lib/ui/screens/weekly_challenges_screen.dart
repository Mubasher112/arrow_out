import 'package:flutter/material.dart';
import '../../domain/models/weekly_challenge.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../../services/reward_service.dart';
import '../../services/weekly_challenge_service.dart';
import '../theme/app_theme.dart';

class WeeklyChallengesScreen extends StatefulWidget {
  final GameRepository repository;
  final AudioService audioService;

  const WeeklyChallengesScreen({
    super.key,
    required this.repository,
    required this.audioService,
  });

  @override
  State<WeeklyChallengesScreen> createState() => _WeeklyChallengesScreenState();
}

class _WeeklyChallengesScreenState extends State<WeeklyChallengesScreen> {
  late WeeklyChallengeService _weeklyService;
  List<WeeklyChallenge> _challenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final rewardService = RewardService(repository: widget.repository);
    _weeklyService = WeeklyChallengeService(
      repository: widget.repository,
      rewardService: rewardService,
    );
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);
    await _weeklyService.evaluateProgress();
    final list = await _weeklyService.getWeeklyChallenges();

    if (mounted) {
      setState(() {
        _challenges = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _claimReward(String challengeId) async {
    widget.audioService.playSound(SoundType.levelComplete);
    final reward = await _weeklyService.claimChallengeReward(challengeId);
    if (mounted && reward > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+$reward Coins Claimed!'),
          backgroundColor: AppTheme.primary,
        ),
      );
      await _loadChallenges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Challenges', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Countdown Header Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.secondary.withAlpha(100)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer_rounded, color: AppTheme.secondary, size: 24),
                            SizedBox(width: 8),
                            Text('Ends in: 3d 8h', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        Text('Resets Sunday 00:00 UTC', style: TextStyle(fontSize: 11, color: Colors.white60)),
                      ],
                    ),
                  ),

                  // Challenges List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _challenges.length,
                      itemBuilder: (context, index) {
                        final c = _challenges[index];
                        return _buildChallengeCard(c);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildChallengeCard(WeeklyChallenge c) {
    final progressRatio = (c.progress / c.target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.isClaimed ? AppTheme.bgDark : AppTheme.bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: c.isCompleted ? AppTheme.goldStar : Colors.white10,
          width: c.isCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                c.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: AppTheme.goldStar, size: 14),
                    const SizedBox(width: 2),
                    Text('+${c.rewardAmount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(c.description, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    minHeight: 8,
                    backgroundColor: Colors.black26,
                    color: c.isCompleted ? AppTheme.goldStar : AppTheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${c.progress} / ${c.target}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
            ],
          ),
          if (c.isCompleted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.isClaimed ? AppTheme.cardBg : AppTheme.goldStar,
                  foregroundColor: c.isClaimed ? Colors.white38 : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(c.isClaimed ? Icons.check_rounded : Icons.card_giftcard_rounded, size: 18),
                label: Text(c.isClaimed ? 'CLAIMED' : 'CLAIM ${c.rewardAmount} COINS', style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: c.isClaimed ? null : () => _claimReward(c.id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
