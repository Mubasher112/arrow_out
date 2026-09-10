import 'dart:math' as math;
import '../../domain/models/friendship_model.dart';
import '../../domain/models/friendship_status.dart';
import '../../domain/models/leaderboard_entry.dart';
import '../../domain/models/player_social_profile.dart';
import 'social_repository.dart';

/// Simulated remote backend database with server-authoritative ranking & security rules.
class InMemorySocialRepository implements SocialRepository {
  final Map<String, PlayerSocialProfile> _profilesDb = {};
  final List<FriendshipModel> _friendshipsDb = [];

  bool isNetworkAvailable = true;

  InMemorySocialRepository() {
    _seedSamplePlayers();
  }

  void _seedSamplePlayers() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final samples = [
      const PlayerSocialProfile(playerId: 'p1', displayName: 'Sofia Arrow', totalStars: 1420, completedLevels: 480, unlockedAchievements: 11, country: 'US', createdAt: 1000),
      const PlayerSocialProfile(playerId: 'p2', displayName: 'Mubasher Code', totalStars: 1398, completedLevels: 470, unlockedAchievements: 10, country: 'PK', createdAt: 2000),
      const PlayerSocialProfile(playerId: 'p3', displayName: 'Elena Swift', totalStars: 1375, completedLevels: 460, unlockedAchievements: 9, country: 'ES', createdAt: 3000),
      const PlayerSocialProfile(playerId: 'p4', displayName: 'Marco Puzzle', totalStars: 1210, completedLevels: 410, unlockedAchievements: 8, country: 'IT', createdAt: 4000),
      const PlayerSocialProfile(playerId: 'p5', displayName: 'Kenji Master', totalStars: 1150, completedLevels: 390, unlockedAchievements: 8, country: 'JP', createdAt: 5000),
      const PlayerSocialProfile(playerId: 'p6', displayName: 'Amina Star', totalStars: 980, completedLevels: 330, unlockedAchievements: 7, country: 'EG', createdAt: 6000),
    ];

    for (final p in samples) {
      _profilesDb[p.playerId] = p;
    }

