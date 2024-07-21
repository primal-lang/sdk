class GenericError implements Exception {
  final String message;

  const GenericError(this.message);

  @override
  String toString() => message;
}
