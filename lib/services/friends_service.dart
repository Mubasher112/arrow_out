import '../data/repositories/social_repository.dart';
import '../domain/models/friendship_status.dart';
import '../domain/models/player_social_profile.dart';

/// Service managing player search, friend requests, friend lists, and blocking/reporting.
class FriendsService {
  final SocialRepository _socialRepository;

  FriendsService({required SocialRepository socialRepository})
      : _socialRepository = socialRepository;

  /// Search players by public display name.
  Future<List<PlayerSocialProfile>> searchPlayers(String query) async {
    return await _socialRepository.searchPlayers(query);
  }

  /// Get friendship relationship status with target player.
  Future<FriendshipStatus> getFriendshipStatus(String currentUserId, String targetUserId) async {
    return await _socialRepository.getFriendshipStatus(currentUserId, targetUserId);
  }

  /// Send friend request to target player.
  Future<void> sendFriendRequest(String currentUserId, String targetUserId) async {
    await _socialRepository.sendFriendRequest(currentUserId, targetUserId);
  }

  /// Accept incoming friend request.
  Future<void> acceptFriendRequest(String currentUserId, String targetUserId) async {
    await _socialRepository.acceptFriendRequest(currentUserId, targetUserId);
  }

  /// Decline incoming friend request.
  Future<void> declineFriendRequest(String currentUserId, String targetUserId) async {
    await _socialRepository.declineFriendRequest(currentUserId, targetUserId);
  }

  /// Remove existing friend.
  Future<void> removeFriend(String currentUserId, String targetUserId) async {
    await _socialRepository.removeFriend(currentUserId, targetUserId);
  }

  /// Block player.
  Future<void> blockPlayer(String currentUserId, String targetUserId) async {
    await _socialRepository.blockPlayer(currentUserId, targetUserId);
  }

  /// Get player's accepted friends list.
  Future<List<PlayerSocialProfile>> getFriendsList(String playerId) async {
    return await _socialRepository.getFriendsList(playerId);
  }

  /// Get pending incoming friend requests.
  Future<List<PlayerSocialProfile>> getPendingRequests(String playerId) async {
    return await _socialRepository.getPendingRequests(playerId);
  }
}