    // Sample accepted friendship between p1 and p2
    _friendshipsDb.add(FriendshipModel(
      id: 'f_p1_p2',
      userA: 'p1',
      userB: 'p2',
      status: FriendshipStatus.friends,
      requestedBy: 'p1',
      createdAt: now,
      updatedAt: now,
    ));
  }

  @override
  Future<void> updateProfile(PlayerSocialProfile profile) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    _profilesDb[profile.playerId] = profile;
  }

  @override
  Future<PlayerSocialProfile?> getProfile(String playerId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    return _profilesDb[playerId];
  }

  @override
  Future<List<PlayerSocialProfile>> searchPlayers(String query) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    if (query.trim().isEmpty) return [];

    final q = query.toLowerCase();
    return _profilesDb.values
        .where((p) => p.displayName.toLowerCase().contains(q))
        .toList();
  }

  List<LeaderboardEntry> _calculateSortedLeaderboard() {
    final profiles = _profilesDb.values.toList();

    // Server-Authoritative Ranking Algorithm
    profiles.sort((a, b) {
      if (b.totalStars != a.totalStars) {
        return b.totalStars.compareTo(a.totalStars); // Primary: Stars desc
      }
      return b.completedLevels.compareTo(a.completedLevels); // Tie-breaker: Completed levels desc
    });

    return List.generate(profiles.length, (index) {
      final p = profiles[index];
      return LeaderboardEntry(
        rank: index + 1,
        playerId: p.playerId,
        displayName: p.displayName,
        avatarUrl: p.avatarUrl,
        totalStars: p.totalStars,
        completedLevels: p.completedLevels,
        bestMovePerformance: p.completedLevels * 5,
      );
    });
  }

  @override
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int offset = 0, int limit = 50}) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    final sorted = _calculateSortedLeaderboard();

    if (offset >= sorted.length) return [];
    final end = math.min(offset + limit, sorted.length);
    return sorted.sublist(offset, end);
  }

  @override
  Future<LeaderboardEntry?> getPlayerRank(String playerId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    final sorted = _calculateSortedLeaderboard();
    final match = sorted.where((e) => e.playerId == playerId);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<List<LeaderboardEntry>> getFriendsLeaderboard(String playerId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    final friends = await getFriendsList(playerId);
    final friendIds = friends.map((f) => f.playerId).toSet()..add(playerId);

    final sorted = _calculateSortedLeaderboard();
    final filtered = sorted.where((e) => friendIds.contains(e.playerId)).toList();

    return List.generate(filtered.length, (index) {
      final entry = filtered[index];
      return LeaderboardEntry(
        rank: index + 1,
        playerId: entry.playerId,
        displayName: entry.displayName,
        avatarUrl: entry.avatarUrl,
        totalStars: entry.totalStars,
        completedLevels: entry.completedLevels,
        bestMovePerformance: entry.bestMovePerformance,
      );
    });
  }

  FriendshipModel? _findRelationship(String userA, String userB) {
    for (final f in _friendshipsDb) {
      if ((f.userA == userA && f.userB == userB) || (f.userA == userB && f.userB == userA)) {
        return f;
      }
    }
    return null;
  }

  @override
  Future<FriendshipStatus> getFriendshipStatus(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) return FriendshipStatus.none;
    final rel = _findRelationship(currentUserId, targetUserId);
    if (rel == null) return FriendshipStatus.none;

    if (rel.status == FriendshipStatus.friends) return FriendshipStatus.friends;
    if (rel.status == FriendshipStatus.blocked) return FriendshipStatus.blocked;

    if (rel.status == FriendshipStatus.requestSent) {
      return rel.requestedBy == currentUserId
          ? FriendshipStatus.requestSent
          : FriendshipStatus.requestReceived;
    }

    return FriendshipStatus.none;
  }

  @override
  Future<void> sendFriendRequest(String currentUserId, String targetUserId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    if (currentUserId == targetUserId) throw Exception('Cannot add yourself as friend');

    final existing = _findRelationship(currentUserId, targetUserId);
    if (existing != null && existing.status != FriendshipStatus.none) {
      return; // Prevent duplicate requests
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final rel = FriendshipModel(
      id: 'f_${currentUserId}_$targetUserId',
      userA: currentUserId,
      userB: targetUserId,
      status: FriendshipStatus.requestSent,
      requestedBy: currentUserId,
      createdAt: now,
      updatedAt: now,
    );
    _friendshipsDb.add(rel);
  }

  @override
  Future<void> acceptFriendRequest(String currentUserId, String targetUserId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    final rel = _findRelationship(currentUserId, targetUserId);
    if (rel != null && rel.status == FriendshipStatus.requestSent) {
      _friendshipsDb.remove(rel);
      final now = DateTime.now().millisecondsSinceEpoch;
      _friendshipsDb.add(FriendshipModel(
        id: rel.id,
        userA: rel.userA,
        userB: rel.userB,
        status: FriendshipStatus.friends,
        requestedBy: rel.requestedBy,
        createdAt: rel.createdAt,
        updatedAt: now,
      ));
    }
  }

  @override
  Future<void> declineFriendRequest(String currentUserId, String targetUserId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    final rel = _findRelationship(currentUserId, targetUserId);
    if (rel != null) {
      _friendshipsDb.remove(rel);
    }
  }

  @override
  Future<void> removeFriend(String currentUserId, String targetUserId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    final rel = _findRelationship(currentUserId, targetUserId);
    if (rel != null) {
      _friendshipsDb.remove(rel);
    }
  }

  @override
  Future<void> blockPlayer(String currentUserId, String targetUserId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    final rel = _findRelationship(currentUserId, targetUserId);
    if (rel != null) _friendshipsDb.remove(rel);

    final now = DateTime.now().millisecondsSinceEpoch;
    _friendshipsDb.add(FriendshipModel(
      id: 'block_${currentUserId}_$targetUserId',
      userA: currentUserId,
      userB: targetUserId,
      status: FriendshipStatus.blocked,
      requestedBy: currentUserId,
      createdAt: now,
      updatedAt: now,
    ));
  }

  @override
  Future<List<PlayerSocialProfile>> getFriendsList(String playerId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    final List<PlayerSocialProfile> friends = [];

    for (final f in _friendshipsDb) {
      if (f.status == FriendshipStatus.friends) {
        final friendId = (f.userA == playerId) ? f.userB : (f.userB == playerId ? f.userA : null);
        if (friendId != null && _profilesDb.containsKey(friendId)) {
          friends.add(_profilesDb[friendId]!);
        }
      }
    }

    return friends;
  }

  @override
  Future<List<PlayerSocialProfile>> getPendingRequests(String playerId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    final List<PlayerSocialProfile> pending = [];

    for (final f in _friendshipsDb) {
      if (f.status == FriendshipStatus.requestSent && f.requestedBy != playerId) {
        final senderId = (f.userA == playerId) ? f.userB : f.userA;
        if (_profilesDb.containsKey(senderId)) {
          pending.add(_profilesDb[senderId]!);
        }
      }
    }

    return pending;
  }
}
