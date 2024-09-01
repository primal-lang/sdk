import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/models/location.dart';
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
            'Invalid argument types for function "$function". Expected: (${expected.join(', ')}). Actual: (${actual.join(', ')})');
}

class InvalidArgumentCountError extends RuntimeError {
  InvalidArgumentCountError({
    required String function,
    required int expected,
    required int actual,
    required Location location,
  }) : super(
            'Invalid argument count for function "$function" at $location. Expected: $expected. Actual: $actual');
}

class NotFoundInScope extends RuntimeError {
  const NotFoundInScope(String variable)
      : super('Variable "$variable" not found in scope');
}

class EmptyExpressionEvaluationError extends RuntimeError {
  const EmptyExpressionEvaluationError()
      : super('Cannot reduce empty expression');
}
