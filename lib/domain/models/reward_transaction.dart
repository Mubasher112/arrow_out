enum RewardType {
  levelComplete,
  threeStarBonus,
  dailyChallenge,
  streakMilestone,
  achievementUnlock,
}

/// Transaction record representing coin reward events.
class RewardTransaction {
  final String id;
  final RewardType type;
  final int amount;
  final int timestamp;
  final String referenceId;

  const RewardTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.referenceId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'timestamp': timestamp,
        'referenceId': referenceId,
      };

  factory RewardTransaction.fromJson(Map<String, dynamic> json) =>
      RewardTransaction(
        id: json['id'] as String,
        type: RewardType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => RewardType.levelComplete,
        ),
        amount: json['amount'] as int,
        timestamp: json['timestamp'] as int,
        referenceId: json['referenceId'] as String,
      );
}
