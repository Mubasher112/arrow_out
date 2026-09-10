import 'package:flutter/material.dart';
import '../../data/repositories/social_repository.dart';
import '../../domain/models/leaderboard_entry.dart';
import '../../services/audio_service.dart';
import '../../services/auth_service.dart';
import '../../services/friends_service.dart';
import '../../services/leaderboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_modal.dart';
import '../widgets/public_profile_dialog.dart';

class LeaderboardScreen extends StatefulWidget {
  final SocialRepository socialRepository;
  final AuthService authService;
  final AudioService audioService;

  const LeaderboardScreen({
    super.key,
    required this.socialRepository,
    required this.authService,
    required this.audioService,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late LeaderboardService _leaderboardService;
  late FriendsService _friendsService;

  int _selectedTab = 0; // 0: Global, 1: Friends
  List<LeaderboardEntry> _globalEntries = [];
  List<LeaderboardEntry> _friendsEntries = [];
  LeaderboardEntry? _myRankEntry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _leaderboardService = LeaderboardService(socialRepository: widget.socialRepository);
    _friendsService = FriendsService(socialRepository: widget.socialRepository);
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData() async {
    setState(() => _isLoading = true);
    final account = widget.authService.currentAccount;

    if (account != null && !account.isGuest) {
      final global = await _leaderboardService.getGlobalLeaderboard(offset: 0, limit: 50);
      final friends = await _leaderboardService.getFriendsLeaderboard(account.userId);
      final myRank = await _leaderboardService.getPlayerRank(account.userId);

      if (mounted) {
        setState(() {
          _globalEntries = global;
          _friendsEntries = friends;
          _myRankEntry = myRank;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openProfileDialog(LeaderboardEntry entry) async {
    final profile = await widget.socialRepository.getProfile(entry.playerId);
    if (profile == null || !mounted) return;

    final currentUserId = widget.authService.currentAccount?.userId ?? '';

    showDialog(
      context: context,
      builder: (_) => PublicProfileDialog(
        profile: profile,
        currentUserId: currentUserId,
        friendsService: _friendsService,
        audioService: widget.audioService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.authService.currentAccount;
    final isGuest = account?.isGuest ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: isGuest
            ? _buildGuestPrompt()
            : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Tabs Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('GLOBAL RANKINGS')),
                                selected: _selectedTab == 0,
                                selectedColor: AppTheme.primary,
                                backgroundColor: AppTheme.bgLight,
                                labelStyle: TextStyle(
                                  color: _selectedTab == 0 ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (sel) {
                                  if (sel) {
                                    widget.audioService.playSound(SoundType.buttonClick);
                                    setState(() => _selectedTab = 0);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('FRIENDS')),
                                selected: _selectedTab == 1,
                                selectedColor: AppTheme.primary,
                                backgroundColor: AppTheme.bgLight,
                                labelStyle: TextStyle(
                                  color: _selectedTab == 1 ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (sel) {
                                  if (sel) {
                                    widget.audioService.playSound(SoundType.buttonClick);
                                    setState(() => _selectedTab = 1);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Current Player Rank Highlight Badge
                      if (_myRankEntry != null) _buildMyRankBanner(_myRankEntry!),

                      // Leaderboard List View
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadLeaderboardData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _selectedTab == 0 ? _globalEntries.length : _friendsEntries.length,
                            itemBuilder: (context, index) {
                              final entry = _selectedTab == 0 ? _globalEntries[index] : _friendsEntries[index];
                              final isMe = entry.playerId == account?.userId;

                              return _buildLeaderboardRow(entry, isMe);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildGuestPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.leaderboard_rounded, size: 72, color: AppTheme.goldStar),
            const SizedBox(height: 16),
            const Text(
              'Sign in to compete',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create an account or sign in to compare your progress with other players on the global leaderboard.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                icon: const Icon(Icons.cloud_upload_rounded),
                label: const Text('SIGN IN / LINK ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AuthModal(
                      authService: widget.authService,
                      syncService: MockSyncService(),
                      audioService: widget.audioService,
                      onAuthSuccess: _loadLeaderboardData,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRankBanner(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldStar, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '#${entry.rank}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.black, color: AppTheme.goldStar),
              ),
              const SizedBox(width: 12),
              const Text(
                'YOUR RANKING',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppTheme.goldStar, size: 20),
              const SizedBox(width: 4),
              Text(
                '${entry.totalStars}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(LeaderboardEntry entry, bool isMe) {
    final rankColor = entry.rank == 1
        ? AppTheme.goldStar
        : entry.rank == 2
            ? const Color(0xFFC0C0C0)
            : entry.rank == 3
                ? const Color(0xFFCD7F32)
                : Colors.white70;

    return InkWell(
      onTap: () => _openProfileDialog(entry),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary.withAlpha(120) : AppTheme.bgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMe ? AppTheme.goldStar : Colors.white10,
            width: isMe ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.tileBg,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.displayName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.goldStar, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${entry.totalStars}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MockSyncService extends ChangeNotifier implements dynamic {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
