import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/audio_service.dart';
import 'package:arrow_path/ui/screens/event_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Widget createEventScreenWidget() {
    final repository = LocalGameRepository();
    final audioService = AudioService(repository: repository);

    return MaterialApp(
      home: EventScreen(
        repository: repository,
        audioService: audioService,
      ),
    );
  }

  group('EventScreen Widget Tests', () {
    testWidgets('renders event title banner, countdown and objectives list', (tester) async {
      await tester.pumpWidget(createEventScreenWidget());
      await tester.pumpAndSettle();

      expect(find.text('ARROW FESTIVAL'), findsOneWidget);
      expect(find.textContaining('Ends in'), findsOneWidget);
      expect(find.text('Complete 15 Levels'), findsOneWidget);
    });
  });
}
