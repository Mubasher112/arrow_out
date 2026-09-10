import 'package:flutter/material.dart';
import '../../domain/models/achievement.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/achievement_service.dart';
import '../../services/audio_service.dart';
import '../../services/reward_service.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends StatefulWidget {
  final GameRepository repository;
  final AudioService audioService;

  const AchievementsScreen({
    super.key,
    required this.repository,
    required this.audioService,
  });

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late AchievementService _achievementService;
  List<Achievement> _achievements = [];
  int _coins = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final rewardService = RewardService(repository: widget.repository);
    _achievementService = AchievementService(
      repository: widget.repository,
      rewardService: rewardService,
    );
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);
    await _achievementService.evaluateAchievements();
    final list = await _achievementService.getAllAchievements();
    final coins = await widget.repository.getCoinsBalance();

    if (mounted) {
      setState(() {
        _achievements = list;
        _coins = coins;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded, color: AppTheme.goldStar, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_coins',
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
                  // Progress Banner Header
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Unlocked Achievements',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$unlockedCount / ${_achievements.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.black,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Achievements List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _achievements.length,
                      itemBuilder: (context, index) {
                        final a = _achievements[index];
                        return _buildAchievementCard(a);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement a) {
    final progressRatio = (a.progress / a.target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: a.isUnlocked ? AppTheme.primary.withAlpha(160) : AppTheme.bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: a.isUnlocked ? AppTheme.goldStar : Colors.white10,
          width: a.isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: a.isUnlocked ? AppTheme.goldStar : Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              a.isUnlocked ? Icons.military_tech_rounded : Icons.lock_rounded,
              color: a.isUnlocked ? Colors.black : Colors.white38,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Text(
                  a.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  a.description,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 6,
                          backgroundColor: Colors.black26,
                          color: a.isUnlocked ? AppTheme.goldStar : AppTheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${a.progress} / ${a.target}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded, color: AppTheme.goldStar, size: 14),
                const SizedBox(width: 2),
                Text(
                  '+${a.coinReward}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
