/// Lightweight analytics service for tracking product retention events without PII.
class AnalyticsService {
  final List<String> _eventLog = [];

  List<String> get eventLog => _eventLog;

  /// Log product event.
  void logEvent(String name, [Map<String, dynamic>? parameters]) {
    final payload = parameters != null ? '$name: $parameters' : name;
    _eventLog.add(payload);
  }
}
