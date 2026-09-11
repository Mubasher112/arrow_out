import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/audio_service.dart';
import 'package:arrow_path/ui/screens/weekly_challenges_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Widget createWeeklyChallengesWidget() {
    final repository = LocalGameRepository();
    final audioService = AudioService(repository: repository);

    return MaterialApp(
      home: WeeklyChallengesScreen(
        repository: repository,
        audioService: audioService,
      ),
    );
  }

  group('WeeklyChallengesScreen Widget Tests', () {
    testWidgets('renders weekly challenges list and countdown card', (tester) async {
      await tester.pumpWidget(createWeeklyChallengesWidget());
      await tester.pumpAndSettle();

      expect(find.text('Weekly Challenges'), findsOneWidget);
      expect(find.textContaining('Ends in:'), findsOneWidget);
      expect(find.text('Complete 20 Levels'), findsOneWidget);
    });
  });
}
