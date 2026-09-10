import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/data/repositories/in_memory_social_repository.dart';
import 'package:arrow_path/domain/models/friendship_status.dart';
import 'package:arrow_path/services/friends_service.dart';

void main() {
  group('FriendsService', () {
    test('send, accept, remove friend flow', () async {
      final repo = InMemorySocialRepository();
      final service = FriendsService(socialRepository: repo);

      expect(await service.getFriendshipStatus('u1', 'u2'), FriendshipStatus.none);

      await service.sendFriendRequest('u1', 'u2');
      expect(await service.getFriendshipStatus('u1', 'u2'), FriendshipStatus.requestSent);

      final pending = await service.getPendingRequests('u2');
      expect(pending.any((p) => p.playerId == 'u1'), isTrue);

      await service.acceptFriendRequest('u2', 'u1');
      expect(await service.getFriendshipStatus('u1', 'u2'), FriendshipStatus.friends);

      await service.removeFriend('u1', 'u2');
      expect(await service.getFriendshipStatus('u1', 'u2'), FriendshipStatus.none);
    });
  });
}
