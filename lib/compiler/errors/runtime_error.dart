import 'package:dry/compiler/errors/generic_error.dart';
import 'package:dry/compiler/models/location.dart';

class RuntimeError extends GenericError {
  const RuntimeError(super.message);
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

class InvalidArgumentTypesError extends RuntimeError {
  InvalidArgumentTypesError({
    required String function,
    required List<String> expected,
    required List<String> actual,
  }) : super(
            'Invalid argument types for function "$function". Expected: (${expected.join(', ')}). Actual: (${actual.join(', ')})');
}

class NotFoundInScope extends RuntimeError {
  const NotFoundInScope(String variable)
      : super('Variable "$variable" not found in scope');
}

class EmptyExpressionEvaluationError extends RuntimeError {
  const EmptyExpressionEvaluationError()
      : super('Cannot evaluate empty expression');
}
