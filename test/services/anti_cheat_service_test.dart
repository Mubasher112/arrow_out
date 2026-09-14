import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/domain/models/game_board.dart';
import 'package:arrow_path/domain/models/arrow.dart';
import 'package:arrow_path/domain/models/level_definition.dart';
import 'package:arrow_path/services/anti_cheat_service.dart';

void main() {
  group('AntiCheatService', () {
    final testLevel = LevelDefinition(
      id: 1,
      difficulty: 'Easy',
      board: const GameBoard(
        rows: 4,
        cols: 4,
        arrows: [
          Arrow(id: 'a1', row: 0, col: 0, direction: ArrowDirection.up),
          Arrow(id: 'a2', row: 1, col: 1, direction: ArrowDirection.left),
        ],
      ),
      parMoves: 5,
    );

    test('validates legitimate score submission', () {
      final result = AntiCheatService.validateSubmission(
        level: testLevel,
        movesTaken: 2,
        durationSeconds: 15,
      );

      expect(result.isValid, isTrue);
      expect(result.rejectionReason, isNull);
    });

    test('flags unrealistically fast completion speed', () {
      final result = AntiCheatService.validateSubmission(
        level: testLevel,
        movesTaken: 2,
        durationSeconds: 0,
      );

      expect(result.isValid, isFalse);
      expect(result.rejectionReason, contains('<1s'));
    });

    test('flags move count less than total arrows', () {
      final result = AntiCheatService.validateSubmission(
        level: testLevel,
        movesTaken: 1,
        durationSeconds: 10,
      );

      expect(result.isValid, isFalse);
      expect(result.rejectionReason, contains('less than total arrows'));
    });
  });
}
