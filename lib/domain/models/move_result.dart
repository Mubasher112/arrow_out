import 'arrow.dart';
import 'arrow_direction.dart';
import 'game_status.dart';

/// Structured result returned when an arrow move is attempted.
class MoveResult {
  final bool isValid;
  final Arrow selectedArrow;
  final Arrow? blockingArrow;
  final ArrowDirection direction;
  final List<List<int>> pathCells; // List of [row, col] points along ray
  final GameStatus resultingStatus;
  final String? message;

  const MoveResult({
    required this.isValid,
    required this.selectedArrow,
    this.blockingArrow,
    required this.direction,
    required this.pathCells,
    required this.resultingStatus,
    this.message,
  });

  @override
  String toString() {
    return 'MoveResult(valid: $isValid, arrow: ${selectedArrow.id}, blocking: ${blockingArrow?.id}, status: ${resultingStatus.name})';
  }
}
