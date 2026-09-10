/// Non-sensitive public social profile representation of a player.
class PlayerSocialProfile {
  final String playerId;
  final String displayName;
  final String? avatarUrl;
  final int totalStars;
  final int completedLevels;
  final int unlockedAchievements;
  final String? country;
  final int createdAt;

  const PlayerSocialProfile({
    required this.playerId,
    required this.displayName,
    this.avatarUrl,
    required this.totalStars,
    required this.completedLevels,
    required this.unlockedAchievements,
    this.country,
    required this.createdAt,
  });

  PlayerSocialProfile copyWith({
    String? displayName,
    String? avatarUrl,
    int? totalStars,
    int? completedLevels,
    int? unlockedAchievements,
    String? country,
  }) {
    return PlayerSocialProfile(
      playerId: playerId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalStars: totalStars ?? this.totalStars,
      completedLevels: completedLevels ?? this.completedLevels,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      country: country ?? this.country,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'totalStars': totalStars,
        'completedLevels': completedLevels,
        'unlockedAchievements': unlockedAchievements,
        'country': country,
        'createdAt': createdAt,
      };

  factory PlayerSocialProfile.fromJson(Map<String, dynamic> json) => PlayerSocialProfile(
        playerId: json['playerId'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        totalStars: (json['totalStars'] ?? 0) as int,
        completedLevels: (json['completedLevels'] ?? 0) as int,
        unlockedAchievements: (json['unlockedAchievements'] ?? 0) as int,
        country: json['country'] as String?,
        createdAt: (json['createdAt'] ?? 0) as int,
      );
}
