import '../domain/game_engine.dart';
import '../domain/models/arrow.dart';

/// Hint result object.
class HintResult {
  final Arrow? recommendedArrow;
  final bool hasAvailableHint;
  final String? message;

  const HintResult({
    required this.recommendedArrow,
    required this.hasAvailableHint,
    this.message,
  });
}

/// Service finding valid hint moves using game engine rules.
class HintService {
  int _hintsUsedInSession = 0;

  int get hintsUsedInSession => _hintsUsedInSession;

  /// Find recommended arrow move using the game engine solver.
  HintResult getHint(GameEngine engine) {
    final arrow = engine.getHint();
    if (arrow == null) {
      return const HintResult(
        recommendedArrow: null,
        hasAvailableHint: false,
        message: 'No valid move available',
      );
    }

    _hintsUsedInSession++;
    return HintResult(
      recommendedArrow: arrow,
      hasAvailableHint: true,
      message: 'Arrow ${arrow.id} is ready to exit!',
    );
  }

  void resetSession() {
    _hintsUsedInSession = 0;
  }
}
