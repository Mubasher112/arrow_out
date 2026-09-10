import '../../domain/models/cloud_game_data.dart';

/// Abstract repository interface for remote backend cloud storage.
abstract class CloudGameRepository {
  Future<CloudGameData?> getCloudData(String userId);
  Future<void> saveCloudData(CloudGameData data);
  Future<void> deleteCloudData(String userId);
}

/// In-memory implementation simulating secure remote cloud backend database.
class InMemoryCloudRepository implements CloudGameRepository {
  final Map<String, CloudGameData> _remoteDb = {};
  bool isNetworkAvailable = true;

  @override
  Future<CloudGameData?> getCloudData(String userId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    await Future.delayed(const Duration(milliseconds: 100));
    return _remoteDb[userId];
  }

  @override
  Future<void> saveCloudData(CloudGameData data) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    await Future.delayed(const Duration(milliseconds: 100));
    _remoteDb[data.userId] = data;
  }

  @override
  Future<void> deleteCloudData(String userId) async {
    if (!isNetworkAvailable) throw Exception('Network offline');
    await Future.delayed(const Duration(milliseconds: 100));
    _remoteDb.remove(userId);
  }
}
