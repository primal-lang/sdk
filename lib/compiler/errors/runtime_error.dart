import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/models/type.dart';

class RuntimeError extends GenericError {
  const RuntimeError(String message) : super('Runtime error', message);
}

class InvalidArgumentTypesError extends RuntimeError {
  InvalidArgumentTypesError({
    required String function,
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
