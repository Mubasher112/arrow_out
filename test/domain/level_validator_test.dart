import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/domain/level_validator.dart';
import 'package:arrow_path/domain/models/arrow.dart';
import 'package:arrow_path/domain/models/arrow_direction.dart';
import 'package:arrow_path/domain/models/level_definition.dart';

void main() {
  group('LevelValidator', () {
    test('valid level passes validation', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        initialArrows: [
          Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
        ],
        parMoves: 1,
      );

      final result = LevelValidator.validate(level);
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('catches duplicate arrow IDs', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        initialArrows: [
          Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
          Arrow(id: 'a1', row: 1, column: 1, direction: ArrowDirection.down),
        ],
        parMoves: 2,
      );

      final result = LevelValidator.validate(level);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('Duplicate arrow ID')), isTrue);
    });

    test('catches out of bounds arrow position', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        initialArrows: [
          Arrow(id: 'a1', row: 5, column: 0, direction: ArrowDirection.up),
        ],
        parMoves: 1,
      );

      final result = LevelValidator.validate(level);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('out of bounds')), isTrue);
    });

    test('catches cell overlaps', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        initialArrows: [
          Arrow(id: 'a1', row: 1, column: 1, direction: ArrowDirection.up),
          Arrow(id: 'a2', row: 1, column: 1, direction: ArrowDirection.down),
        ],
        parMoves: 2,
      );

      final result = LevelValidator.validate(level);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('occupied by multiple arrows')), isTrue);
    });

    test('catches empty level', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        initialArrows: [],
        parMoves: 0,
      );

      final result = LevelValidator.validate(level);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('contains no arrows')), isTrue);
    });

    test('catches unsolvable puzzle deadlock', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 2,
        cols: 2,
        initialArrows: [
          Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.right),
          Arrow(id: 'a2', row: 0, column: 1, direction: ArrowDirection.left),
        ],
        parMoves: 2,
      );

      final result = LevelValidator.validate(level);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('unsolvable')), isTrue);
    });
  });
}
