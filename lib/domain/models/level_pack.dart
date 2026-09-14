/// Data-driven level pack container supporting content versioning.
class LevelPack {
  final String id;
  final String title;
  final String description;
  final int startLevel;
  final int endLevel;
  final int contentVersion;
  final Map<String, dynamic> unlockRequirements;

  const LevelPack({
    required this.id,
    required this.title,
    required this.description,
    required this.startLevel,
    required this.endLevel,
    this.contentVersion = 1,
    this.unlockRequirements = const {},
  });

  int get totalLevels => endLevel - startLevel + 1;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startLevel': startLevel,
        'endLevel': endLevel,
        'contentVersion': contentVersion,
        'unlockRequirements': unlockRequirements,
      };

  factory LevelPack.fromJson(Map<String, dynamic> json) => LevelPack(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        startLevel: json['startLevel'] as int,
        endLevel: json['endLevel'] as int,
        contentVersion: (json['contentVersion'] ?? 1) as int,
        unlockRequirements: (json['unlockRequirements'] as Map<String, dynamic>?) ?? const {},
      );
}
