import 'reward_transaction.dart';

/// 7-day daily login calendar reward entry.
class DailyLoginReward {
  final int day;
  final RewardType type;
  final int amount;
  final String? claimedAtIso;

  const DailyLoginReward({
    required this.day,
    required this.type,
    required this.amount,
    this.claimedAtIso,
  });

  bool get isClaimed => claimedAtIso != null;

  DailyLoginReward copyWith({
    String? claimedAtIso,
  }) {
    return DailyLoginReward(
      day: day,
      type: type,
      amount: amount,
      claimedAtIso: claimedAtIso ?? this.claimedAtIso,
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'type': type.name,
        'amount': amount,
        'claimedAtIso': claimedAtIso,
      };

  factory DailyLoginReward.fromJson(Map<String, dynamic> json) => DailyLoginReward(
        day: json['day'] as int,
        type: RewardType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => RewardType.levelComplete,
        ),
        amount: json['amount'] as int,
        claimedAtIso: json['claimedAtIso'] as String?,
      );
}
