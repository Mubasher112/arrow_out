import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../domain/level_generator.dart';
import '../domain/models/difficulty.dart';
import '../domain/models/level_definition.dart';
import '../domain/repositories/game_repository.dart';
import 'date_provider.dart';

/// Completed daily challenge record.
class DailyChallengeResult {
  final String dateIso;
  final bool isCompleted;
  final int stars;
  final int movesTaken;
  final int bestMoves;

  const DailyChallengeResult({
    required this.dateIso,
    required this.isCompleted,
    required this.stars,
    required this.movesTaken,
    required this.bestMoves,
  });

  Map<String, dynamic> toJson() => {
        'dateIso': dateIso,
        'isCompleted': isCompleted,
        'stars': stars,
        'movesTaken': movesTaken,
        'bestMoves': bestMoves,
      };

  factory DailyChallengeResult.fromJson(Map<String, dynamic> json) =>
      DailyChallengeResult(
        dateIso: json['dateIso'] as String,
        isCompleted: json['isCompleted'] as bool,
        stars: json['stars'] as int,
        movesTaken: json['movesTaken'] as int,
        bestMoves: json['bestMoves'] as int,
      );
}

/// Service managing daily puzzle generation, completion records, and streak calculations.
class DailyChallengeService {
  final GameRepository _repository;
  final DateProvider _dateProvider;

  DailyChallengeService({
    required GameRepository repository,
    DateProvider? dateProvider,
  })  : _repository = repository,
        _dateProvider = dateProvider ?? const LocalDateProvider();

  DateProvider get dateProvider => _dateProvider;

  /// Generate deterministic seed integer for a specific ISO calendar date.
  int getSeedForDate(String dateIso) {
    final raw = 'v1_arrow_path_daily_$dateIso';
    final bytes = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    // Take first 4 bytes as positive 32-bit integer seed
    return digest.bytes.take(4).fold(0, (acc, b) => (acc << 8) | b).abs();
  }

  /// Get daily challenge level definition for a given ISO date (defaults to today).
  LevelDefinition getChallengeForDate(String dateIso) {
    final seed = getSeedForDate(dateIso);
    final generator = LevelGenerator(seed: seed);

    // Parse date day of month to vary grid sizes (6x6 or 7x7)
    final dt = DateProvider.parseIso(dateIso);
    final rows = (dt.day % 2 == 0) ? 6 : 7;

    return generator.generateCustomLevel(
      levelNumber: 10000 + dt.day,
      rows: rows,
      cols: rows,
      difficulty: Difficulty.hard,
    );
  }

  /// Get today's daily challenge puzzle.
  LevelDefinition getTodayChallenge() {
    return getChallengeForDate(_dateProvider.currentDateIso);
  }

  /// Calculate current streak and longest streak based on completed dates.
  Future<Map<String, int>> calculateStreaks() async {
    final completedMap = await _repository.getDailyChallengeResults();
    final today = _dateProvider.now;

    int currentStreak = 0;
    int longestStreak = await _repository.getLongestStreak();

    // Check backwards day by day from today or yesterday
    DateTime checkDate = today;
    final todayIso = DateProvider.dateToIso(today);

    // If today is completed, start streak from today
    if (completedMap.containsKey(todayIso) && completedMap[todayIso]!.isCompleted) {
      currentStreak++;
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      // If today not completed yet, check if yesterday was completed
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayIso = DateProvider.dateToIso(yesterday);
      if (completedMap.containsKey(yesterdayIso) && completedMap[yesterdayIso]!.isCompleted) {
        checkDate = yesterday;
      } else {
        // Streak is broken / 0
        return {
          'currentStreak': 0,
          'longestStreak': longestStreak,
        };
      }
    }

    // Iterate backwards consecutive days
    while (true) {
      final iso = DateProvider.dateToIso(checkDate);
      if (completedMap.containsKey(iso) && completedMap[iso]!.isCompleted) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
      await _repository.setLongestStreak(longestStreak);
    }

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  /// Record daily challenge completion and update streak state.
  Future<bool> recordDailyCompletion({
    required String dateIso,
    required int stars,
    required int movesTaken,
  }) async {
    final completedMap = await _repository.getDailyChallengeResults();
    final existing = completedMap[dateIso];

    final isFirstCompletion = existing == null || !existing.isCompleted;

    final bestMoves = (existing != null && existing.bestMoves < movesTaken)
        ? existing.bestMoves
        : movesTaken;
    final bestStars = (existing != null && existing.stars > stars)
        ? existing.stars
        : stars;

    final result = DailyChallengeResult(
      dateIso: dateIso,
      isCompleted: true,
      stars: bestStars,
      movesTaken: movesTaken,
      bestMoves: bestMoves,
    );

    await _repository.saveDailyChallengeResult(result);
    await calculateStreaks();

    return isFirstCompletion;
  }
}
