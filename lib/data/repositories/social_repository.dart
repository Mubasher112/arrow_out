import '../../domain/models/friendship_status.dart';
import '../../domain/models/leaderboard_entry.dart';
import '../../domain/models/player_social_profile.dart';

/// Abstract repository interface for social operations, leaderboards, and friendships.
abstract class SocialRepository {
  Future<void> updateProfile(PlayerSocialProfile profile);
  Future<PlayerSocialProfile?> getProfile(String playerId);
  Future<List<PlayerSocialProfile>> searchPlayers(String query);

  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int offset = 0, int limit = 50});
  Future<LeaderboardEntry?> getPlayerRank(String playerId);
  Future<List<LeaderboardEntry>> getFriendsLeaderboard(String playerId);

  Future<FriendshipStatus> getFriendshipStatus(String currentUserId, String targetUserId);
  Future<void> sendFriendRequest(String currentUserId, String targetUserId);
  Future<void> acceptFriendRequest(String currentUserId, String targetUserId);
  Future<void> declineFriendRequest(String currentUserId, String targetUserId);
  Future<void> removeFriend(String currentUserId, String targetUserId);
  Future<void> blockPlayer(String currentUserId, String targetUserId);

  Future<List<PlayerSocialProfile>> getFriendsList(String playerId);
  Future<List<PlayerSocialProfile>> getPendingRequests(String playerId);
}
