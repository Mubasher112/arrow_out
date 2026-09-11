import 'package:flutter/material.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../../services/daily_login_service.dart';
import '../../services/reward_service.dart';
import '../theme/app_theme.dart';

class DailyRewardDialog extends StatefulWidget {
  final GameRepository repository;
  final AudioService audioService;
  final VoidCallback? onRewardClaimed;

  const DailyRewardDialog({
    super.key,
    required this.repository,
    required this.audioService,
    this.onRewardClaimed,
  });

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog> {
  late DailyLoginService _loginService;
  int _currentDay = 1;
  bool _isClaimed = false;
  bool _isLoading = true;
  int _claimedAmount = 0;

  @override
  void initState() {
    super.initState();
    final rewardService = RewardService(repository: widget.repository);
    _loginService = DailyLoginService(
      repository: widget.repository,
      rewardService: rewardService,
    );
    _loadState();
  }

  Future<void> _loadState() async {
    setState(() => _isLoading = true);
    final day = await _loginService.getCurrentLoginDay();
    final claimed = await _loginService.isTodayClaimed();

    if (mounted) {
      setState(() {
        _currentDay = day;
        _isClaimed = claimed;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleClaim() async {
    widget.audioService.playSound(SoundType.levelComplete);
    final amount = await _loginService.claimTodayReward();

    if (mounted) {
      setState(() {
        _claimedAmount = amount;
        _isClaimed = true;
      });
      widget.onRewardClaimed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppTheme.bgLight,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Login Rewards',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 16),

            if (_claimedAmount > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.goldStar,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '+$_claimedAmount COINS CLAIMED!',
                  style: const TextStyle(fontWeight: FontWeight.black, color: Colors.black),
                ),
              ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              )
            else ...[
              // 7-Day Grid Calendar
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
                children: List.generate(7, (index) {
                  final dayNum = index + 1;
                  final reward = DailyLoginService.defaultRewards[index];
                  final isToday = dayNum == _currentDay;
                  final isPastClaimed = dayNum < _currentDay || (isToday && _isClaimed);

                  return Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppTheme.primary
                          : isPastClaimed
                              ? AppTheme.bgDark
                              : AppTheme.tileBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isToday ? AppTheme.goldStar : Colors.white10,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Day $dayNum', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                        const SizedBox(height: 2),
                        Icon(
                          isPastClaimed
                              ? Icons.check_circle_rounded
                              : Icons.monetization_on_rounded,
                          color: isPastClaimed
                              ? AppTheme.secondary
                              : isToday
                                  ? AppTheme.goldStar
                                  : Colors.white38,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+${reward.amount}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isClaimed ? AppTheme.cardBg : AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: Icon(_isClaimed ? Icons.check_rounded : Icons.card_giftcard_rounded),
                  label: Text(
                    _isClaimed ? 'Come back tomorrow!' : 'CLAIM TODAY REWARD',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isClaimed ? null : _handleClaim,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
