import '../domain/models/level_definition.dart';

/// Server-authoritative anti-cheat score submission validator.
class AntiCheatResult {
  final bool isValid;
  final String? rejectionReason;

  const AntiCheatResult({
    required this.isValid,
    this.rejectionReason,
  });

  factory AntiCheatResult.valid() => const AntiCheatResult(isValid: true);
  factory AntiCheatResult.rejected(String reason) =>
      AntiCheatResult(isValid: false, rejectionReason: reason);
}

/// Service validating score submissions and detecting impossible move counts/completion times.
class AntiCheatService {
  /// Validate level completion submission.
  static AntiCheatResult validateSubmission({
    required LevelDefinition level,
    required int movesTaken,
    required int durationSeconds,
  }) {
    // 1. Duration check
    if (durationSeconds < 1) {
      return AntiCheatResult.rejected('Completion time impossible (<1s)');
    }

    // 2. Minimum moves check (moves cannot be less than arrow count)
    if (movesTaken < level.initialArrows.length) {
      return AntiCheatResult.rejected(
          'Move count ($movesTaken) is less than total arrows (${level.initialArrows.length})');
    }

    // 3. Move bounds check
    if (movesTaken > level.initialArrows.length * 10) {
      return AntiCheatResult.rejected('Move count unreasonably high');
    }

    return AntiCheatResult.valid();
  }
}
