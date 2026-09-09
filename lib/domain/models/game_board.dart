import 'arrow.dart';
import 'arrow_state.dart';

/// Immutable representation of the puzzle grid board.
class GameBoard {
  final int rows;
  final int cols;
  final List<Arrow> arrows;

  // $O(1)$ grid cell map cache for active arrows
  final Map<String, Arrow> _gridMap;

  GameBoard({
    required this.rows,
    required this.cols,
    required this.arrows,
  }) : _gridMap = _buildGridMap(arrows);

  static Map<String, Arrow> _buildGridMap(List<Arrow> arrows) {
    final map = <String, Arrow>{};
    for (final arrow in arrows) {
      if (arrow.state != ArrowState.removed) {
        map['${arrow.row},${arrow.column}'] = arrow;
      }
    }
    return map;
  }

  /// Check if coordinates are out of bounds.
  bool isOutOfBounds(int row, int col) {
    return row < 0 || row >= rows || col < 0 || col >= cols;
  }

  /// $O(1)$ lookup for active arrow at grid position (row, col).
  Arrow? getArrowAt(int row, int col) {
    return _gridMap['$row,$col'];
  }

  /// Get active arrow by ID.
  Arrow? getArrowById(String id) {
    for (final arrow in arrows) {
      if (arrow.id == id && arrow.state != ArrowState.removed) {
        return arrow;
      }
    }
    return null;
  }

  /// Get all active arrows in a specific row.
  List<Arrow> getArrowsInRow(int row) {
    return arrows
        .where((a) => a.state != ArrowState.removed && a.row == row)
        .toList();
  }

  /// Get all active arrows in a specific column.
  List<Arrow> getArrowsInColumn(int col) {
    return arrows
        .where((a) => a.state != ArrowState.removed && a.column == col)
        .toList();
  }

  /// Add a new arrow to the board.
  GameBoard addArrow(Arrow arrow) {
    final updatedList = List<Arrow>.from(arrows)..add(arrow);
    return copyWith(arrows: updatedList);
  }

  /// Remove an arrow by ID or set its state to removed.
  GameBoard removeArrow(String arrowId) {
    final updatedList = arrows.map((a) {
      if (a.id == arrowId) {
        return a.copyWith(state: ArrowState.removed);
      }
      return a;
    }).toList();
    return copyWith(arrows: updatedList);
  }

  /// Number of active remaining arrows on the board.
  int get activeArrowCount => _gridMap.length;

  /// Check if board is cleared (no active arrows left).
  bool get isCleared => _gridMap.isEmpty;

  GameBoard copyWith({
    int? rows,
    int? cols,
    List<Arrow>? arrows,
  }) {
    return GameBoard(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      arrows: arrows ?? List<Arrow>.from(this.arrows),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rows': rows,
      'cols': cols,
      'arrows': arrows.map((a) => a.toJson()).toList(),
    };
  }

  factory GameBoard.fromJson(Map<String, dynamic> json) {
    return GameBoard(
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      arrows: (json['arrows'] as List)
          .map((item) => Arrow.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
