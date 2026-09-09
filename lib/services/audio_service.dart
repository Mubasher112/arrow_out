import 'package:flutter/services.dart';
import '../domain/repositories/game_repository.dart';

enum SoundType {
  tap,
  arrowExit,
  blocked,
  levelComplete,
  buttonClick,
}

/// Service handling game sound effects, music preferences, and haptic feedback.
class AudioService {
  final GameRepository _repository;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;

  AudioService({required GameRepository repository}) : _repository = repository;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  /// Initialize sound/music settings from preferences.
  Future<void> init() async {
    _soundEnabled = await _repository.isSoundEnabled();
    _musicEnabled = await _repository.isMusicEnabled();
    _vibrationEnabled = await _repository.isVibrationEnabled();
  }

  /// Toggle sound effects.
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _repository.setSoundEnabled(_soundEnabled);
  }

  /// Toggle background music.
  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    await _repository.setMusicEnabled(_musicEnabled);
  }

  /// Toggle haptic feedback.
  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    await _repository.setVibrationEnabled(_vibrationEnabled);
  }

  /// Trigger sound effect and haptics if enabled.
  void playSound(SoundType type) {
    if (_soundEnabled) {
      switch (type) {
        case SoundType.tap:
        case SoundType.buttonClick:
          SystemSound.play(SystemSoundType.click);
          break;
        case SoundType.arrowExit:
        case SoundType.levelComplete:
        case SoundType.blocked:
          SystemSound.play(SystemSoundType.click);
          break;
      }
    }

    if (_vibrationEnabled) {
      switch (type) {
        case SoundType.blocked:
          HapticFeedback.heavyImpact();
          break;
        case SoundType.arrowExit:
          HapticFeedback.lightImpact();
          break;
        case SoundType.levelComplete:
          HapticFeedback.mediumImpact();
          break;
        case SoundType.tap:
        case SoundType.buttonClick:
          HapticFeedback.selectionClick();
          break;
      }
    }
  }
}
