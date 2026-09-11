/// Individual objective inside a limited-time event.
class EventObjective {
  final String id;
  final String description;
  final int target;
  final int progress;
  final bool isCompleted;

  const EventObjective({
    required this.id,
    required this.description,
    required this.target,
    this.progress = 0,
    this.isCompleted = false,
  });

  EventObjective copyWith({
    int? progress,
    bool? isCompleted,
  }) {
    return EventObjective(
      id: id,
      description: description,
      target: target,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'target': target,
        'progress': progress,
        'isCompleted': isCompleted,
      };

  factory EventObjective.fromJson(Map<String, dynamic> json) => EventObjective(
        id: json['id'] as String,
        description: json['description'] as String,
        target: json['target'] as int,
        progress: (json['progress'] ?? 0) as int,
        isCompleted: (json['isCompleted'] ?? false) as bool,
      );
}
