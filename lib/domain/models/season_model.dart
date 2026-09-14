/// Model representing a competitive leaderboard season.
class SeasonModel {
  final String seasonId;
  final String title;
  final String theme;
  final String startAtIso;
  final String endAtIso;

  const SeasonModel({
    required this.seasonId,
    required this.title,
    required this.theme,
    required this.startAtIso,
    required this.endAtIso,
  });

  Map<String, dynamic> toJson() => {
        'seasonId': seasonId,
        'title': title,
        'theme': theme,
        'startAtIso': startAtIso,
        'endAtIso': endAtIso,
      };

  factory SeasonModel.fromJson(Map<String, dynamic> json) => SeasonModel(
        seasonId: json['seasonId'] as String,
        title: json['title'] as String,
        theme: json['theme'] as String,
        startAtIso: json['startAtIso'] as String,
        endAtIso: json['endAtIso'] as String,
      );
}
