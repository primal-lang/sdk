import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class NumRoundTo extends NativeFunctionTerm {
  const NumRoundTo()
    : super(
        name: 'num.roundTo',
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
      final num value = a.value;
      final num places = b.value;

      if (places < 0) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'decimal places cannot be negative, got $places',
        );
      }

      if (!value.isFinite) {
        return NumberTerm(value);
      }

      final num multiplier = pow(10, places.truncate());
      return NumberTerm((value * multiplier).round() / multiplier);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
