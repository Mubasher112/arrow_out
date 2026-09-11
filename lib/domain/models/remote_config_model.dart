/// Versioned remote configuration container with safe built-in defaults.
class RemoteConfigModel {
  final Map<String, bool> featureFlags;
  final int schemaVersion;
  final String lastUpdatedIso;

  const RemoteConfigModel({
    required this.featureFlags,
    this.schemaVersion = 1,
    required this.lastUpdatedIso,
  });

  bool isFeatureEnabled(String flagName) => featureFlags[flagName] ?? true;

  static final RemoteConfigModel defaultDefaults = RemoteConfigModel(
    featureFlags: const {
      'weeklyChallenges': true,
      'liveEvents': true,
      'notifications': true,
      'friendActivity': true,
      'dailyRewards': true,
    },
    schemaVersion: 1,
    lastUpdatedIso: '2026-09-10',
  );

  Map<String, dynamic> toJson() => {
        'featureFlags': featureFlags,
        'schemaVersion': schemaVersion,
        'lastUpdatedIso': lastUpdatedIso,
      };

  factory RemoteConfigModel.fromJson(Map<String, dynamic> json) => RemoteConfigModel(
        featureFlags: Map<String, bool>.from(json['featureFlags'] as Map? ?? {}),
        schemaVersion: (json['schemaVersion'] ?? 1) as int,
        lastUpdatedIso: json['lastUpdatedIso'] as String? ?? '2026-09-10',
      );
}
