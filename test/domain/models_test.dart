import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/domain/models/arrow.dart';
import 'package:arrow_path/domain/models/arrow_direction.dart';
import 'package:arrow_path/domain/models/arrow_state.dart';
import 'package:arrow_path/domain/models/difficulty.dart';
import 'package:arrow_path/domain/models/game_board.dart';
import 'package:arrow_path/domain/models/game_status.dart';
import 'package:arrow_path/domain/models/level_definition.dart';
import 'package:arrow_path/domain/models/move_result.dart';
import 'package:arrow_path/domain/models/undo_result.dart';
import 'package:arrow_path/domain/models/validation_result.dart';

void main() {
  group('ArrowDirection opposite', () {
    test('opposite directions', () {
      expect(ArrowDirection.up.opposite, ArrowDirection.down);
      expect(ArrowDirection.down.opposite, ArrowDirection.up);
      expect(ArrowDirection.left.opposite, ArrowDirection.right);
      expect(ArrowDirection.right.opposite, ArrowDirection.left);
    });
  });

  group('GameBoard row/col queries and modifications', () {
    test('getArrowsInRow and getArrowsInColumn', () {
      const arrow1 = Arrow(id: 'a1', row: 1, column: 0, direction: ArrowDirection.right);
      const arrow2 = Arrow(id: 'a2', row: 1, column: 2, direction: ArrowDirection.left);
      const arrow3 = Arrow(id: 'a3', row: 2, column: 2, direction: ArrowDirection.up);

      final board = GameBoard(
        rows: 4,
        cols: 4,
        arrows: [arrow1, arrow2, arrow3],
      );

      final row1Arrows = board.getArrowsInRow(1);
      expect(row1Arrows.length, 2);
      expect(row1Arrows, containsAll([arrow1, arrow2]));

      final col2Arrows = board.getArrowsInColumn(2);
      expect(col2Arrows.length, 2);
      expect(col2Arrows, containsAll([arrow2, arrow3]));
    });

    test('addArrow and removeArrow', () {
      const arrow1 = Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.down);
      var board = GameBoard(rows: 3, cols: 3, arrows: [arrow1]);

      expect(board.activeArrowCount, 1);

      const arrow2 = Arrow(id: 'a2', row: 1, column: 1, direction: ArrowDirection.right);
      board = board.addArrow(arrow2);
      expect(board.activeArrowCount, 2);

      board = board.removeArrow('a1');
      expect(board.activeArrowCount, 1);
      expect(board.getArrowAt(0, 0), isNull);
      expect(board.getArrowAt(1, 1), equals(arrow2));
    });
  });

  group('Result Models', () {
    test('MoveResult and UndoResult and ValidationResult', () {
      const arrow = Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.right);
      final moveRes = MoveResult(
        isValid: true,
        selectedArrow: arrow,
        direction: ArrowDirection.right,
        pathCells: [[0, 0], [0, 1]],
        resultingStatus: GameStatus.playing,
      );
      expect(moveRes.isValid, isTrue);

      final board = GameBoard(rows: 2, cols: 2, arrows: [arrow]);
      final undoRes = UndoResult(
        success: true,
        restoredArrow: arrow,
        board: board,
        moves: 0,
      );
      expect(undoRes.success, isTrue);

      final valValid = ValidationResult.valid();
      final valInvalid = ValidationResult.invalid(['Error']);
      expect(valValid.isValid, isTrue);
      expect(valInvalid.isValid, isFalse);
      expect(valInvalid.errors, contains('Error'));
    });
  });

  group('LevelDefinition with difficulty', () {
    test('JSON roundtrip with difficulty and metadata', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 4,
        cols: 4,
        initialArrows: [Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up)],
        parMoves: 1,
        difficulty: Difficulty.medium,
        metadata: {'author': 'Jules'},
      );

      final json = level.toJson();
      final restored = LevelDefinition.fromJson(json);

      expect(restored.difficulty, Difficulty.medium);
      expect(restored.metadata['author'], 'Jules');
    });
  });
}
