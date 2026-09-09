import 'package:flutter/foundation.dart';
import 'models/arrow.dart';
import 'models/arrow_direction.dart';
import 'models/arrow_state.dart';
import 'models/game_board.dart';
import 'models/game_status.dart';
import 'models/level_definition.dart';
import 'models/move_result.dart';
import 'models/undo_result.dart';

/// State snapshot for undo operations.
class _EngineSnapshot {
  final GameBoard board;
  final Arrow removedArrow;
  final int totalMoves;
  final int successfulMoves;
  final int failedAttempts;

  const _EngineSnapshot({
    required this.board,
    required this.removedArrow,
    required this.totalMoves,
    required this.successfulMoves,
    required this.failedAttempts,
  });
}

/// Central Puzzle & Game Engine managing game rules and state transitions.
class GameEngine extends ChangeNotifier {
  LevelDefinition? _currentLevel;
  GameBoard? _board;
  GameStatus _status = GameStatus.loading;

  int _totalMoves = 0;
  int _successfulMoves = 0;
  int _failedAttempts = 0;

  final List<_EngineSnapshot> _undoStack = [];
  String? _lastTappedArrowId;

  LevelDefinition? get currentLevel => _currentLevel;
  GameBoard? get board => _board;
  GameStatus get status => _status;

  int get totalMoves => _totalMoves;
  int get successfulMoves => _successfulMoves;
  int get failedAttempts => _failedAttempts;
  int get moves => _successfulMoves; // Default move count = successful extractions

  bool get canUndo => _undoStack.isNotEmpty;
  String? get lastTappedArrowId => _lastTappedArrowId;

  /// Start a level in the engine.
  void startLevel(LevelDefinition level) {
    _currentLevel = level;
    _board = level.toBoard();
    _status = GameStatus.playing;
    _totalMoves = 0;
    _successfulMoves = 0;
    _failedAttempts = 0;
    _undoStack.clear();
    _lastTappedArrowId = null;
    notifyListeners();
  }

  /// Alias for startLevel to maintain compatibility.
  void loadLevel(LevelDefinition level) => startLevel(level);

  /// Start or resume game playing status.
  void startGame() {
    if (_status == GameStatus.ready || _status == GameStatus.paused) {
      _status = GameStatus.playing;
      notifyListeners();
    }
  }

  /// Pause the game.
  void pauseGame() {
    if (_status == GameStatus.playing) {
      _status = GameStatus.paused;
      notifyListeners();
    }
  }

  /// Resume from paused state.
  void resumeGame() {
    if (_status == GameStatus.paused) {
      _status = GameStatus.playing;
      notifyListeners();
    }
  }

  /// Check whether a specific arrow can legally move and exit the board.
  bool canMove(Arrow arrow) {
    if (_board == null || arrow.state == ArrowState.removed) return false;
    return isPathClear(_board!, arrow);
  }

