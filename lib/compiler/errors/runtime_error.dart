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
            'Invalid argument types for function "$function". Expected: (${expected.join(', ')}). Actual: (${actual.join(', ')})');
}

class InvalidArgumentCountError extends RuntimeError {
  InvalidArgumentCountError({
    required String function,
    required int expected,
    required int actual,
  }) : super(
            'Invalid argument count for function "$function". Expected: $expected. Actual: $actual');
}

class NotFoundInScopeError extends RuntimeError {
  const NotFoundInScopeError(String variable)
      : super('Variable "$variable" not found in scope');
}

class InvalidFunctionError extends RuntimeError {
  const InvalidFunctionError(String variable)
      : super('"$variable" is not a function');
}
