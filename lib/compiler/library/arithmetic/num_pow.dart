import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class NumPow extends NativeFunctionTerm {
  const NumPow()
    : super(
        name: 'num.pow',
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
      if (a.value < 0 && b.value != b.value.truncate()) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'cannot raise negative number to fractional power',
        );
      }
      final num result = pow(a.value, b.value);
      if (result.isNaN || result.isInfinite) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'result is not a finite number',
        );
      }
      return NumberTerm(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
