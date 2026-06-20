/// Result returned when validating a candidate region.
class PuzzleValidationResult {
  /// Creates a validation result.
  const PuzzleValidationResult._({
    required this.isValid,
    required this.message,
  });

  /// Creates a successful validation result.
  const PuzzleValidationResult.valid()
    : this._(isValid: true, message: 'Valid region');

  /// Creates a failed validation result.
  const PuzzleValidationResult.invalid(String message)
    : this._(isValid: false, message: message);

  /// Whether the candidate region can be accepted.
  final bool isValid;

  /// Human-readable validation message.
  final String message;
}
