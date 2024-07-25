import 'package:dry/compiler/errors/generic_error.dart';

class RuntimeError extends GenericError {
  const RuntimeError(super.message);
}

class UndefinedArgumentError extends RuntimeError {
  const UndefinedArgumentError(String argument)
      : super('Undefined argument "$argument"');
}

class InvalidArgumentCountError extends RuntimeError {
  InvalidArgumentCountError({
    required String function,
    required int expected,
    required int actual,
  }) : super(
            'Invalid argument count for function "$function". Expected: $expected. Actual: $actual');
}

class InvalidArgumentTypesError extends RuntimeError {
  InvalidArgumentTypesError({
    required String function,
    required List<String> expected,
    required List<String> actual,
  }) : super(
            'Invalid argument types for function "$function". Expected: (${expected.join(', ')}). Actual: (${actual.join(', ')})');
}

class EmptyExpressionEvaluationError extends RuntimeError {
  const EmptyExpressionEvaluationError()
      : super('Cannot evaluate empty expression');
}
