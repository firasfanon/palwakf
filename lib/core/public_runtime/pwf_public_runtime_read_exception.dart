class PwfPublicRuntimeReadException implements Exception {
  final String surface;
  final String operation;
  final Object? cause;

  const PwfPublicRuntimeReadException({
    required this.surface,
    required this.operation,
    this.cause,
  });

  factory PwfPublicRuntimeReadException.fromError(
    Object error, {
    required String surface,
    required String operation,
  }) {
    return PwfPublicRuntimeReadException(
      surface: surface,
      operation: operation,
      cause: error,
    );
  }

  @override
  String toString() =>
      'PwfPublicRuntimeReadException(surface: $surface, operation: $operation, cause: $cause)';
}
