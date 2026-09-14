/// Model representing account XP level progression separate from puzzle level.
class PlayerLevel {
  final int level;
  final int currentXp;

  const PlayerLevel({
    this.level = 1,
    this.currentXp = 0,
  });

  /// Required XP formula for next level: level * 250 XP
  int get requiredXpForNextLevel => level * 250;

  double get progressRatio => (currentXp / requiredXpForNextLevel).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'level': level,
        'currentXp': currentXp,
      };

  factory PlayerLevel.fromJson(Map<String, dynamic> json) => PlayerLevel(
        level: (json['level'] ?? 1) as int,
        currentXp: (json['currentXp'] ?? 0) as int,
      );
}
