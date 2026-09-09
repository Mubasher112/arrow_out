import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/audio_service.dart';
import 'package:arrow_path/ui/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Widget createHomeScreenWidget() {
    final repository = LocalGameRepository();
    final audioService = AudioService(repository: repository);

    return MaterialApp(
      home: HomeScreen(
        repository: repository,
        audioService: audioService,
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('renders title, play button and settings button', (tester) async {
      await tester.pumpWidget(createHomeScreenWidget());
      await tester.pumpAndSettle();

      expect(find.text('ARROW PATH'), findsOneWidget);
      expect(find.text('PLAY LEVEL 1'), findsOneWidget);
      expect(find.text('LEVEL SELECT'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('tapping settings opens SettingsDialog', (tester) async {
      await tester.pumpWidget(createHomeScreenWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('Haptics'), findsOneWidget);
    });
  });
}
