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
    testWidgets('renders title, continue level button and level map button', (tester) async {
      await tester.pumpWidget(createHomeScreenWidget());
      await tester.pumpAndSettle();

      expect(find.text('ARROW PATH'), findsOneWidget);
      expect(find.textContaining('CONTINUE LEVEL 1'), findsOneWidget);
      expect(find.text('LEVEL MAP'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('tapping settings opens SettingsDialog with reset option', (tester) async {
      await tester.pumpWidget(createHomeScreenWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Reset All Progress'), findsOneWidget);
    });
  });
}
