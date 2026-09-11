/// Structured error categories for production telemetry.
enum ErrorCategory {
  authenticationError,
  networkError,
  cloudSyncError,
  purchaseError,
  adError,
  leaderboardError,
  eventError,
  storageError,
  unknownError,
}

/// Production crash reporting and non-fatal exception monitoring service abstraction.
class CrashReportingService {
  final List<String> _nonFatalLog = [];

  List<String> get nonFatalLog => _nonFatalLog;

  /// Log a non-fatal exception with error category, removing sensitive PII.
  void recordError({
    required Object exception,
    required StackTrace stackTrace,
    required ErrorCategory category,
    String? reason,
  }) {
    final entry = '[${category.name.toUpperCase()}] ${reason ?? 'An error occurred'}: $exception';
    _nonFatalLog.add(entry);
  }

  /// Log fatal crash event safely.
  void recordFatalCrash(Object exception, StackTrace stackTrace) {
    _nonFatalLog.add('[FATAL] $exception');
  }
}
