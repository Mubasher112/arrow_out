/// Immutable model representing an achievement milestone.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int target;
  final int progress;
  final bool isUnlocked;
  final int? unlockedAt;
  final int coinReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.target,
    this.progress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.coinReward,
  });

  Achievement copyWith({
    int? progress,
    bool? isUnlocked,
    int? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      iconName: iconName,
      target: target,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      coinReward: coinReward,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconName': iconName,
        'target': target,
        'progress': progress,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt,
        'coinReward': coinReward,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        iconName: json['iconName'] as String,
        target: json['target'] as int,
        progress: (json['progress'] ?? 0) as int,
        isUnlocked: (json['isUnlocked'] ?? false) as bool,
        unlockedAt: json['unlockedAt'] as int?,
        coinReward: (json['coinReward'] ?? 50) as int,
      );
}
