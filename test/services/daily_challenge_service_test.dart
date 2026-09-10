import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/domain/level_validator.dart';
import 'package:arrow_path/services/daily_challenge_service.dart';
import 'package:arrow_path/services/date_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('DailyChallengeService Seed Determinism & Solvability', () {
    test('same date produces identical seed and puzzle', () {
      final repo = LocalGameRepository();
      final dateProvider = TestDateProvider(DateTime(2026, 9, 10));
      final service = DailyChallengeService(repository: repo, dateProvider: dateProvider);

      final level1 = service.getChallengeForDate('2026-09-10');
      final level2 = service.getChallengeForDate('2026-09-10');

      expect(level1.rows, level2.rows);
      expect(level1.initialArrows.length, level2.initialArrows.length);
      for (int i = 0; i < level1.initialArrows.length; i++) {
        expect(level1.initialArrows[i], equals(level2.initialArrows[i]));
      }
    });

    test('different dates produce different seeds', () {
      final repo = LocalGameRepository();
      final service = DailyChallengeService(repository: repo);

      final seed1 = service.getSeedForDate('2026-09-10');
      final seed2 = service.getSeedForDate('2026-09-11');

      expect(seed1, isNot(equals(seed2)));
    });

    test('daily challenge puzzle passes LevelValidator', () {
      final repo = LocalGameRepository();
      final service = DailyChallengeService(repository: repo);

      final level = service.getChallengeForDate('2026-09-10');
      final validation = LevelValidator.validate(level);

      expect(validation.isValid, isTrue, reason: 'Daily challenge puzzle must be 100% solvable');
    });
  });

  group('Streak Calculation Engine', () {
    test('consecutive daily completions increase streak', () async {
      final repo = LocalGameRepository();
      final dateProvider = TestDateProvider(DateTime(2026, 9, 10));
      final service = DailyChallengeService(repository: repo, dateProvider: dateProvider);

      // Day 1
      await service.recordDailyCompletion(dateIso: '2026-09-10', stars: 3, movesTaken: 12);
      var streaks = await service.calculateStreaks();
      expect(streaks['currentStreak'], 1);

      // Day 2
      dateProvider.advanceDays(1); // 2026-09-11
      await service.recordDailyCompletion(dateIso: '2026-09-11', stars: 3, movesTaken: 14);
      streaks = await service.calculateStreaks();
      expect(streaks['currentStreak'], 2);

      // Day 3
      dateProvider.advanceDays(1); // 2026-09-12
      await service.recordDailyCompletion(dateIso: '2026-09-12', stars: 2, movesTaken: 18);
      streaks = await service.calculateStreaks();
      expect(streaks['currentStreak'], 3);
      expect(streaks['longestStreak'], 3);
    });

    test('missed day resets current streak but preserves longest streak', () async {
      final repo = LocalGameRepository();
      final dateProvider = TestDateProvider(DateTime(2026, 9, 10));
      final service = DailyChallengeService(repository: repo, dateProvider: dateProvider);

      await service.recordDailyCompletion(dateIso: '2026-09-10', stars: 3, movesTaken: 10);
      await service.recordDailyCompletion(dateIso: '2026-09-11', stars: 3, movesTaken: 12);

      // Skip 2026-09-12, advance to 2026-09-13
      dateProvider.setDate(DateTime(2026, 9, 13));

      final streaks = await service.calculateStreaks();
      expect(streaks['currentStreak'], 0);
      expect(streaks['longestStreak'], 2);
    });

    test('replaying same challenge does not grant duplicate streak counts', () async {
      final repo = LocalGameRepository();
      final dateProvider = TestDateProvider(DateTime(2026, 9, 10));
      final service = DailyChallengeService(repository: repo, dateProvider: dateProvider);

      final isFirst1 = await service.recordDailyCompletion(dateIso: '2026-09-10', stars: 2, movesTaken: 15);
      expect(isFirst1, isTrue);

      final isFirst2 = await service.recordDailyCompletion(dateIso: '2026-09-10', stars: 3, movesTaken: 12);
      expect(isFirst2, isFalse);

      final streaks = await service.calculateStreaks();
      expect(streaks['currentStreak'], 1);
    });
  });
}
