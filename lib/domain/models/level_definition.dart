import 'arrow.dart';
import 'difficulty.dart';
import 'game_board.dart';

/// Immutable definition of a puzzle level.
class LevelDefinition {
  final int levelNumber;
  final int rows;
  final int cols;
  final List<Arrow> initialArrows;
  final int parMoves;
  final Difficulty difficulty;
  final Map<String, dynamic> metadata;

  const LevelDefinition({
    required this.levelNumber,
    required this.rows,
    required this.cols,
    required this.initialArrows,
    required this.parMoves,
    this.difficulty = Difficulty.easy,
    this.metadata = const {},
  });

  /// Calculate stars earned based on moves taken.
  int calculateStars(int movesTaken) {
    if (movesTaken <= parMoves) return 3;
    if (movesTaken <= parMoves + 3) return 2;
    return 1;
  }

  /// Create an initial GameBoard instance for this level.
  GameBoard toBoard() {
    return GameBoard(
      rows: rows,
      cols: cols,
      arrows: List<Arrow>.from(initialArrows),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelNumber': levelNumber,
      'rows': rows,
      'cols': cols,
      'initialArrows': initialArrows.map((a) => a.toJson()).toList(),
      'parMoves': parMoves,
      'difficulty': difficulty.name,
      'metadata': metadata,
    };
  }

  factory LevelDefinition.fromJson(Map<String, dynamic> json) {
    return LevelDefinition(
      levelNumber: (json['levelNumber'] ?? json['id']) as int,
      rows: (json['rows'] ?? json['columns'] ?? 4) as int,
      cols: (json['cols'] ?? json['columns'] ?? 4) as int,
      initialArrows: ((json['initialArrows'] ?? json['arrows']) as List)
          .map((a) => Arrow.fromJson(a as Map<String, dynamic>))
          .toList(),
      parMoves: (json['parMoves'] ?? ((json['initialArrows'] ?? json['arrows']) as List).length) as int,
      difficulty: json['difficulty'] != null
          ? Difficulty.fromString(json['difficulty'].toString())
          : Difficulty.easy,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }
}
