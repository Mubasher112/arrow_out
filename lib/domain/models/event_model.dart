import 'event_objective.dart';
import 'event_status.dart';

/// Model representing a limited-time live event.
class EventModel {
  final String id;
  final String title;
  final String description;
  final String startAtIso;
  final String endAtIso;
  final EventStatus status;
  final List<EventObjective> objectives;
  final int rewardAmount;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startAtIso,
    required this.endAtIso,
    required this.status,
    required this.objectives,
    required this.rewardAmount,
  });

  bool get isAllObjectivesCompleted =>
      objectives.isNotEmpty && objectives.every((o) => o.isCompleted);

  EventModel copyWith({
    EventStatus? status,
    List<EventObjective>? objectives,
  }) {
    return EventModel(
      id: id,
      title: title,
      description: description,
      startAtIso: startAtIso,
      endAtIso: endAtIso,
      status: status ?? this.status,
      objectives: objectives ?? this.objectives,
      rewardAmount: rewardAmount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startAtIso': startAtIso,
        'endAtIso': endAtIso,
        'status': status.name,
        'objectives': objectives.map((o) => o.toJson()).toList(),
        'rewardAmount': rewardAmount,
      };

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        startAtIso: json['startAtIso'] as String,
        endAtIso: json['endAtIso'] as String,
        status: EventStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => EventStatus.active,
        ),
        objectives: ((json['objectives'] ?? []) as List)
            .map((o) => EventObjective.fromJson(o as Map<String, dynamic>))
            .toList(),
        rewardAmount: json['rewardAmount'] as int,
      );
}
