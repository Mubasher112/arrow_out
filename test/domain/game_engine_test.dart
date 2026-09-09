import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/domain/game_engine.dart';
import 'package:arrow_path/domain/models/arrow.dart';
import 'package:arrow_path/domain/models/arrow_direction.dart';
import 'package:arrow_path/domain/models/arrow_state.dart';
import 'package:arrow_path/domain/models/game_status.dart';
import 'package:arrow_path/domain/models/level_definition.dart';

void main() {
  late GameEngine engine;

  setUp(() {
    engine = GameEngine();
  });

  group('Upgraded GameEngine API & Metrics', () {
    test('startLevel initializes metrics and state correctly', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        initialArrows: [
          Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
        ],
        parMoves: 1,
      );

      engine.startLevel(level);

      expect(engine.status, GameStatus.playing);
      expect(engine.totalMoves, 0);
      expect(engine.successfulMoves, 0);
      expect(engine.failedAttempts, 0);
      expect(engine.getRemainingArrows().length, 1);
      expect(engine.isLevelComplete(), isFalse);
    });

    test('canMove checks path clearance', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        initialArrows: [
          Arrow(id: 'a1', row: 1, column: 1, direction: ArrowDirection.up),
          Arrow(id: 'a2', row: 0, column: 1, direction: ArrowDirection.right),
        ],
        parMoves: 2,
      );

      engine.startLevel(level);

      final a1 = engine.board!.getArrowById('a1')!;
      final a2 = engine.board!.getArrowById('a2')!;

      expect(engine.canMove(a1), isFalse); // Blocked by a2
      expect(engine.canMove(a2), isTrue); // Path to edge is clear
    });

    test('moveArrow tracks totalMoves, successfulMoves, and failedAttempts', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        initialArrows: [
          Arrow(id: 'a1', row: 1, column: 1, direction: ArrowDirection.up),
          Arrow(id: 'a2', row: 0, column: 1, direction: ArrowDirection.right),
        ],
        parMoves: 2,
      );

      engine.startLevel(level);

      // Attempt blocked move
      final res1 = engine.moveArrow('a1');
      expect(res1.isValid, isFalse);
      expect(res1.blockingArrow?.id, 'a2');
      expect(engine.totalMoves, 1);
      expect(engine.successfulMoves, 0);
      expect(engine.failedAttempts, 1);

      // Reset blocked state and make valid move
      engine.resetBlockedState('a1');
      final res2 = engine.moveArrow('a2');
      expect(res2.isValid, isTrue);
      expect(engine.totalMoves, 2);
      expect(engine.successfulMoves, 1);
      expect(engine.failedAttempts, 1);
      expect(engine.getRemainingArrows().length, 1);
    });

    test('multiple sequential undo operations and post-completion undo', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        initialArrows: [
          Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
          Arrow(id: 'a2', row: 2, column: 2, direction: ArrowDirection.down),
        ],
        parMoves: 2,
      );

      engine.startLevel(level);

      engine.moveArrow('a1');
      expect(engine.successfulMoves, 1);
      expect(engine.getRemainingArrows().length, 1);

      engine.moveArrow('a2');
      expect(engine.successfulMoves, 2);
      expect(engine.isLevelComplete(), isTrue);
      expect(engine.status, GameStatus.completed);

      // Post-completion Undo
      final undo1 = engine.undo();
      expect(undo1.success, isTrue);
      expect(undo1.restoredArrow?.id, 'a2');
      expect(engine.status, GameStatus.playing);
      expect(engine.successfulMoves, 1);
      expect(engine.getRemainingArrows().length, 1);

      // Second Undo
      final undo2 = engine.undo();
      expect(undo2.success, isTrue);
      expect(undo2.restoredArrow?.id, 'a1');
      expect(engine.successfulMoves, 0);
      expect(engine.getRemainingArrows().length, 2);
    });

    test('resetLevel restores initial state and metrics', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 2,
        cols: 2,
        initialArrows: [
          Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
        ],
        parMoves: 1,
      );

      engine.startLevel(level);
      engine.moveArrow('a1');
      expect(engine.isLevelComplete(), isTrue);

      engine.resetLevel();
      expect(engine.status, GameStatus.playing);
      expect(engine.successfulMoves, 0);
      expect(engine.getRemainingArrows().length, 1);
      expect(engine.canUndo, isFalse);
    });
  });
}
