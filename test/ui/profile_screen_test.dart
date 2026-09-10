import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/cloud_game_repository.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/audio_service.dart';
import 'package:arrow_path/services/mock_auth_service.dart';
import 'package:arrow_path/services/sync_service.dart';
import 'package:arrow_path/ui/screens/profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Widget createProfileScreenWidget() {
    final repository = LocalGameRepository();
    final audioService = AudioService(repository: repository);
    final authService = MockAuthService();
    final syncService = SyncService(
      localRepository: repository,
      cloudRepository: InMemoryCloudRepository(),
      authService: authService,
    );

    return MaterialApp(
      home: ProfileScreen(
        repository: repository,
        authService: authService,
        syncService: syncService,
        audioService: audioService,
      ),
    );
  }

  group('ProfileScreen Widget Tests', () {
    testWidgets('renders guest profile details, sync status and sign in button', (tester) async {
      await tester.pumpWidget(createProfileScreenWidget());
      await tester.pumpAndSettle();

      expect(find.text('Player Profile'), findsOneWidget);
      expect(find.text('Guest Player'), findsOneWidget);
      expect(find.text('SIGN IN / LINK ACCOUNT'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Total Stars'), findsOneWidget);
      expect(find.text('Coins Balance'), findsOneWidget);
    });

    testWidgets('tapping sign in button opens AuthModal', (tester) async {
      await tester.pumpWidget(createProfileScreenWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('SIGN IN / LINK ACCOUNT'));
      await tester.pumpAndSettle();

      expect(find.text('Cloud Save Account'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign in with Apple'), findsOneWidget);
      expect(find.text('Sign in with Facebook'), findsOneWidget);
    });
  });
}
