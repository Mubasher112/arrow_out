import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/audio_service.dart';
import 'package:arrow_path/ui/screens/level_map_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Widget createLevelMapWidget() {
    final repository = LocalGameRepository();
    final audioService = AudioService(repository: repository);

    return MaterialApp(
      home: LevelMapScreen(
        repository: repository,
        audioService: audioService,
      ),
    );
  }

  group('LevelMapScreen Widget Tests', () {
    testWidgets('renders chapter headers, total stars and level nodes grid', (tester) async {
      await tester.pumpWidget(createLevelMapWidget());
      await tester.pumpAndSettle();

      expect(find.text('Level Map'), findsOneWidget);
      expect(find.textContaining('CHAPTER 1'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('switching chapter tab updates active chapter title', (tester) async {
      await tester.pumpWidget(createLevelMapWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ch. 2'));
      await tester.pumpAndSettle();

      expect(find.textContaining('CHAPTER 2'), findsOneWidget);
    });
  });
}
