import '../domain/models/event_model.dart';
import '../domain/models/event_objective.dart';
import '../domain/models/event_status.dart';
import '../domain/repositories/game_repository.dart';
import 'date_provider.dart';
import 'reward_service.dart';

/// Service managing limited-time live events, countdown timers, and objective progress.
class EventService {
  final GameRepository _repository;
  final RewardService _rewardService;
  final DateProvider _dateProvider;

  EventService({
    required GameRepository repository,
    required RewardService rewardService,
    DateProvider? dateProvider,
  })  : _repository = repository,
        _rewardService = rewardService,
        _dateProvider = dateProvider ?? const LocalDateProvider();

  EventModel getDefaultActiveEvent() {
    final now = _dateProvider.now;
    final startIso = DateProvider.dateToIso(now.subtract(const Duration(days: 1)));
    final endIso = DateProvider.dateToIso(now.add(const Duration(days: 5)));

    return EventModel(
      id: 'event_arrow_festival_2026',
      title: 'Arrow Festival',
      description: 'Complete festival objectives to win exclusive bonus coins!',
      startAtIso: startIso,
      endAtIso: endIso,
      status: EventStatus.active,
      objectives: const [
        EventObjective(id: 'obj_levels_15', description: 'Complete 15 Levels', target: 15),
        EventObjective(id: 'obj_stars_30', description: 'Earn 30 Stars', target: 30),
        EventObjective(id: 'obj_dailies_3', description: 'Solve 3 Daily Puzzles', target: 3),
      ],
      rewardAmount: 500,
    );
  }

  /// Get current active event with updated progress.
  Future<EventModel> getActiveEvent() async {
    final saved = await _repository.getSavedEvent();
    final event = saved ?? getDefaultActiveEvent();

    // Check expiration based on DateProvider
    final nowIso = _dateProvider.currentDateIso;
    if (nowIso.compareTo(event.endAtIso) > 0) {
      return event.copyWith(status: EventStatus.expired);
    }

    return event;
  }

  /// Evaluate event objectives progress from gameplay stats.
  Future<EventModel> evaluateEventProgress() async {
    final event = await getActiveEvent();
    if (event.status == EventStatus.expired) return event;

    final allProgress = await _repository.getAllProgress();
    final dailyResults = await _repository.getDailyChallengeResults();

    int totalCompleted = 0;
    int totalStars = 0;
    allProgress.forEach((_, p) {
      if (p.isCompleted) {
        totalCompleted++;
        totalStars += p.stars;
      }
    });

    int completedDailies = dailyResults.values.where((d) => d.isCompleted).length;

    final updatedObjectives = event.objectives.map((obj) {
      int val = 0;
      switch (obj.id) {
        case 'obj_levels_15':
          val = totalCompleted;
          break;
        case 'obj_stars_30':
          val = totalStars;
          break;
        case 'obj_dailies_3':
          val = completedDailies;
          break;
      }

      final progress = val.clamp(0, obj.target);
      return obj.copyWith(
        progress: progress,
        isCompleted: progress >= obj.target,
      );
    }).toList();

    final updated = event.copyWith(objectives: updatedObjectives);
    await _repository.saveEvent(updated);
    return updated;
  }

  /// Claim event completion reward (+500 coins).
  Future<int> claimEventReward() async {
    final event = await evaluateEventProgress();
    if (!event.isAllObjectivesCompleted || event.status == EventStatus.completed) return 0;

    final ref = 'event_claim_${event.id}';
    if (!await _rewardService.hasClaimed(ref)) {
      await _rewardService.grantDailyChallengeReward(ref);
    }

    final updated = event.copyWith(status: EventStatus.completed);
    await _repository.saveEvent(updated);

    return event.rewardAmount;
  }
}
