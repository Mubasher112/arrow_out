import 'package:flutter/material.dart';
import '../../domain/models/account_model.dart';
import '../../domain/models/player_level.dart';
import '../../domain/models/sync_status.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/achievement_service.dart';
import '../../services/audio_service.dart';
import '../../services/auth_service.dart';
import '../../services/daily_challenge_service.dart';
import '../../services/progression_service.dart';
import '../../services/reward_service.dart';
import '../../services/support_service.dart';
import '../../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_modal.dart';
import '../widgets/support_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final GameRepository repository;
  final AuthService authService;
  final SyncService syncService;
  final AudioService audioService;
  final SupportService? supportService;

  const ProfileScreen({
    super.key,
    required this.repository,
    required this.authService,
    required this.syncService,
    required this.audioService,
    this.supportService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProgressionService _progressionService;
  late DailyChallengeService _dailyService;
  late AchievementService _achievementService;
  late SupportService _supportService;

  AccountModel? _account;
  int _completedCount = 0;
  int _totalStars = 0;
  int _coins = 0;
  int _streak = 0;
  int _unlockedAchievements = 0;
  PlayerLevel _playerLevel = const PlayerLevel(level: 5, currentXp: 150);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _progressionService = ProgressionService(repository: widget.repository);
    _dailyService = DailyChallengeService(repository: widget.repository);
    final rewardService = RewardService(repository: widget.repository);
    _achievementService = AchievementService(
      repository: widget.repository,
      rewardService: rewardService,
    );
    _supportService = widget.supportService ?? SupportService();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    _account = widget.authService.currentAccount;
    final allProgress = await widget.repository.getAllProgress();
    final stars = await _progressionService.getTotalStars();
    final coins = await widget.repository.getCoinsBalance();
    final streakData = await _dailyService.calculateStreaks();
    final achievements = await _achievementService.getAllAchievements();

    int completed = 0;
    allProgress.forEach((_, p) {
      if (p.isCompleted) completed++;
    });

    if (mounted) {
      setState(() {
        _completedCount = completed;
        _totalStars = stars;
        _coins = coins;
        _streak = streakData['currentStreak'] ?? 0;
        _unlockedAchievements = achievements.where((a) => a.isUnlocked).length;
        _playerLevel = PlayerLevel(level: (completed ~/ 10) + 1, currentXp: (completed % 10) * 25);
        _isLoading = false;
      });
    }
  }

  void _openAuthModal() {
    showDialog(
      context: context,
      builder: (_) => AuthModal(
        authService: widget.authService,
        syncService: widget.syncService,
        audioService: widget.audioService,
        onAuthSuccess: _loadProfileData,
      ),
    );
  }

  void _openSupportDialog() {
    widget.audioService.playSound(SoundType.buttonClick);
    showDialog(
      context: context,
      builder: (_) => SupportDialog(
        supportService: _supportService,
        audioService: widget.audioService,
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgLight,
        title: const Text('Sign Out?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You will return to Guest mode. Your cloud progress will remain safely backed up.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('Sign Out'),
            onPressed: () async {
              widget.audioService.playSound(SoundType.buttonClick);
              Navigator.of(ctx).pop();
              await widget.authService.signOut();
              await _loadProfileData();
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgLight,
        title: const Text('Delete Account?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This action permanently deletes your cloud account and online save data. This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
            onPressed: () async {
              widget.audioService.playSound(SoundType.buttonClick);
              Navigator.of(ctx).pop();
              await widget.authService.deleteAccount();
              await _loadProfileData();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = _account;
    final isGuest = account?.isGuest ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppTheme.primary,
                            child: Icon(
                              isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            account?.displayName ?? 'Guest Player',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Player XP Level Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.bgDark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Level ${_playerLevel.level}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.goldStar),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: _playerLevel.progressRatio,
                                      minHeight: 6,
                                      backgroundColor: Colors.black26,
                                      color: AppTheme.secondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_playerLevel.currentXp}/${_playerLevel.requiredXpForNextLevel} XP',
                                  style: const TextStyle(fontSize: 10, color: Colors.white60),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Cloud Sync Status Badge
                          ListenableBuilder(
                            listenable: widget.syncService,
                            builder: (context, _) {
                              final status = widget.syncService.status;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: status == SyncStatus.synced
                                      ? AppTheme.secondary.withAlpha(50)
                                      : AppTheme.tileBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: status == SyncStatus.synced
                                        ? AppTheme.secondary
                                        : Colors.white24,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      status == SyncStatus.synced
                                          ? Icons.cloud_done_rounded
                                          : status == SyncStatus.syncing
                                              ? Icons.cloud_sync_rounded
                                              : Icons.cloud_off_rounded,
                                      size: 14,
                                      color: status == SyncStatus.synced
                                          ? AppTheme.secondary
                                          : Colors.white70,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isGuest
                                          ? 'Local Storage (Guest)'
                                          : status == SyncStatus.synced
                                              ? 'Cloud Synced'
                                              : status == SyncStatus.syncing
                                                  ? 'Syncing...'
                                                  : 'Offline',
                                      style: const TextStyle(fontSize: 11, color: Colors.white),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Gameplay Stats Grid
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.6,
                        children: [
                          _buildStatCard(
                            icon: Icons.grid_view_rounded,
                            title: 'Completed',
                            value: '$_completedCount / 500',
                            color: AppTheme.primary,
                          ),
                          _buildStatCard(
                            icon: Icons.star_rounded,
                            title: 'Total Stars',
                            value: '$_totalStars',
                            color: AppTheme.goldStar,
                          ),
                          _buildStatCard(
                            icon: Icons.monetization_on_rounded,
                            title: 'Coins Balance',
                            value: '$_coins',
                            color: AppTheme.goldStar,
                          ),
                          _buildStatCard(
                            icon: Icons.whatshot_rounded,
                            title: 'Current Streak',
                            value: '$_streak Days',
                            color: AppTheme.accent,
                          ),
                          _buildStatCard(
                            icon: Icons.military_tech_rounded,
                            title: 'Achievements',
                            value: '$_unlockedAchievements / 11',
                            color: AppTheme.secondary,
                          ),
                          InkWell(
                            onTap: _openSupportDialog,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.secondary.withAlpha(150)),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.headset_mic_rounded, color: AppTheme.secondary, size: 22),
                                  SizedBox(height: 4),
                                  Text('Feedback & Support', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Controls
                    if (isGuest)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.cloud_upload_rounded),
                          label: const Text('SIGN IN / LINK ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _openAuthModal,
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white30),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text('Sign Out'),
                              onPressed: _confirmSignOut,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              icon: const Icon(Icons.delete_forever_rounded, size: 18),
                              label: const Text('Delete Account'),
                              onPressed: _confirmDeleteAccount,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 10),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.white60)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
