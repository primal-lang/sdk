import 'package:dry/compiler/errors/generic_error.dart';

class RuntimeError extends GenericError {
  const RuntimeError(super.message);
}

class InvalidArgumentLengthError extends RuntimeError {
  const InvalidArgumentLengthError({
    required String function,
    required int expected,
    required int actual,
  }) : super(
            'Invalid argument length for function "$function". Expected: $expected. Actual: $actual');
}

class InvalidArgumentTypesError extends RuntimeError {
  InvalidArgumentTypesError({
    required String function,
    required List<String> expected,
    required List<String> actual,
  }) : super(
            'Invalid argument length for function "$function". Expected: (${expected.join(', ')}). Actual: (${actual.join(', ')})');
}
