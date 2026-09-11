/// Notification category preference toggles.
class NotificationSettings {
  final bool dailyRewards;
  final bool dailyChallenges;
  final bool events;
  final bool friendActivity;

  const NotificationSettings({
    this.dailyRewards = true,
    this.dailyChallenges = true,
    this.events = true,
    this.friendActivity = true,
  });

  NotificationSettings copyWith({
    bool? dailyRewards,
    bool? dailyChallenges,
    bool? events,
    bool? friendActivity,
  }) {
    return NotificationSettings(
      dailyRewards: dailyRewards ?? this.dailyRewards,
      dailyChallenges: dailyChallenges ?? this.dailyChallenges,
      events: events ?? this.events,
      friendActivity: friendActivity ?? this.friendActivity,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyRewards': dailyRewards,
        'dailyChallenges': dailyChallenges,
        'events': events,
        'friendActivity': friendActivity,
      };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        dailyRewards: (json['dailyRewards'] ?? true) as bool,
        dailyChallenges: (json['dailyChallenges'] ?? true) as bool,
        events: (json['events'] ?? true) as bool,
        friendActivity: (json['friendActivity'] ?? true) as bool,
      );
}
