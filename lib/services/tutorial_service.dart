/// Service providing first-time gameplay tutorial instructions.
class TutorialService {
  /// Get tutorial message for specific level number if applicable.
  static String? getTutorialMessage(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return 'Tap an arrow to move it.';
      case 2:
        return 'An arrow can only move when its path is clear.';
      case 3:
        return 'Clear the blocking arrows first.';
      default:
        return null;
    }
  }
}
