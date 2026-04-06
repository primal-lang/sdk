import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class VectorMagnitude extends NativeFunctionTerm {
  const VectorMagnitude()
    : super(
        name: 'vector.magnitude',
        parameters: const [
          Parameter.vector('a'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );

  /// Computes the magnitude (Euclidean norm) of a vector from its native list.
  static double computeMagnitude(List<num> values) {
    double sumOfSquares = 0;

    for (final num element in values) {
      sumOfSquares += element * element;
    }

    return sqrt(sumOfSquares);
  }

  static NumberTerm execute({
    required FunctionTerm function,
    required Term a,
  }) {
    if (a is VectorTerm) {
      final List<num> values = a.native().cast<num>();

      return NumberTerm(computeMagnitude(values));
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type],
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

    return VectorMagnitude.execute(
      function: this,
      a: a,
    );
  }
}
