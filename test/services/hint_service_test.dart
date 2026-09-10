import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/domain/game_engine.dart';
import 'package:arrow_path/domain/models/arrow.dart';
import 'package:arrow_path/domain/models/arrow_direction.dart';
import 'package:arrow_path/domain/models/level_definition.dart';
import 'package:arrow_path/services/hint_service.dart';
import 'package:arrow_path/services/tutorial_service.dart';

void main() {
  group('TutorialService', () {
    test('returns correct tutorial hints for levels 1-3', () {
      expect(TutorialService.getTutorialMessage(1), 'Tap an arrow to move it.');
      expect(TutorialService.getTutorialMessage(2), 'An arrow can only move when its path is clear.');
      expect(TutorialService.getTutorialMessage(3), 'Clear the blocking arrows first.');
      expect(TutorialService.getTutorialMessage(4), isNull);
    });
  });

  group('HintService', () {
    test('provides valid unblocked arrow hint', () {
      const level = LevelDefinition(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        initialArrows: [
          Arrow(id: 'a1', row: 1, column: 1, direction: ArrowDirection.up), // blocked by a2
          Arrow(id: 'a2', row: 0, column: 1, direction: ArrowDirection.right), // clear
        ],
        parMoves: 2,
      );

      final engine = GameEngine();
      engine.startLevel(level);

      final hintService = HintService();
      final result = hintService.getHint(engine);

      expect(result.hasAvailableHint, isTrue);
      expect(result.recommendedArrow?.id, 'a2');
      expect(hintService.hintsUsedInSession, 1);
    });
  });
}
