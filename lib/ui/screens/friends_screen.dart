import 'package:flutter/material.dart';
import '../../data/repositories/social_repository.dart';
import '../../domain/models/friendship_status.dart';
import '../../domain/models/player_social_profile.dart';
import '../../services/audio_service.dart';
import '../../services/auth_service.dart';
import '../../services/friends_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_modal.dart';
import '../widgets/public_profile_dialog.dart';
import 'leaderboard_screen.dart';

class FriendsScreen extends StatefulWidget {
  final SocialRepository socialRepository;
  final AuthService authService;
  final AudioService audioService;

  const FriendsScreen({
    super.key,
    required this.socialRepository,
    required this.authService,
    required this.audioService,
  });

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late FriendsService _friendsService;
  int _selectedTab = 0; // 0: My Friends, 1: Pending, 2: Find Players

  List<PlayerSocialProfile> _friendsList = [];
  List<PlayerSocialProfile> _pendingList = [];
  List<PlayerSocialProfile> _searchResults = [];

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _friendsService = FriendsService(socialRepository: widget.socialRepository);
    _loadFriendsData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendsData() async {
    setState(() => _isLoading = true);
    final account = widget.authService.currentAccount;

    if (account != null && !account.isGuest) {
      final friends = await _friendsService.getFriendsList(account.userId);
      final pending = await _friendsService.getPendingRequests(account.userId);

      if (mounted) {
        setState(() {
          _friendsList = friends;
          _pendingList = pending;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final results = await _friendsService.searchPlayers(query);
    final currentUserId = widget.authService.currentAccount?.userId;

    if (mounted) {
      setState(() {
        _searchResults = results.where((p) => p.playerId != currentUserId).toList();
        _isLoading = false;
      });
    }
  }

  void _openProfile(PlayerSocialProfile profile) {
    final currentUserId = widget.authService.currentAccount?.userId ?? '';
    showDialog(
      context: context,
      builder: (_) => PublicProfileDialog(
        profile: profile,
        currentUserId: currentUserId,
        friendsService: _friendsService,
        audioService: widget.audioService,
      ),
    ).then((_) => _loadFriendsData());
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.authService.currentAccount;
    final isGuest = account?.isGuest ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends & Social', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      // Sub-tabs
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            _buildTabChip('MY FRIENDS (${_friendsList.length})', 0),
                            const SizedBox(width: 8),
                            _buildTabChip('PENDING (${_pendingList.length})', 1),
                            const SizedBox(width: 8),
                            _buildTabChip('FIND', 2),
                          ],
                        ),
                      ),

                      // Search input for Find Players tab
                      if (_selectedTab == 2)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search player by display name...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.secondary),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.arrow_forward_rounded, color: AppTheme.primary),
                                onPressed: () => _performSearch(_searchController.text),
                              ),
                              filled: true,
                              fillColor: AppTheme.bgLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: _performSearch,
                          ),
                        ),

                      // Content List View
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadFriendsData,
                          child: _buildTabContent(),
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
            const Icon(Icons.people_alt_rounded, size: 72, color: AppTheme.secondary),
            const SizedBox(height: 16),
            const Text(
              'Sign in for Social Features',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create an account or sign in to add friends, compare progress, and view social rankings.',
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
                      onAuthSuccess: _loadFriendsData,
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

  Widget _buildTabChip(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(label, style: const TextStyle(fontSize: 11))),
        selected: isSelected,
        selectedColor: AppTheme.primary,
        backgroundColor: AppTheme.bgLight,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (sel) {
          if (sel) {
            widget.audioService.playSound(SoundType.buttonClick);
            setState(() => _selectedTab = index);
          }
        },
      ),
    );
  }

  Widget _buildTabContent() {
    final currentUserId = widget.authService.currentAccount?.userId ?? '';

    if (_selectedTab == 0) {
      if (_friendsList.isEmpty) {
        return const Center(
          child: Text('No friends added yet. Use "Find" to search players!', style: TextStyle(color: Colors.white60)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _friendsList.length,
        itemBuilder: (context, index) {
          final p = _friendsList[index];
          return _buildPlayerCard(p, isPending: false);
        },
      );
    } else if (_selectedTab == 1) {
      if (_pendingList.isEmpty) {
        return const Center(
          child: Text('No pending friend requests.', style: TextStyle(color: Colors.white60)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingList.length,
        itemBuilder: (context, index) {
          final p = _pendingList[index];
          return _buildPlayerCard(p, isPending: true);
        },
      );
    } else {
      if (_searchResults.isEmpty) {
        return const Center(
          child: Text('Search by name to find players.', style: TextStyle(color: Colors.white60)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final p = _searchResults[index];
          return _buildPlayerCard(p, isPending: false);
        },
      );
    }
  }

  Widget _buildPlayerCard(PlayerSocialProfile p, {required bool isPending}) {
    final currentUserId = widget.authService.currentAccount?.userId ?? '';

    return InkWell(
      onTap: () => _openProfile(p),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAlignment: CrossAlignment.start,
                children: [
                  Text(
                    p.displayName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppTheme.goldStar, size: 14),
                      const SizedBox(width: 2),
                      Text('${p.totalStars} Stars', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                      const SizedBox(width: 8),
                      Text('${p.completedLevels} Levels', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                    ],
                  ),
                ],
              ),
            ),
            if (isPending) ...[
              IconButton(
                icon: const Icon(Icons.check_circle_rounded, color: AppTheme.secondary, size: 28),
                onPressed: () async {
                  await _friendsService.acceptFriendRequest(currentUserId, p.playerId);
                  await _loadFriendsData();
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel_rounded, color: AppTheme.accent, size: 28),
                onPressed: () async {
                  await _friendsService.declineFriendRequest(currentUserId, p.playerId);
                  await _loadFriendsData();
                },
              ),
            ] else
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
