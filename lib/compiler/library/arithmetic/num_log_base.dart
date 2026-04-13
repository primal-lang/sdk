import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class NumLogBase extends NativeFunctionTerm {
  const NumLogBase()
    : super(
        name: 'num.logBase',
        parameters: const [
          Parameter.number('a'),
          Parameter.number('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class TermWithArguments extends NativeFunctionTermWithArguments {
  const TermWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();
    final Term b = arguments[1].reduce();

    if ((a is NumberTerm) && (b is NumberTerm)) {
      if (a.value <= 0) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'cannot compute logarithm of non-positive number ${a.value}',
        );
      }
      if (b.value <= 0) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'base must be positive, got ${b.value}',
        );
      }
      if (b.value == 1) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'base cannot be 1',
        );
      }
      return NumberTerm(log(a.value) / log(b.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
