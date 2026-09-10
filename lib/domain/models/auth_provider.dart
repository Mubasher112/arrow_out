/// Supported authentication identity providers.
enum AuthProvider {
  guest,
  google,
  apple,
  facebook;

  static AuthProvider fromString(String val) {
    return AuthProvider.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => AuthProvider.guest,
    );
  }
}
