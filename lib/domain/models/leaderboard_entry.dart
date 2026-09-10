/// Model representing a player's calculated ranking entry on a leaderboard.
class LeaderboardEntry {
  final int rank;
  final String playerId;
  final String displayName;
  final String? avatarUrl;
  final int totalStars;
  final int completedLevels;
  final int bestMovePerformance;

  const LeaderboardEntry({
    required this.rank,
    required this.playerId,
    required this.displayName,
    this.avatarUrl,
    required this.totalStars,
    required this.completedLevels,
    required this.bestMovePerformance,
  });

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'playerId': playerId,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'totalStars': totalStars,
        'completedLevels': completedLevels,
        'bestMovePerformance': bestMovePerformance,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        rank: json['rank'] as int,
        playerId: json['playerId'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        totalStars: (json['totalStars'] ?? 0) as int,
        completedLevels: (json['completedLevels'] ?? 0) as int,
        bestMovePerformance: (json['bestMovePerformance'] ?? 0) as int,
      );
}
