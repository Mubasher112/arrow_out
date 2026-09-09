import 'arrow.dart';
import 'game_board.dart';

/// Structured result returned when an undo operation is requested.
class UndoResult {
  final bool success;
  final Arrow? restoredArrow;
  final GameBoard board;
  final int moves;
  final String? message;

  const UndoResult({
    required this.success,
    this.restoredArrow,
    required this.board,
    required this.moves,
    this.message,
  });
}
