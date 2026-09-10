import 'package:flutter/material.dart';
import '../../domain/models/friendship_status.dart';
import '../../domain/models/player_social_profile.dart';
import '../../services/audio_service.dart';
import '../../services/friends_service.dart';
import '../theme/app_theme.dart';

class PublicProfileDialog extends StatefulWidget {
  final PlayerSocialProfile profile;
  final String currentUserId;
  final FriendsService friendsService;
  final AudioService audioService;

  const PublicProfileDialog({
    super.key,
    required this.profile,
    required this.currentUserId,
    required this.friendsService,
    required this.audioService,
  });

  @override
  State<PublicProfileDialog> createState() => _PublicProfileDialogState();
}

class _PublicProfileDialogState extends State<PublicProfileDialog> {
  FriendshipStatus _status = FriendshipStatus.none;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    final status = await widget.friendsService.getFriendshipStatus(
      widget.currentUserId,
      widget.profile.playerId,
    );
    if (mounted) {
      setState(() {
        _status = status;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleFriendAction() async {
    widget.audioService.playSound(SoundType.buttonClick);
    setState(() => _isLoading = true);

    try {
      if (_status == FriendshipStatus.none) {
        await widget.friendsService.sendFriendRequest(widget.currentUserId, widget.profile.playerId);
      } else if (_status == FriendshipStatus.requestReceived) {
        await widget.friendsService.acceptFriendRequest(widget.currentUserId, widget.profile.playerId);
      } else if (_status == FriendshipStatus.friends) {
        await widget.friendsService.removeFriend(widget.currentUserId, widget.profile.playerId);
      }
      await _loadStatus();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelf = widget.currentUserId == widget.profile.playerId;

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
                  'Player Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 20),

            CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),

            Text(
              widget.profile.displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            if (widget.profile.country != null) ...[
              const SizedBox(height: 2),
              Text(
                'Region: ${widget.profile.country}',
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],

            const SizedBox(height: 16),

            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.bgDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Stars', '${widget.profile.totalStars}', Icons.star_rounded, AppTheme.goldStar),
                  _buildStat('Levels', '${widget.profile.completedLevels}', Icons.grid_view_rounded, AppTheme.secondary),
                  _buildStat('Badges', '${widget.profile.unlockedAchievements}', Icons.military_tech_rounded, AppTheme.primaryLight),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (!isSelf)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _status == FriendshipStatus.friends
                        ? AppTheme.accent
                        : AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: Icon(_status == FriendshipStatus.friends
                      ? Icons.person_remove_rounded
                      : _status == FriendshipStatus.requestSent
                          ? Icons.hourglass_top_rounded
                          : Icons.person_add_rounded),
                  label: Text(_status == FriendshipStatus.friends
                      ? 'Remove Friend'
                      : _status == FriendshipStatus.requestSent
                          ? 'Request Sent'
                          : _status == FriendshipStatus.requestReceived
                              ? 'Accept Request'
                              : 'Add Friend'),
                  onPressed: _isLoading || _status == FriendshipStatus.requestSent
                      ? null
                      : _handleFriendAction,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.white60)),
      ],
    );
  }
}
