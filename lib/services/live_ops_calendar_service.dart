import 'date_provider.dart';

/// Service managing Live-Ops calendar schedule and content rotation.
class LiveOpsCalendarService {
  final DateProvider _dateProvider;

  LiveOpsCalendarService({DateProvider? dateProvider})
      : _dateProvider = dateProvider ?? const LocalDateProvider();

  /// Check if a live event is currently active based on UTC date range.
  bool isEventActive({required String startAtIso, required String endAtIso}) {
    final nowIso = _dateProvider.currentDateIso;
    return nowIso.compareTo(startAtIso) >= 0 && nowIso.compareTo(endAtIso) <= 0;
  }
}
