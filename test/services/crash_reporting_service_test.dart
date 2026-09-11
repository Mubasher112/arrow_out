import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/services/crash_reporting_service.dart';

void main() {
  group('CrashReportingService', () {
    test('records non-fatal exceptions and fatal crashes under error categories', () {
      final service = CrashReportingService();

      service.recordError(
        exception: 'Network timeout',
        stackTrace: StackTrace.current,
        category: ErrorCategory.networkError,
        reason: 'Failed to sync cloud save',
      );

      service.recordFatalCrash('Unhandled error', StackTrace.current);

      expect(service.nonFatalLog.length, 2);
      expect(service.nonFatalLog[0], contains('[NETWORKERROR] Failed to sync cloud save: Network timeout'));
      expect(service.nonFatalLog[1], contains('[FATAL] Unhandled error'));
    });
  });
}
