import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/repositories/cloud_game_repository.dart';
import '../domain/models/cloud_game_data.dart';
import '../domain/models/sync_status.dart';
import '../domain/repositories/game_repository.dart';
import 'auth_service.dart';
import 'progress_merge_service.dart';

/// Orchestrates local-first cloud synchronization and offline queueing.
class SyncService extends ChangeNotifier {
  final GameRepository _localRepository;
  final CloudGameRepository _cloudRepository;
  final AuthService _authService;

  SyncStatus _status = SyncStatus.idle;
  String? _lastError;
  bool _isSyncPending = false;

  SyncService({
    required GameRepository localRepository,
    required CloudGameRepository cloudRepository,
    required AuthService authService,
  })  : _localRepository = localRepository,
        _cloudRepository = cloudRepository,
        _authService = authService;

  SyncStatus get status => _status;
  String? get lastError => _lastError;
  bool get isSyncPending => _isSyncPending;

  /// Package local progress into CloudGameData container.
  Future<CloudGameData> _exportLocalData(String userId) async {
    final curLevel = await _localRepository.getCurrentLevel();
    final progressMap = await _localRepository.getAllProgress();
    final coins = await _localRepository.getCoinsBalance();
    final txs = await _localRepository.getRewardTransactions();
    final dailies = await _localRepository.getDailyChallengeResults();
    final streak = await _localRepository.getLongestStreak();
    final achieveMap = await _localRepository.getAchievements();

    return CloudGameData(
      userId: userId,
      currentLevel: curLevel,
      levelProgressMap: progressMap,
      coinsBalance: coins,
      rewardTransactions: txs,
      dailyChallengeResults: dailies,
      longestStreak: streak,
      achievements: achieveMap,
      lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Write CloudGameData object back into local GameRepository storage.
  Future<void> _importLocalData(CloudGameData data) async {
    await _localRepository.setCurrentLevel(data.currentLevel);
    await _localRepository.setCoinsBalance(data.coinsBalance);
    await _localRepository.setLongestStreak(data.longestStreak);

    for (final p in data.levelProgressMap.values) {
      await _localRepository.saveLevelProgress(p);
    }
    for (final tx in data.rewardTransactions) {
      await _localRepository.addRewardTransaction(tx);
    }
    for (final d in data.dailyChallengeResults.values) {
      await _localRepository.saveDailyChallengeResult(d);
    }
    for (final a in data.achievements.values) {
      await _localRepository.saveAchievement(a);
    }
  }

  /// Queue or execute cloud synchronization.
  Future<void> sync() async {
    final account = _authService.currentAccount;
    if (account == null || account.isGuest) {
      _status = SyncStatus.idle;
      notifyListeners();
      return;
    }

    _status = SyncStatus.syncing;
    _isSyncPending = true;
    notifyListeners();

    try {
      final localData = await _exportLocalData(account.userId);
      final cloudData = await _cloudRepository.getCloudData(account.userId);

      CloudGameData merged;
      if (cloudData == null) {
        merged = localData;
      } else {
        merged = ProgressMergeService.mergeGameData(
          localData: localData,
          cloudData: cloudData,
          targetUserId: account.userId,
        );
      }

      await _importLocalData(merged);
      await _cloudRepository.saveCloudData(merged);

      _status = SyncStatus.synced;
      _isSyncPending = false;
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _status = SyncStatus.offline;
      _lastError = e.toString();
      notifyListeners();
    }
  }
}
