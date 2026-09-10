import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/in_memory_social_repository.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/audio_service.dart';
import 'package:arrow_path/services/mock_auth_service.dart';
import 'package:arrow_path/ui/screens/leaderboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Widget createLeaderboardScreenWidget({bool isAuthenticated = true}) {
    final repository = LocalGameRepository();
    final audioService = AudioService(repository: repository);
    final socialRepository = InMemorySocialRepository();
    final authService = MockAuthService();

    if (isAuthenticated) {
      authService.signInWithGoogle();
    } else {
      authService.playAsGuest();
    }

    return MaterialApp(
      home: LeaderboardScreen(
        socialRepository: socialRepository,
        authService: authService,
        audioService: audioService,
      ),
    );
  }

  group('LeaderboardScreen Widget Tests', () {
    testWidgets('renders guest sign in prompt when unauthenticated', (tester) async {
      await tester.pumpWidget(createLeaderboardScreenWidget(isAuthenticated: false));
      await tester.pumpAndSettle();

      expect(find.text('Sign in to compete'), findsOneWidget);
      expect(find.text('SIGN IN / LINK ACCOUNT'), findsOneWidget);
    });

    testWidgets('renders global leaderboard ranking list when authenticated', (tester) async {
      await tester.pumpWidget(createLeaderboardScreenWidget(isAuthenticated: true));
      await tester.pumpAndSettle();

      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('GLOBAL RANKINGS'), findsOneWidget);
      expect(find.text('FRIENDS'), findsOneWidget);
      expect(find.text('Sofia Arrow'), findsOneWidget);
    });
  });
}