  /// Raycast along arrow direction to check if path to boundary is unobstructed.
  bool isPathClear(GameBoard board, Arrow arrow) {
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

  /// Compute the ray path cells from arrow position outward to board edge.
  List<List<int>> getRayPathCells(GameBoard board, Arrow arrow) {
    final List<List<int>> path = [];
    int r = arrow.row + arrow.direction.dRow;
    int c = arrow.column + arrow.direction.dCol;

    while (!board.isOutOfBounds(r, c)) {
      path.add([r, c]);
      r += arrow.direction.dRow;
      c += arrow.direction.dCol;
    }

    return path;
  }

  /// Find blocking arrow along ray path if any.
  Arrow? getBlockingArrow(GameBoard board, Arrow arrow) {
    int r = arrow.row + arrow.direction.dRow;
    int c = arrow.column + arrow.direction.dCol;

    while (!board.isOutOfBounds(r, c)) {
      final occupant = board.getArrowAt(r, c);
      if (occupant != null) {
        return occupant;
      }
      r += arrow.direction.dRow;
      c += arrow.direction.dCol;
    }

    return null;
  }

  /// Execute an arrow move attempt by ID. Returns structured [MoveResult].
  MoveResult moveArrow(String arrowId) {
    if (_board == null || (_status != GameStatus.playing && _status != GameStatus.ready)) {
      const fallbackArrow = Arrow(id: '', row: 0, column: 0, direction: ArrowDirection.up);
      return MoveResult(
        isValid: false,
        selectedArrow: fallbackArrow,
        direction: ArrowDirection.up,
        pathCells: const [],
        resultingStatus: _status,
        message: 'Game is not in active playing state',
      );
    }

    if (_status == GameStatus.ready) {
      _status = GameStatus.playing;
    }

    final arrow = _board!.getArrowById(arrowId);
    if (arrow == null || arrow.state == ArrowState.removed) {
      const fallbackArrow = Arrow(id: '', row: 0, column: 0, direction: ArrowDirection.up);
      return MoveResult(
        isValid: false,
        selectedArrow: fallbackArrow,
        direction: ArrowDirection.up,
        pathCells: const [],
        resultingStatus: _status,
        message: 'Arrow not found or already removed',
      );
    }

    _lastTappedArrowId = arrowId;
    _totalMoves++;

    final path = getRayPathCells(_board!, arrow);
    final blocking = getBlockingArrow(_board!, arrow);

    if (blocking == null) {
      // Valid move! Save snapshot to undo stack
      _undoStack.add(_EngineSnapshot(
        board: _board!,
        removedArrow: arrow,
        totalMoves: _totalMoves - 1,
        successfulMoves: _successfulMoves,
        failedAttempts: _failedAttempts,
      ));

      // Remove arrow from active board
      _board = _board!.removeArrow(arrowId);
      _successfulMoves++;

      final isComplete = _board!.isCleared;
      if (isComplete) {
        _status = GameStatus.completed;
      }

      notifyListeners();

      return MoveResult(
        isValid: true,
        selectedArrow: arrow,
        direction: arrow.direction,
        pathCells: path,
        resultingStatus: _status,
      );
    } else {
      // Invalid / blocked move
      _failedAttempts++;

      // Temporarily set arrow state to blocked for shake feedback
      final updatedArrows = _board!.arrows.map((a) {
        if (a.id == arrowId) return a.copyWith(state: ArrowState.blocked);
        return a;
      }).toList();

      _board = _board!.copyWith(arrows: updatedArrows);
      notifyListeners();

      return MoveResult(
        isValid: false,
        selectedArrow: arrow,
        blockingArrow: blocking,
        direction: arrow.direction,
        pathCells: path,
        resultingStatus: _status,
        message: 'Path blocked by arrow ${blocking.id}',
      );
    }
  }

  /// Alias for UI tap handlers.
  MoveResult tapArrow(String arrowId) => moveArrow(arrowId);

  /// Reset blocked state on arrow after feedback animation completes.
  void resetBlockedState(String arrowId) {
    if (_board == null) return;
    final arrow = _board!.getArrowById(arrowId);
    if (arrow != null && arrow.state == ArrowState.blocked) {
      final updatedArrows = _board!.arrows.map((a) {
        if (a.id == arrowId) return a.copyWith(state: ArrowState.idle);
        return a;
      }).toList();
      _board = _board!.copyWith(arrows: updatedArrows);
      notifyListeners();
    }
  }

  /// Undo the last valid move.
  UndoResult undo() {
    if (_board == null || _undoStack.isEmpty) {
      return UndoResult(
        success: false,
        board: _board ?? const GameBoard(rows: 0, cols: 0, arrows: []),
        moves: _successfulMoves,
        message: 'Nothing to undo',
      );
    }

    final snapshot = _undoStack.removeLast();
    _board = snapshot.board;
    _totalMoves = snapshot.totalMoves;
    _successfulMoves = snapshot.successfulMoves;
    _failedAttempts = snapshot.failedAttempts;

    if (_status == GameStatus.completed) {
      _status = GameStatus.playing;
    }

    _lastTappedArrowId = null;
    notifyListeners();

    return UndoResult(
      success: true,
      restoredArrow: snapshot.removedArrow,
      board: _board!,
      moves: _successfulMoves,
    );
  }

  /// Reset level to initial state.
  void resetLevel() {
    if (_currentLevel != null) {
      startLevel(_currentLevel!);
    }
  }

  /// Alias for restartLevel.
  void restartLevel() => resetLevel();

  /// Get list of active remaining arrows on board.
  List<Arrow> getRemainingArrows() {
    if (_board == null) return [];
    return _board!.arrows.where((a) => a.state != ArrowState.removed).toList();
  }

  /// Check if level is completed.
  bool isLevelComplete() => _board?.isCleared ?? false;

  /// Find valid unblocked move hint.
  Arrow? getHint() {
    if (_board == null) return null;
    final remaining = getRemainingArrows();
    for (final arrow in remaining) {
      if (canMove(arrow)) {
        return arrow;
      }
    }
    return null;
  }
}
