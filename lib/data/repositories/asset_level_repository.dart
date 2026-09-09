import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/level_solver.dart';
import '../../domain/models/level_definition.dart';
import '../../domain/repositories/level_repository.dart';

/// Asset-backed implementation of LevelRepository reading bundled levels.json.
class AssetLevelRepository implements LevelRepository {
  final String assetPath;
  List<LevelDefinition>? _cache;

  AssetLevelRepository({this.assetPath = 'assets/levels/levels.json'});

  @override
  Future<List<LevelDefinition>> getAllLevels() async {
    if (_cache != null && _cache!.isNotEmpty) {
      return _cache!;
    }

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      _cache = jsonList
          .map((item) => LevelDefinition.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cache!;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<LevelDefinition?> getLevelById(int id) async {
    final levels = await getAllLevels();
    final match = levels.where((l) => l.levelNumber == id);
    if (match.isNotEmpty) {
      return match.first;
    }
    return null;
  }

  @override
  Future<List<LevelDefinition>> getLevelRange(int startId, int count) async {
    final levels = await getAllLevels();
    return levels
        .where((l) => l.levelNumber >= startId && l.levelNumber < startId + count)
        .toList();
  }

  @override
  Future<bool> validateLevel(LevelDefinition level) async {
    return LevelSolver.isSolvable(level);
  }
}
