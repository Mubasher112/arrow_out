import '../domain/models/notification_settings.dart';
import '../domain/repositories/game_repository.dart';

/// Notification reminder item model.
class ScheduledNotification {
  final String id;
  final String title;
  final String body;
  final String triggerTimeIso;
  final String category;

  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.triggerTimeIso,
    required this.category,
  });
}

/// Service managing local notification scheduling and category preferences.
class NotificationService {
  final GameRepository _repository;
  NotificationSettings _settings = const NotificationSettings();
  final List<ScheduledNotification> _scheduledQueue = [];

  NotificationService({required GameRepository repository})
      : _repository = repository;

  NotificationSettings get settings => _settings;
  List<ScheduledNotification> get scheduledQueue => _scheduledQueue;

  Future<void> init() async {
    _settings = await _repository.getNotificationSettings();
    _refreshSchedules();
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _repository.setNotificationSettings(newSettings);
    _refreshSchedules();
  }

  void _refreshSchedules() {
    _scheduledQueue.clear();

    if (_settings.dailyRewards) {
      _scheduledQueue.add(const ScheduledNotification(
        id: 'notif_daily_reward',
        title: 'Daily Reward Ready! 🎁',
        body: 'Claim today\'s free coins and bonus hints!',
        triggerTimeIso: '09:00',
        category: 'dailyRewards',
      ));
    }

    if (_settings.dailyChallenges) {
      _scheduledQueue.add(const ScheduledNotification(
        id: 'notif_daily_challenge',
        title: 'New Daily Challenge! 🔥',
        body: 'Today\'s puzzle is waiting. Keep your streak alive!',
        triggerTimeIso: '12:00',
        category: 'dailyChallenges',
      ));
    }

    if (_settings.events) {
      _scheduledQueue.add(const ScheduledNotification(
        id: 'notif_event_ending',
        title: 'Arrow Festival Ending Soon! 🎉',
        body: 'Complete objectives to claim 500 bonus coins!',
        triggerTimeIso: '18:00',
        category: 'events',
      ));
    }
  }
}
