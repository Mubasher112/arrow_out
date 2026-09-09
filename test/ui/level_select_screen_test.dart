import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/audio_service.dart';
import 'package:arrow_path/ui/screens/level_select_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Widget createLevelSelectWidget() {
    final repository = LocalGameRepository();
    final audioService = AudioService(repository: repository);

    return MaterialApp(
      home: LevelSelectScreen(
        repository: repository,
        audioService: audioService,
      ),
    );
  }

  group('LevelSelectScreen Widget Tests', () {
    testWidgets('renders 100 level cards grid and app bar title', (tester) async {
      await tester.pumpWidget(createLevelSelectWidget());
      await tester.pumpAndSettle();

      expect(find.text('Select Level'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Level 1 card is visible
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('tapping locked level shows snackbar feedback', (tester) async {
      await tester.pumpWidget(createLevelSelectWidget());
      await tester.pumpAndSettle();

      // Scroll to a locked level, e.g. level 10
      final itemFinder = find.byIcon(Icons.lock_rounded).first;
      await tester.tap(itemFinder);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
