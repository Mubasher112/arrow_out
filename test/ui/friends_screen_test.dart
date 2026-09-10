import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/in_memory_social_repository.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/audio_service.dart';
import 'package:arrow_path/services/mock_auth_service.dart';
import 'package:arrow_path/ui/screens/friends_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Widget createFriendsScreenWidget({bool isAuthenticated = true}) {
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
      home: FriendsScreen(
        socialRepository: socialRepository,
        authService: authService,
        audioService: audioService,
      ),
    );
  }

  group('FriendsScreen Widget Tests', () {
    testWidgets('renders guest prompt when unauthenticated', (tester) async {
      await tester.pumpWidget(createFriendsScreenWidget(isAuthenticated: false));
      await tester.pumpAndSettle();

      expect(find.text('Sign in for Social Features'), findsOneWidget);
      expect(find.text('SIGN IN / LINK ACCOUNT'), findsOneWidget);
    });

    testWidgets('renders friends sub-tabs when authenticated', (tester) async {
      await tester.pumpWidget(createFriendsScreenWidget(isAuthenticated: true));
      await tester.pumpAndSettle();

      expect(find.text('Friends & Social'), findsOneWidget);
      expect(find.textContaining('MY FRIENDS'), findsOneWidget);
      expect(find.textContaining('PENDING'), findsOneWidget);
      expect(find.text('FIND'), findsOneWidget);
    });
  });
}
