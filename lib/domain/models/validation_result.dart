/// Detailed result returned by LevelValidator.
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  factory ValidationResult.invalid(List<String> errors) =>
      ValidationResult(isValid: false, errors: errors);

  @override
  String toString() {
    return isValid ? 'ValidationResult(valid)' : 'ValidationResult(invalid: $errors)';
  }
}
