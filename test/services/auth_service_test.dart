import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/domain/models/auth_provider.dart';
import 'package:arrow_path/domain/models/auth_state.dart';
import 'package:arrow_path/services/mock_auth_service.dart';

void main() {
  group('MockAuthService', () {
    test('default initial state is guest', () {
      final auth = MockAuthService();
      expect(auth.currentState, AuthState.guest);
      expect(auth.currentAccount, isNotNull);
      expect(auth.currentAccount!.isGuest, isTrue);
    });

    test('sign in with Google updates auth state to authenticated', () async {
      final auth = MockAuthService();
      final account = await auth.signInWithGoogle();

      expect(auth.currentState, AuthState.authenticated);
      expect(account.provider, AuthProvider.google);
      expect(account.email, isNotNull);
      expect(auth.currentAccount!.userId, account.userId);
    });

    test('sign in with Apple updates auth state to authenticated', () async {
      final auth = MockAuthService();
      final account = await auth.signInWithApple();

      expect(auth.currentState, AuthState.authenticated);
      expect(account.provider, AuthProvider.apple);
    });

    test('sign in with Facebook updates auth state to authenticated', () async {
      final auth = MockAuthService();
      final account = await auth.signInWithFacebook();

      expect(auth.currentState, AuthState.authenticated);
      expect(account.provider, AuthProvider.facebook);
    });

    test('signOut returns user to guest mode', () async {
      final auth = MockAuthService();
      await auth.signInWithGoogle();
      expect(auth.currentState, AuthState.authenticated);

      await auth.signOut();
      expect(auth.currentState, AuthState.guest);
      expect(auth.currentAccount!.isGuest, isTrue);
    });
  });
}
