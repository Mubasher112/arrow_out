import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/domain/level_generator.dart';
import 'package:arrow_path/domain/level_validator.dart';
import 'package:arrow_path/domain/models/difficulty.dart';

void main() {
  group('LevelGenerator Seed Determinism & Grid Sizes', () {
    test('same seed produces identical puzzle definition', () {
      final gen1 = LevelGenerator(seed: 12345);
      final gen2 = LevelGenerator(seed: 12345);

      final level1 = gen1.generateCustomLevel(
        levelNumber: 1,
        rows: 5,
        cols: 5,
        difficulty: Difficulty.medium,
      );

      final level2 = gen2.generateCustomLevel(
        levelNumber: 1,
        rows: 5,
        cols: 5,
        difficulty: Difficulty.medium,
      );

      expect(level1.rows, level2.rows);
      expect(level1.cols, level2.cols);
      expect(level1.initialArrows.length, level2.initialArrows.length);

      for (int i = 0; i < level1.initialArrows.length; i++) {
        expect(level1.initialArrows[i], equals(level2.initialArrows[i]));
      }
    });

    test('different seeds produce different puzzle layouts', () {
      final gen1 = LevelGenerator(seed: 1111);
      final gen2 = LevelGenerator(seed: 9999);

      final level1 = gen1.generateCustomLevel(
        levelNumber: 1,
        rows: 5,
        cols: 5,
        difficulty: Difficulty.medium,
      );

      final level2 = gen2.generateCustomLevel(
        levelNumber: 1,
        rows: 5,
        cols: 5,
        difficulty: Difficulty.medium,
      );

      bool differs = level1.initialArrows.length != level2.initialArrows.length;
      if (!differs) {
        for (int i = 0; i < level1.initialArrows.length; i++) {
          if (level1.initialArrows[i] != level2.initialArrows[i]) {
            differs = true;
            break;
          }
        }
      }

      expect(differs, isTrue);
    });

    test('supports grid sizes 4x4, 5x5, 6x6, 7x7, and 8x8 across all difficulties', () {
      final sizes = [4, 5, 6, 7, 8];
      final difficulties = Difficulty.values;

      int seedCounter = 100;
      for (final size in sizes) {
        for (final difficulty in difficulties) {
          final generator = LevelGenerator(seed: seedCounter++);
          final level = generator.generateCustomLevel(
            levelNumber: 1,
            rows: size,
            cols: size,
            difficulty: difficulty,
          );

          expect(level.rows, size);
          expect(level.cols, size);
          final validation = LevelValidator.validate(level);
          expect(validation.isValid, isTrue,
              reason: 'Generated ${size}x$size ${difficulty.name} puzzle must be valid');
        }
      }
    });
  });
}
