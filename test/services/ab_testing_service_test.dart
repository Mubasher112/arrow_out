import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/services/ab_testing_service.dart';

void main() {
  group('ABTestingService', () {
    late ABTestingService abService;

    setUp(() {
      abService = ABTestingService();
    });

    test('deterministically assigns variant for user ID', () {
      final variant1 = abService.getVariant(userId: 'user_123', experimentId: 'exp_hint_cost');
      final variant2 = abService.getVariant(userId: 'user_123', experimentId: 'exp_hint_cost');

      expect(variant1, equals(variant2));
      expect(['A', 'B'], contains(variant1));
    });

    test('returns structured ExperimentModel', () {
      final experiment = abService.getExperiment(
        userId: 'user_123',
        experimentId: 'exp_daily_coins',
        startAtIso: '2025-01-01T00:00:00Z',
        endAtIso: '2025-12-31T23:59:59Z',
      );

      expect(experiment.id, equals('exp_daily_coins'));
      expect(['A', 'B'], contains(experiment.variant));
      expect(experiment.startAtIso, equals('2025-01-01T00:00:00Z'));
    });
  });
}
