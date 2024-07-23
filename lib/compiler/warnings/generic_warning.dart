class GenericWarning implements Exception {
  final String message;

  const GenericWarning(this.message);

  @override
  String toString() => 'Warning: $message';
}
