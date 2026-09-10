import '../domain/models/account_model.dart';
import '../domain/models/auth_state.dart';

/// Abstract service interface for authentication providers.
abstract class AuthService {
  Stream<AuthState> get authStateStream;
  AuthState get currentState;
  AccountModel? get currentAccount;

  Future<AccountModel> playAsGuest();
  Future<AccountModel> signInWithGoogle();
  Future<AccountModel> signInWithApple();
  Future<AccountModel> signInWithFacebook();
  Future<void> signOut();
  Future<void> deleteAccount();
}
