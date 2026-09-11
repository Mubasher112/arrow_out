import '../domain/models/remote_config_model.dart';
import '../domain/repositories/game_repository.dart';

/// Service managing feature flags and live content parameters with safe cached/built-in defaults.
class RemoteConfigService {
  final GameRepository _repository;
  RemoteConfigModel _config = RemoteConfigModel.defaultDefaults;

  RemoteConfigService({required GameRepository repository})
      : _repository = repository;

  RemoteConfigModel get config => _config;

  Future<void> init() async {
    try {
      final cached = await _repository.getRemoteConfig();
      if (cached != null) {
        _config = cached;
      } else {
        _config = RemoteConfigModel.defaultDefaults;
      }
    } catch (_) {
      _config = RemoteConfigModel.defaultDefaults;
    }
  }

  bool isFeatureEnabled(String flagName) {
    return _config.isFeatureEnabled(flagName);
  }
}
