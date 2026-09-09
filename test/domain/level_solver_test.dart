import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/domain/level_generator.dart';
import 'package:arrow_path/domain/level_solver.dart';
import 'package:arrow_path/domain/models/arrow.dart';
import 'package:arrow_path/domain/models/arrow_direction.dart';
import 'package:arrow_path/domain/models/level_definition.dart';

void main() {
  group('LevelSolver Algorithm', () {
    test('solves simple 2x2 board', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 2,
        cols: 2,
        initialArrows: [
          Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
          Arrow(id: 'a2', row: 1, column: 1, direction: ArrowDirection.down),
        ],
        parMoves: 2,
      );

      final solution = LevelSolver.solve(level.toBoard());
      expect(solution, isNotNull);
      expect(solution!.length, 2);
    });

    test('detects unsolvable deadlock cycle', () {
      // a1 at (0,0) points down to (1,0); a2 at (1,0) points up to (0,0)
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 2,
        cols: 2,
        initialArrows: [
          Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.down),
          Arrow(id: 'a2', row: 1, column: 0, direction: ArrowDirection.up),
        ],
        parMoves: 2,
      );

      final solution = LevelSolver.solve(level.toBoard());
      expect(solution, isNull);
      expect(LevelSolver.isSolvable(level), isFalse);
    });
  });

  group('100 Playable Levels Validation', () {
    test('generates and verifies 100 levels are 100% solvable', () {
      final generator = LevelGenerator(seed: 2026);
      final levels = generator.generate100Levels();

      expect(levels.length, 100);

      for (final level in levels) {
        expect(level.initialArrows.isNotEmpty, isTrue,
            reason: 'Level ${level.levelNumber} must have arrows');
        expect(LevelSolver.isSolvable(level), isTrue,
            reason: 'Level ${level.levelNumber} must be solvable');
      }
    });

    test('saved assets/levels/levels.json contains 100 solvable levels', () {
      final file = File('assets/levels/levels.json');
      expect(file.existsSync(), isTrue, reason: 'levels.json asset file must exist');

      final jsonString = file.readAsStringSync();
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      expect(jsonList.length, 100);

      for (int i = 0; i < jsonList.length; i++) {
        final level = LevelDefinition.fromJson(jsonList[i] as Map<String, dynamic>);
        expect(level.levelNumber, i + 1);
        expect(LevelSolver.isSolvable(level), isTrue,
            reason: 'Asset level ${level.levelNumber} must be solvable');
      }
    });
  });
}
