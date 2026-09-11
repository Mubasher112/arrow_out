/// Model representing persistent user monetization entitlements.
class EntitlementModel {
  final bool adsRemoved;
  final int? purchasedAt;
  final String? transactionId;

  const EntitlementModel({
    this.adsRemoved = false,
    this.purchasedAt,
    this.transactionId,
  });

  EntitlementModel copyWith({
    bool? adsRemoved,
    int? purchasedAt,
    String? transactionId,
  }) {
    return EntitlementModel(
      adsRemoved: adsRemoved ?? this.adsRemoved,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  Map<String, dynamic> toJson() => {
        'adsRemoved': adsRemoved,
        'purchasedAt': purchasedAt,
        'transactionId': transactionId,
      };

  factory EntitlementModel.fromJson(Map<String, dynamic> json) =>
      EntitlementModel(
        adsRemoved: (json['adsRemoved'] ?? false) as bool,
        purchasedAt: json['purchasedAt'] as int?,
        transactionId: json['transactionId'] as String?,
      );
}
