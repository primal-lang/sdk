import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class VectorDot extends NativeFunctionTerm {
  const VectorDot()
    : super(
        name: 'vector.dot',
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

  /// Computes the dot product of two vectors from their native lists.
  static num computeDotProduct(List<num> valuesA, List<num> valuesB) {
    num dotProduct = 0;

    for (int index = 0; index < valuesA.length; index++) {
      dotProduct += valuesA[index] * valuesB[index];
    }

    return dotProduct;
  }

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

      return NumberTerm(computeDotProduct(valuesA, valuesB));
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

    return VectorDot.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
