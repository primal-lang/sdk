import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class VectorDistance extends NativeFunctionTerm {
  const VectorDistance()
    : super(
        name: 'vector.distance',
        parameters: const [
          Parameter.vector('a'),
          Parameter.vector('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );

  static NumberTerm execute({
    required FunctionTerm function,
    required Term a,
    required Term b,
  }) {
    if ((a is VectorTerm) && (b is VectorTerm)) {
      final List<num> valuesA = a.native().cast<num>();
      final List<num> valuesB = b.native().cast<num>();

      if (valuesA.length != valuesB.length) {
        throw IterablesWithDifferentLengthError(
          iterable1: valuesA,
          iterable2: valuesB,
        );
      }

      double sumOfSquares = 0;

      for (int index = 0; index < valuesA.length; index++) {
        final num difference = valuesA[index] - valuesB[index];
        sumOfSquares += difference * difference;
      }

      return NumberTerm(sqrt(sumOfSquares));
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
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

    return VectorDistance.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
