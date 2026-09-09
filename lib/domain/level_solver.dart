import 'models/arrow.dart';
import 'models/arrow_state.dart';
import 'models/game_board.dart';
import 'models/level_definition.dart';

/// Fast, exact solver algorithm for Arrow extraction puzzles.
///
/// Key Property of Extraction Puzzles:
/// Removing an unblocked arrow frees up grid space and NEVER blocks any other arrow.
/// Therefore, greedily extracting any available unblocked arrow will find a valid clearing sequence
/// if the puzzle is solvable, operating in linear time O(N^2) instead of exponential DFS.
class LevelSolver {
  /// Check whether an arrow's ray to the boundary is unobstructed on [board].
  static bool isPathClear(GameBoard board, Arrow arrow) {
    int r = arrow.row + arrow.direction.dRow;
    int c = arrow.column + arrow.direction.dCol;

    while (!board.isOutOfBounds(r, c)) {
      final occupant = board.getArrowAt(r, c);
      if (occupant != null) {
        return false;
      }
      r += arrow.direction.dRow;
      c += arrow.direction.dCol;
    }
    return true;
  }

  /// Solves a puzzle in O(N^2) time.
  /// Returns the ordered move sequence of arrow IDs if solvable, or `null` if unsolvable.
  static List<String>? solve(GameBoard board) {
    final List<String> moveSequence = [];
    GameBoard currentBoard = board;

    while (!currentBoard.isCleared) {
      // Find the first unblocked arrow
      Arrow? unblockedArrow;
      for (final arrow in currentBoard.arrows) {
        if (arrow.state != ArrowState.removed && isPathClear(currentBoard, arrow)) {
          unblockedArrow = arrow;
          break;
        }
      }

      // If no unblocked arrow exists and board is not cleared, puzzle cannot be solved.
      if (unblockedArrow == null) {
        return null;
      }

      // Extract the unblocked arrow
      moveSequence.add(unblockedArrow.id);
      final updatedArrows = currentBoard.arrows.map((a) {
        if (a.id == unblockedArrow!.id) {
          return a.copyWith(state: ArrowState.removed);
        }
        return a;
      }).toList();

      currentBoard = currentBoard.copyWith(arrows: updatedArrows);
    }

    return moveSequence;
  }

  /// Check if a LevelDefinition is 100% solvable.
  static bool isSolvable(LevelDefinition level) {
    return solve(level.toBoard()) != null;
  }
}
