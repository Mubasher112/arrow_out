import 'dart:convert';
import 'dart:io';
import 'package:arrow_path/domain/level_generator.dart';
import 'package:arrow_path/domain/level_validator.dart';

void main() {
  print('Generating 500 verified solvable levels using LevelGenerator and LevelValidator...');
  final generator = LevelGenerator(seed: 2026);
  final levels = generator.generate500Levels();

  int validatedCount = 0;
  for (final level in levels) {
    final result = LevelValidator.validate(level);
    if (!result.isValid) {
      stderr.writeln('ERROR: Level ${level.levelNumber} failed validation: ${result.errors}');
      exit(1);
    }
    validatedCount++;
  }

  print('Successfully validated $validatedCount / ${levels.length} levels!');

  final jsonList = levels.map((l) => l.toJson()).toList();
  final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

  final dir = Directory('assets/levels');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final file = File('assets/levels/levels.json');
  file.writeAsStringSync(jsonString);
  print('Saved 500 levels to assets/levels/levels.json (${file.lengthSync()} bytes)');
}
