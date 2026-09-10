import 'dart:async';
import '../domain/models/account_model.dart';
import '../domain/models/auth_provider.dart';
import '../domain/models/auth_state.dart';
import 'auth_service.dart';

/// Concrete mock AuthService implementing authentication flows for testing and UI integration.
class MockAuthService implements AuthService {
  final _stateController = StreamController<AuthState>.broadcast();
  AuthState _state = AuthState.guest;
  AccountModel? _account;

  MockAuthService({AccountModel? initialAccount}) {
    _account = initialAccount ?? AccountModel.createGuest();
    _state = _account!.isGuest ? AuthState.guest : AuthState.authenticated;
  }

  @override
  Stream<AuthState> get authStateStream => _stateController.stream;

  @override
  AuthState get currentState => _state;

  @override
  AccountModel? get currentAccount => _account;

  void _updateState(AuthState newState, AccountModel? account) {
    _state = newState;
    _account = account;
    _stateController.add(newState);
  }

  @override
  Future<AccountModel> playAsGuest() async {
    _updateState(AuthState.authenticating, _account);
    await Future.delayed(const Duration(milliseconds: 100));
    final guestAccount = AccountModel.createGuest();
    _updateState(AuthState.guest, guestAccount);
    return guestAccount;
  }

  @override
  Future<AccountModel> signInWithGoogle() async {
    _updateState(AuthState.authenticating, _account);
    await Future.delayed(const Duration(milliseconds: 150));
    final account = AccountModel(
      userId: 'google_user_12345',
      displayName: 'Alex Mobile',
      email: 'alex.player@example.com',
      photoUrl: 'https://example.com/avatar.png',
      provider: AuthProvider.google,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _updateState(AuthState.authenticated, account);
    return account;
  }

  @override
  Future<AccountModel> signInWithApple() async {
    _updateState(AuthState.authenticating, _account);
    await Future.delayed(const Duration(milliseconds: 150));
    final account = AccountModel(
      userId: 'apple_user_67890',
      displayName: 'Apple Gamer',
      email: 'gamer@icloud.com',
      provider: AuthProvider.apple,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _updateState(AuthState.authenticated, account);
    return account;
  }

  @override
  Future<AccountModel> signInWithFacebook() async {
    _updateState(AuthState.authenticating, _account);
    await Future.delayed(const Duration(milliseconds: 150));
    final account = AccountModel(
      userId: 'fb_user_11223',
      displayName: 'FB Arrow Player',
      email: 'fb.user@example.com',
      provider: AuthProvider.facebook,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _updateState(AuthState.authenticated, account);
    return account;
  }

  @override
  Future<void> signOut() async {
    _updateState(AuthState.signingOut, _account);
    await Future.delayed(const Duration(milliseconds: 100));
    final guest = AccountModel.createGuest();
    _updateState(AuthState.guest, guest);
  }

  @override
  Future<void> deleteAccount() async {
    _updateState(AuthState.signingOut, _account);
    await Future.delayed(const Duration(milliseconds: 100));
    final guest = AccountModel.createGuest();
    _updateState(AuthState.guest, guest);
  }

  void dispose() {
    _stateController.close();
  }
}
