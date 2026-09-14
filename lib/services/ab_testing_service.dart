import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../domain/models/experiment_model.dart';
import 'analytics_service.dart';

/// Service assigning stable A/B testing experiment variants based on deterministic user hash.
class ABTestingService {
  final AnalyticsService? _analyticsService;

  ABTestingService({AnalyticsService? analyticsService})
      : _analyticsService = analyticsService;

  /// Get stable variant ('A' or 'B') for user and experiment ID.
  String getVariant({required String userId, required String experimentId}) {
    final raw = 'exp_${experimentId}_$userId';
    final bytes = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    final val = digest.bytes.fold(0, (acc, b) => acc + b);

    final variant = (val % 2 == 0) ? 'A' : 'B';
    _analyticsService?.logEvent('experiment_viewed', {
      'experimentId': experimentId,
      'variant': variant,
    });

    return variant;
  }

  ExperimentModel getExperiment({
    required String userId,
    required String experimentId,
    required String startAtIso,
    required String endAtIso,
  }) {
    final variant = getVariant(userId: userId, experimentId: experimentId);
    return ExperimentModel(
      id: experimentId,
      variant: variant,
      startAtIso: startAtIso,
      endAtIso: endAtIso,
    );
  }
}
