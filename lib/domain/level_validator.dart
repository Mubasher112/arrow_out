import 'level_solver.dart';
import 'models/level_definition.dart';
import 'models/validation_result.dart';

/// Validator that checks puzzle rules, boundary constraints, and solvability.
class LevelValidator {
  static const int minDimension = 2;
  static const int maxDimension = 12;

  /// Validate a level definition and return a detailed ValidationResult.
  static ValidationResult validate(LevelDefinition level) {
    final List<String> errors = [];

    // Check board dimensions
    if (level.rows < minDimension || level.rows > maxDimension) {
      errors.add('Invalid row count: ${level.rows}. Must be between $minDimension and $maxDimension.');
    }
    if (level.cols < minDimension || level.cols > maxDimension) {
      errors.add('Invalid column count: ${level.cols}. Must be between $minDimension and $maxDimension.');
    }

    // Check non-empty arrow list
    if (level.initialArrows.isEmpty) {
      errors.add('Level contains no arrows.');
    }

    final Set<String> arrowIds = {};
    final Set<String> occupiedCells = {};

    for (final arrow in level.initialArrows) {
      // Check unique IDs
      if (arrowIds.contains(arrow.id)) {
        errors.add('Duplicate arrow ID found: ${arrow.id}.');
      }
      arrowIds.add(arrow.id);

      // Check bounds
      if (arrow.row < 0 || arrow.row >= level.rows ||
          arrow.column < 0 || arrow.column >= level.cols) {
        errors.add('Arrow ${arrow.id} position [${arrow.row}, ${arrow.column}] is out of bounds for board size ${level.rows}x${level.cols}.');
      }

      // Check overlaps
      final cellKey = '${arrow.row},${arrow.column}';
      if (occupiedCells.contains(cellKey)) {
        errors.add('Cell [$cellKey] is occupied by multiple arrows.');
      }
      occupiedCells.add(cellKey);
    }

    if (errors.isNotEmpty) {
      return ValidationResult.invalid(errors);
    }

    // Check puzzle solvability
    final isSolvable = LevelSolver.isSolvable(level);
    if (!isSolvable) {
      errors.add('Puzzle is unsolvable (contains deadlocks or blocking cycles).');
      return ValidationResult.invalid(errors);
    }

    return ValidationResult.valid();
  }
}
