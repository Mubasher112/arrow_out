import 'arrow_direction.dart';
import 'arrow_state.dart';

/// Immutable model representing an arrow tile on the board.
class Arrow {
  final String id;
  final int row;
  final int column;
  final ArrowDirection direction;
  final ArrowState state;

  const Arrow({
    required this.id,
    required this.row,
    required this.column,
    required this.direction,
    this.state = ArrowState.idle,
  });

  Arrow copyWith({
    String? id,
    int? row,
    int? column,
    ArrowDirection? direction,
    ArrowState? state,
  }) {
    return Arrow(
      id: id ?? this.id,
      row: row ?? this.row,
      column: column ?? this.column,
      direction: direction ?? this.direction,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'row': row,
      'column': column,
      'direction': direction.name,
      'state': state.name,
    };
  }

  factory Arrow.fromJson(Map<String, dynamic> json) {
    return Arrow(
      id: json['id'] as String,
      row: json['row'] as int,
      column: json['column'] as int,
      direction: ArrowDirection.fromString(json['direction'] as String),
      state: ArrowState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => ArrowState.idle,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Arrow &&
        other.id == id &&
        other.row == row &&
        other.column == column &&
        other.direction == direction &&
        other.state == state;
  }

  @override
  int get hashCode => Object.hash(id, row, column, direction, state);

  @override
  String toString() {
    return 'Arrow(id: $id, pos: [$row, $column], dir: ${direction.name}, state: ${state.name})';
  }
}
