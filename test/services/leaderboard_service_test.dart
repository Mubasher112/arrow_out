import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/data/repositories/in_memory_social_repository.dart';
import 'package:arrow_path/services/leaderboard_service.dart';

void main() {
  group('LeaderboardService', () {
    test('fetches and caches global leaderboard', () async {
      final repo = InMemorySocialRepository();
      final service = LeaderboardService(socialRepository: repo);

      final page = await service.getGlobalLeaderboard(offset: 0, limit: 5);
      expect(page.length, 5);
      expect(service.cachedGlobalLeaderboard.length, 5);
    });

    test('fetches player rank', () async {
      final repo = InMemorySocialRepository();
      final service = LeaderboardService(socialRepository: repo);

      final rank = await service.getPlayerRank('p1');
      expect(rank, isNotNull);
      expect(rank!.playerId, 'p1');
    });
  });
}
