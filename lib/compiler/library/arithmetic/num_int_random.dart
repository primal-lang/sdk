import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

final Random _random = Random();

class NumIntegerRandom extends NativeFunctionTerm {
  const NumIntegerRandom()
    : super(
        name: 'num.integerRandom',
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
      final int min = a.value.toInt();
      final int max = b.value.toInt();
      if (max < min) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'max ($max) must be >= min ($min)',
        );
      }
      final int range = max - min + 1;
      if (range <= 0) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'range overflow',
        );
      }
      return NumberTerm(min + _random.nextInt(range));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
