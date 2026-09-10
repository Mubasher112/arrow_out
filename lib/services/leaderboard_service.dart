import '../data/repositories/social_repository.dart';
import '../domain/models/leaderboard_entry.dart';

/// Service managing paginated global and friends leaderboards with offline caching.
class LeaderboardService {
  final SocialRepository _socialRepository;
  List<LeaderboardEntry> _cachedGlobalLeaderboard = [];
  List<LeaderboardEntry> _cachedFriendsLeaderboard = [];

  LeaderboardService({required SocialRepository socialRepository})
      : _socialRepository = socialRepository;

  List<LeaderboardEntry> get cachedGlobalLeaderboard => _cachedGlobalLeaderboard;
  List<LeaderboardEntry> get cachedFriendsLeaderboard => _cachedFriendsLeaderboard;

  /// Fetch global leaderboard page.
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int offset = 0, int limit = 50}) async {
    try {
      final entries = await _socialRepository.getGlobalLeaderboard(offset: offset, limit: limit);
      if (offset == 0) {
        _cachedGlobalLeaderboard = entries;
      }
      return entries;
    } catch (_) {
      return _cachedGlobalLeaderboard; // Return cached data on offline failure
    }
  }

  /// Fetch current player's calculated global rank.
  Future<LeaderboardEntry?> getPlayerRank(String playerId) async {
    try {
      return await _socialRepository.getPlayerRank(playerId);
    } catch (_) {
      return null;
    }
  }

  /// Fetch friends leaderboard.
  Future<List<LeaderboardEntry>> getFriendsLeaderboard(String playerId) async {
    try {
      final entries = await _socialRepository.getFriendsLeaderboard(playerId);
      _cachedFriendsLeaderboard = entries;
      return entries;
    } catch (_) {
      return _cachedFriendsLeaderboard;
    }
  }
}
