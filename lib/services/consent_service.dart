import '../domain/models/consent_status.dart';
import '../domain/repositories/game_repository.dart';

/// Service managing user privacy consent status for advertising.
class ConsentService {
  final GameRepository _repository;
  ConsentStatus _status = ConsentStatus.obtained;

  ConsentService({required GameRepository repository}) : _repository = repository;

  ConsentStatus get status => _status;

  bool get canServePersonalizedAds => _status == ConsentStatus.obtained;

  Future<void> updateConsent(ConsentStatus newStatus) async {
    _status = newStatus;
  }
}
