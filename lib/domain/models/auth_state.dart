/// Overall authentication state of the player account.
enum AuthState {
  unknown,
  guest,
  authenticating,
  authenticated,
  signingOut,
  error,
}
