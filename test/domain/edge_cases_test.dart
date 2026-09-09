import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/domain/game_engine.dart';
import 'package:arrow_path/domain/models/arrow.dart';
import 'package:arrow_path/domain/models/arrow_direction.dart';
import 'package:arrow_path/domain/models/game_status.dart';
import 'package:arrow_path/domain/models/level_definition.dart';

void main() {
  late GameEngine engine;

  setUp(() {
    engine = GameEngine();
  });

  group('Edge Cases', () {
    test('one-arrow puzzle', () {
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
      expect(engine.getRemainingArrows().length, 1);

      final result = engine.moveArrow('a1');
      expect(result.isValid, isTrue);
      expect(engine.isLevelComplete(), isTrue);
      expect(engine.status, GameStatus.completed);
    });

    test('arrow pointing toward empty board edge', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 4,
        cols: 4,
        initialArrows: [
          Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
        ],
        parMoves: 1,
      );

      engine.startLevel(level);
      expect(engine.canMove(engine.board!.getArrowById('a1')!), isTrue);
    });

    test('directly adjacent arrows blocking each other', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        initialArrows: [
          Arrow(id: 'a1', row: 1, column: 1, direction: ArrowDirection.right), // points to (1,2)
          Arrow(id: 'a2', row: 1, column: 2, direction: ArrowDirection.right), // points off board
        ],
        parMoves: 2,
      );

      engine.startLevel(level);

      // a1 is blocked by directly adjacent a2
      final res1 = engine.moveArrow('a1');
      expect(res1.isValid, isFalse);
      expect(res1.blockingArrow?.id, 'a2');

      // Remove a2 first
      final res2 = engine.moveArrow('a2');
      expect(res2.isValid, isTrue);

      // Now a1 is clear!
      engine.resetBlockedState('a1');
      final res3 = engine.moveArrow('a1');
      expect(res3.isValid, isTrue);
      expect(engine.isLevelComplete(), isTrue);
    });

    test('long chain of dependent arrows', () {
      // 4 arrows in a row: a1 -> a2 -> a3 -> a4 -> edge
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 1,
        cols: 4,
        initialArrows: [
          Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.right),
          Arrow(id: 'a2', row: 0, column: 1, direction: ArrowDirection.right),
          Arrow(id: 'a3', row: 0, column: 2, direction: ArrowDirection.right),
          Arrow(id: 'a4', row: 0, column: 3, direction: ArrowDirection.right),
        ],
        parMoves: 4,
      );

      engine.startLevel(level);

      // Tapping a1, a2, a3 fail
      expect(engine.moveArrow('a1').isValid, isFalse);
      expect(engine.moveArrow('a2').isValid, isFalse);
      expect(engine.moveArrow('a3').isValid, isFalse);

      // Solve in reverse sequence: a4, a3, a2, a1
      expect(engine.moveArrow('a4').isValid, isTrue);
      engine.resetBlockedState('a3');
      expect(engine.moveArrow('a3').isValid, isTrue);
      engine.resetBlockedState('a2');
      expect(engine.moveArrow('a2').isValid, isTrue);
      engine.resetBlockedState('a1');
      expect(engine.moveArrow('a1').isValid, isTrue);

      expect(engine.isLevelComplete(), isTrue);
    });

    test('maximum supported board size (8x8)', () {
      final arrows = List.generate(
        8,
        (i) => Arrow(
          id: 'a_${i + 1}',
          row: i,
          column: i,
          direction: ArrowDirection.up,
        ),
      );

      final level = LevelDefinition(
        levelNumber: 1,
        rows: 8,
        cols: 8,
        initialArrows: arrows,
        parMoves: 8,
      );

      engine.startLevel(level);
      expect(engine.board!.rows, 8);
      expect(engine.board!.cols, 8);
      expect(engine.getRemainingArrows().length, 8);
    });

    test('undo after completing a level', () {
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

      final undoRes = engine.undo();
      expect(undoRes.success, isTrue);
      expect(engine.isLevelComplete(), isFalse);
      expect(engine.status, GameStatus.playing);
      expect(engine.getRemainingArrows().length, 1);
    });

    test('multiple undos and reset after undo', () {
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
      engine.moveArrow('a2');
      expect(engine.successfulMoves, 2);

      // Perform 2 undos
      engine.undo();
      engine.undo();
      expect(engine.successfulMoves, 0);
      expect(engine.getRemainingArrows().length, 2);

      // Move again then reset
      engine.moveArrow('a1');
      expect(engine.successfulMoves, 1);

      engine.resetLevel();
      expect(engine.successfulMoves, 0);
      expect(engine.canUndo, isFalse);
      expect(engine.getRemainingArrows().length, 2);
    });
  });
}
