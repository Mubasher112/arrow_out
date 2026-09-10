import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/data/repositories/in_memory_social_repository.dart';
import 'package:arrow_path/domain/models/friendship_status.dart';
import 'package:arrow_path/domain/models/player_social_profile.dart';

void main() {
  late InMemorySocialRepository repo;

  setUp(() {
    repo = InMemorySocialRepository();
  });

  group('SocialRepository Leaderboards & Ranking Algorithm', () {
    test('ranks players by totalStars desc then completedLevels desc', () async {
      const p1 = PlayerSocialProfile(playerId: 'user1', displayName: 'User 1', totalStars: 100, completedLevels: 50, unlockedAchievements: 2, createdAt: 100);
      const p2 = PlayerSocialProfile(playerId: 'user2', displayName: 'User 2', totalStars: 200, completedLevels: 80, unlockedAchievements: 5, createdAt: 100);
      const p3 = PlayerSocialProfile(playerId: 'user3', displayName: 'User 3', totalStars: 200, completedLevels: 90, unlockedAchievements: 6, createdAt: 100);

      await repo.updateProfile(p1);
      await repo.updateProfile(p2);
      await repo.updateProfile(p3);

      final leaderboard = await repo.getGlobalLeaderboard(offset: 0, limit: 10);

      // Top player should be p3 (200 stars, 90 levels), second p2 (200 stars, 80 levels), third p1 (100 stars)
      final top3 = leaderboard.where((e) => ['user1', 'user2', 'user3'].contains(e.playerId)).toList();
      expect(top3[0].playerId, 'user3');
      expect(top3[1].playerId, 'user2');
      expect(top3[2].playerId, 'user1');
    });

    test('supports leaderboard pagination', () async {
      final page1 = await repo.getGlobalLeaderboard(offset: 0, limit: 2);
      expect(page1.length, 2);
      expect(page1[0].rank, 1);
      expect(page1[1].rank, 2);

      final page2 = await repo.getGlobalLeaderboard(offset: 2, limit: 2);
      expect(page2.length, 2);
      expect(page2[0].rank, 3);
      expect(page2[1].rank, 4);
    });

    test('searches players by display name', () async {
      final results = await repo.searchPlayers('Sofia');
      expect(results.length, 1);
      expect(results.first.displayName, 'Sofia Arrow');
    });
  });

  group('Friendship Relationships & Security Rules', () {
    test('sends and accepts friend request', () async {
      final status1 = await repo.getFriendshipStatus('userA', 'userB');
      expect(status1, FriendshipStatus.none);

      await repo.sendFriendRequest('userA', 'userB');
      expect(await repo.getFriendshipStatus('userA', 'userB'), FriendshipStatus.requestSent);
      expect(await repo.getFriendshipStatus('userB', 'userA'), FriendshipStatus.requestReceived);

      await repo.acceptFriendRequest('userB', 'userA');
      expect(await repo.getFriendshipStatus('userA', 'userB'), FriendshipStatus.friends);
    });

    test('prevents sending friend request to yourself', () async {
      expect(() => repo.sendFriendRequest('userA', 'userA'), throwsException);
    });

    test('blocks player and removes existing friendship', () async {
      await repo.sendFriendRequest('userA', 'userB');
      await repo.acceptFriendRequest('userB', 'userA');
      expect(await repo.getFriendshipStatus('userA', 'userB'), FriendshipStatus.friends);

      await repo.blockPlayer('userA', 'userB');
      expect(await repo.getFriendshipStatus('userA', 'userB'), FriendshipStatus.blocked);
    });
  });
}
