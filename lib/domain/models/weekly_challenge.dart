/// Weekly objective challenge definition and player progress.
class WeeklyChallenge {
  final String id;
  final String title;
  final String description;
  final int target;
  final int progress;
  final int rewardAmount;
  final String startAtIso;
  final String endAtIso;
  final bool isClaimed;

  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    this.progress = 0,
    required this.rewardAmount,
    required this.startAtIso,
    required this.endAtIso,
    this.isClaimed = false,
  });

  bool get isCompleted => progress >= target;

  WeeklyChallenge copyWith({
    int? progress,
    bool? isClaimed,
  }) {
    return WeeklyChallenge(
      id: id,
      title: title,
      description: description,
      target: target,
      progress: progress ?? this.progress,
      rewardAmount: rewardAmount,
      startAtIso: startAtIso,
      endAtIso: endAtIso,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'target': target,
        'progress': progress,
        'rewardAmount': rewardAmount,
        'startAtIso': startAtIso,
        'endAtIso': endAtIso,
        'isClaimed': isClaimed,
      };

  factory WeeklyChallenge.fromJson(Map<String, dynamic> json) => WeeklyChallenge(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        target: json['target'] as int,
        progress: (json['progress'] ?? 0) as int,
        rewardAmount: json['rewardAmount'] as int,
        startAtIso: json['startAtIso'] as String,
        endAtIso: json['endAtIso'] as String,
        isClaimed: (json['isClaimed'] ?? false) as bool,
      );
}
