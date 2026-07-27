import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/models/type.dart';

class RuntimeError extends GenericError {
  const RuntimeError(String message, {String category = 'Runtime error'})
    : super(category, message);
}

class InvalidArgumentTypesError extends RuntimeError {
  /// The function that rejected the arguments.
  ///
  /// Retained so a caller can tell an error it raised itself apart from one
  /// that merely propagated through it.
  final String function;

  InvalidArgumentTypesError({
    required this.function,
    required List<Type> expected,
    required List<Type> actual,
  }) : super(
         'Invalid argument types for function "$function". Expected: (${expected.join(', ')}). Actual: (${actual.join(', ')})',
       );
}

class InvalidArgumentCountError extends RuntimeError {
  InvalidArgumentCountError({
    required String function,
    required int expected,
    required int actual,
  }) : super(
         'Invalid argument count for function "$function". Expected: $expected. Actual: $actual',
       );
}

class IterablesWithDifferentLengthError extends RuntimeError {
  const IterablesWithDifferentLengthError({
    required dynamic iterable1,
    required dynamic iterable2,
  }) : super('Iterables with different length: $iterable1 and $iterable2');
}

class InvalidLiteralValueError extends RuntimeError {
  const InvalidLiteralValueError(String value)
    : super('Invalid literal value: "$value"');
}

class InvalidValueError extends RuntimeError {
  const InvalidValueError(String value) : super('Invalid value: "$value"');
}

class InvalidMapIndexError extends RuntimeError {
  const InvalidMapIndexError(String index)
    : super('No element present in map for key: "$index"');
}

class ElementNotFoundError extends RuntimeError {
  const ElementNotFoundError(String index)
    : super('Element not found at index: "$index"');
}

class NotFoundInScopeError extends RuntimeError {
  const NotFoundInScopeError(String variable)
    : super('Variable "$variable" not found in scope');
}

class InvalidFunctionError extends RuntimeError {
  const InvalidFunctionError(String variable)
    : super('"$variable" is not a function');
}

class UnimplementedFunctionWebError extends RuntimeError {
  const UnimplementedFunctionWebError(String function)
    : super('Function "$function" is not implemented on the web platform');
}

class EmptyCollectionError extends RuntimeError {
  EmptyCollectionError({
    required String function,
    required String collectionType,
  }) : super(
         'Cannot get element from empty $collectionType in function "$function"',
       );
}

class IndexOutOfBoundsError extends RuntimeError {
  IndexOutOfBoundsError({
    required String function,
    required int index,
    required int length,
  }) : super(
         'Index $index is out of bounds for $function (length: $length)',
       );
}

class NegativeIndexError extends RuntimeError {
  NegativeIndexError({
    required String function,
    required int index,
  }) : super(
         'Negative index $index is not allowed for $function',
       );
}

class DivisionByZeroError extends RuntimeError {
  DivisionByZeroError({
    required String function,
  }) : super(
         'Division by zero is not allowed in "$function"',
       );
}

class InvalidNumericOperationError extends RuntimeError {
  InvalidNumericOperationError({
    required String function,
    required String reason,
  }) : super(
         'Invalid numeric operation in "$function": $reason',
       );
}

class ParseError extends RuntimeError {
  ParseError({
    required String function,
    required String input,
    required String targetType,
  }) : super(
         'Cannot parse "$input" as $targetType in "$function"',
       );
}

class JsonParseError extends RuntimeError {
  JsonParseError({
    required String input,
    required String details,
  }) : super(
         'Invalid JSON: $details. Input: "${_truncate(input)}"',
       );

  static String _truncate(String s) =>
      s.length > 50 ? '${s.substring(0, 50)}...' : s;
}

class Base64ParseError extends RuntimeError {
  Base64ParseError({
    required String input,
    required String details,
  }) : super(
         'Invalid Base64: $details. Input: "${_truncate(input)}"',
       );

  static String _truncate(String s) =>
      s.length > 50 ? '${s.substring(0, 50)}...' : s;
}

class RecursionLimitError extends RuntimeError {
  RecursionLimitError({
    required int limit,
  }) : super(
         'Maximum recursion depth of $limit exceeded',
       );
}

/// Raised by an assertion whose expectation was not satisfied.
///
/// Renders under its own category so a test failure is distinguishable from a
/// genuine runtime error. The constructor arguments are folded into the
/// message and not retained.
class AssertionFailedError extends RuntimeError {
  AssertionFailedError({
    required String function,
    required String actual,
    required String expected,
  }) : super(
         '"$function" failed: expected $expected, actual $actual',
         category: 'Assertion error',
       );
}

/// Raised by an assertion that was *misused* rather than unsatisfied.
///
/// Wraps the [InvalidArgumentTypesError] the assertion would otherwise have
/// thrown and forwards its message verbatim, so rendering is identical. The
/// type exists only to be recognisable to `assert.throws`, which must not
/// absorb a broken assertion as a satisfied expectation.
class AssertionArgumentError extends RuntimeError {
  AssertionArgumentError(InvalidArgumentTypesError cause)
    : super(cause.message);
}

class NegativeDurationError extends RuntimeError {
  NegativeDurationError({
    required String function,
    String? component,
    num? value,
  }) : super(
         component != null
             ? 'Duration cannot be negative in "$function" ($component: $value)'
             : 'Duration cannot be negative in "$function"',
       );
}
