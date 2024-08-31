class GenericError implements Exception {
  final String errorType;
  final String message;

  const GenericError(this.errorType, this.message);

  @override
  String toString() => '$errorType: $message';
}

class CompilationError extends GenericError {
  const CompilationError(String message) : super('Compilation error', message);
}
