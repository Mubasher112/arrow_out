/// A/B testing experiment configuration model.
class ExperimentModel {
  final String id;
  final String variant; // 'A' or 'B'
  final String startAtIso;
  final String endAtIso;

  const ExperimentModel({
    required this.id,
    required this.variant,
    required this.startAtIso,
    required this.endAtIso,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'variant': variant,
        'startAtIso': startAtIso,
        'endAtIso': endAtIso,
      };

  factory ExperimentModel.fromJson(Map<String, dynamic> json) => ExperimentModel(
        id: json['id'] as String,
        variant: json['variant'] as String,
        startAtIso: json['startAtIso'] as String,
        endAtIso: json['endAtIso'] as String,
      );
}
